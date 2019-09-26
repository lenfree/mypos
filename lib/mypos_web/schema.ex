defmodule MyposWeb.Schema do
  use Absinthe.Schema
  alias MyposWeb.Resolvers

  import_types(__MODULE__.ProductTypes)
  import_types(__MODULE__.OrderingTypes)

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Category, Mypos.Product.data())

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
