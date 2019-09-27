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
      resolve(&Resolvers.Ordering.create_order/3)
    end

    field :ready_order, :order_result do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.ready_order/3)
    end

    field :complete_order, :order_result do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.complete_order/3)
    end

    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:role, non_null(:role))
      resolve(&Resolvers.Accounts.login/3)
    end
  end

  subscription do
    field :new_order, :order do
      config(fn _args, _info ->
        {:ok, topic: "*"}
      end)

      trigger([:place_order],
        topic: fn
          %{order: _order} ->
            ["*"]

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
