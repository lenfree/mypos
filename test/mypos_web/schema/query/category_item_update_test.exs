defmodule MyposWeb.Schema.Mutation.CategoryUpdateItemTest do
  use MyposWeb.ConnCase, async: true
  alias Mypos.{Product}

  setup do
    category_items = [
      %{
        "name" => "bread",
        "description" => "all breads"
      },
      %{
        "name" => "drinks",
        "description" => "any drinks"
      }
    ]

    category_items
    |> Enum.map(&Product.create_category/1)

    [item | _items] = Product.list_categories()

    {:ok, item: item}
  end

  @query """
  mutation($id: ID!, $input: CategoryItemInput) {
    updateCategoryItem(id: $id, input: $input) {
      categoryItem {
        name
        description
      }
    }
  }
  """
  test "updates an existing category", %{item: item} do
    conn = build_conn()

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          "id" => item.id,
          "input" => %{
            "name" => "new category",
            "description" => "a category updated"
          }
        }
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "updateCategoryItem" => %{
                 "categoryItem" => %{
                   "name" => "new category",
                   "description" => "a category updated"
                 }
               }
             }
           }
  end
end
