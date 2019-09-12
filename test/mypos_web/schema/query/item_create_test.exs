defmodule MyposWeb.Schema.Mutation.ItemCreateTest do
  use MyposWeb.ConnCase, async: true
  alias Mypos.{Product}

  setup do
    category_items = [
      %{
        "name" => "lunch box",
        "description" => "kiddies lunch box"
      }
    ]

    category_items
    |> Enum.map(&Product.create_category/1)

    category = List.last(Product.list_categories())
    {:ok, category: category}
  end

  @query """
  mutation($input: ItemInput) {
    createItem(input: $input) {
      item{
        name
        description
        price
        category {
          name
          id
        }
      }
    }
  }
  """
  test "create item with category id", %{category: category} do
    conn = build_conn()

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          "input" => %{
            "categoryId" => category.id,
            "description" => "a kind of bread",
            "name" => "pan coco",
            "price" => "50"
          }
        }
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "createItem" => %{
                 "item" => %{
                   "description" => "a kind of bread",
                   "name" => "pan coco",
                   "price" => "50",
                   "category" => %{
                     "id" => to_string(category.id),
                     "name" => category.name
                   }
                 }
               }
             }
           }
  end
end
