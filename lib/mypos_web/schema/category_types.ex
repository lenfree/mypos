defmodule MyposWeb.Schema.CategoryTypes do
  use Absinthe.Schema.Notation
  alias MyposWeb.Resolvers

  object :category_queries do
    field(:category_list, :category_items_result) do
      resolve(&Resolvers.Product.category_list/3)
    end
  end

  object :category_item do
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
end
