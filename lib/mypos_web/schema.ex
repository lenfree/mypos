defmodule MyposWeb.Schema do
  use Absinthe.Schema
  alias MyposWeb.Resolvers
  alias MyposWeb.Schema.Middleware
  alias Mypos.Product

  def middleware(middleware, field, %{identifier: :allergy_info} = object) do
    new_middleware = {Absinthe.Middleware.MapGet, to_string(field.identifier)}

    middleware
    |> Absinthe.Schema.replace_default(new_middleware, field, object)
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  import_types(__MODULE__.ProductTypes)
  import_types(__MODULE__.OrderingTypes)
  import_types(__MODULE__.AccountsTypes)
  import_types(Absinthe.Phoenix.Types)

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Product, Mypos.Product.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  @desc "The list of categories"
  query do
    import_fields(:category_queries)
    import_fields(:item_queries)
    import_fields(:product_search)
  end

  mutation do
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:role, non_null(:role))
      resolve(&Resolvers.Accounts.login/3)

      middleware(fn res, _ ->
        with %{value: %{user: user}} <- res do
          %{res | context: Map.put(res.context, :current_user, user)}
        end
      end)
    end

    field :logout, :query do
      middleware(fn res, _ ->
        %{
          res
          | context: Map.delete(res.context, :current_user),
            value: "logged out",
            state: :resolved
        }
      end)
    end

    field :create_category_item, :category_item_result do
      arg(:input, :category_item_input)
      resolve(&Resolvers.Product.category_create/3)
    end

    field(:delete_category_item, :category_item_result) do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Product.category_delete/3)
    end

    field(:update_category_item, :category_item_result) do
      arg(:id, non_null(:id))
      arg(:input, :category_item_input)
      resolve(&Resolvers.Product.category_update/3)
    end

    field :create_item, :item_result do
      arg(:input, :item_input)
      middleware(Middleware.Authorize, "employee")
      resolve(&Resolvers.Product.item_create/3)
    end

    field(:update_item, :item_result) do
      arg(:id, non_null(:id))
      arg(:input, :item_input)
      resolve(&Resolvers.Product.item_update/3)
    end

    field(:delete_item, :item_result) do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Product.item_delete/3)
    end

    field(:place_order, :order_result) do
      arg(:input, non_null(:place_order_input))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.Ordering.create_order/3)
    end

    field :ready_order, :order_result do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.ready_order/3)
    end

    field :complete_order, :order_result do
      arg(:id, non_null(:id))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.Ordering.complete_order/3)
    end
  end

  subscription do
    field :new_order, :order do
      config(fn _args, %{context: context} ->
        case context[:current_user] do
          %{role: "customer", id: id} ->
            {:ok, topic: id}

          %{role: "employee"} ->
            {:ok, topic: "*"}

          _ ->
            {:ok, topic: "*"}
        end
      end)

      trigger([:place_order],
        topic: fn
          %{order: order} ->
            ["*", order.customer_number]

          _ ->
            []
        end
      )

      resolve(fn %{order: order}, _, _ ->
        {:ok, order}
      end)
    end

    field :update_order, :order do
      arg(:id, non_null(:id))

      config(fn args, _info ->
        {:ok, topic: args.id}
      end)

      trigger([:ready_order, :complete_order],
        topic: fn
          %{order: order} -> [order.id]
          _ -> []
        end
      )

      resolve(fn %{order: order}, _, _ ->
        {:ok, order}
      end)
    end
  end

  scalar :date do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end

  scalar :decimal do
    parse(fn
      %{value: value}, _ ->
        Decimal.parse(value)

      _, _ ->
        :error
    end)

    serialize(&to_string/1)
  end
end
