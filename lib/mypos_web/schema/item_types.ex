defmodule MyposWeb.Schema.ProductTypes do
  use Absinthe.Schema.Notation
  alias MyposWeb.Resolvers
  use Absinthe.Ecto, repo: Mypos.Repo

  object :category_queries do
    field(:category_list, :category_items_result) do
      resolve(&Resolvers.Product.category_list/3)
    end
  end

  object :category_item do
    interfaces([:search_result])
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
  end

  input_object :category_item_input do
    field(:name, non_null(:string))
    field(:description, :string)
  end

  object :category_item_result do
    field(:category_item, :category_item)
    field(:errors, list_of(:input_error))
  end

  object :category_items_result do
    field(:category_items, list_of(:category_item))
    field(:errors, list_of(:input_error))
  end

  object :input_error do
    field(:key, non_null(:string))
    field(:message, non_null(:string))
  end

  object :item_queries do
    field(:item_list, :items_result) do
      resolve(&Resolvers.Product.item_list/3)
    end
  end

  object :item do
    interfaces([:search_result])
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
    field(:price, :decimal)
    field(:added_on, :date)

    field(:category, :category_item, resolve: assoc(:category))
  end

  object :items_result do
    field(:items, list_of(:item))
    field(:errors, list_of(:input_error))
  end

  object :item_result do
    field(:item, :item)
    field(:errors, list_of(:input_error))
  end

  input_object :item_input do
    field(:name, non_null(:string))
    field(:description, :string)
    field(:price, :decimal)
    field(:category_id, non_null(:id))
  end

  object :product_search do
    field(:search, list_of(:search_result)) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Product.search/3)
    end
  end

  interface :search_result do
    field(:name, :string)

    resolve_type(fn
      %Mypos.Product.Item{}, _ ->
        :item

      %Mypos.Product.Category{}, _ ->
        :category_item

      _, _
        -> nil
    end)
  end
end
