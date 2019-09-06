defmodule MyposWeb.Schema.Mutation.ItemDeleteTest do
  use MyposWeb.ConnCase, async: true
  alias Mypos.{Product}

  setup do
    category_items = [
      %{
        "name" => "lunch box",
        "description" => "kiddies lunch box"
      },
      %{
        "name" => "drinks",
        "description" => "all drinks"
      }
    ]
    |> Enum.map(&Product.create_category/1)

    {:ok, category2} = List.last(category_items)

    {:ok, item} = %{
      "categoryId" => category2.id,
      "description" => "a kind of bread",
      "name" => "pan coco",
      "price" => 50,
    } |> Product.create_item

    {:ok, item: item, category: category2}
  end

  @query """
  mutation($id: ID!) {
    deleteItem(id: $id) {
      item {
        name
        description
        price
        category {
          id
          name
        }
      }
    }
  }
  """
  test "deletes an item", %{item: item} do
    conn = build_conn()

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          "id" => item.id
        }
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "deleteItem" => %{
                "item" => %{
                  "category" => nil,
                  "description" => "a kind of bread",
                   "name" => "pan coco",
                   "price" => 50
                  }
                }
             }
           }
  end
end
