defmodule MyposWeb.Schema do
  use Absinthe.Schema
  alias MyposWeb.Resolvers
  import_types(__MODULE__.CategoryTypes)

  @desc "The list of categories"
  query do
    import_fields(:category_queries)
  end

  mutation do
    field :create_category_item, :category do
      arg(:input, :category_item_input)
      resolve(&Resolvers.Product.category_create/3)
    end
  end
end
