defmodule MyposWeb.Schema.CategoryTypes do
  use Absinthe.Schema.Notation
  alias MyposWeb.Resolvers
  use Absinthe.Ecto, repo: PlateSlate.Repo

  object :category_queries do
    field(:category_list, list_of(:category)) do
      resolve(&Resolvers.Product.category_list/3)
    end
  end

  object :category do
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
  end

  input_object :category_item_input do
    field(:name, non_null(:string))
    field(:description, :string)
  end
end
