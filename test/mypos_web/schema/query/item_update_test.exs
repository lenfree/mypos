defmodule MyposWeb.Schema.Mutation.ItemUpdateTest do
  use MyposWeb.ConnCase, async: true
  alias Mypos.{Product}

  setup do
    category_items =
      [
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

    {:ok, category1} = List.first(category_items)
    {:ok, category2} = List.last(category_items)

    {:ok, item} =
      %{
        "categoryId" => category2.id,
        "description" => "a kind of bread",
        "name" => "pan coco",
        "price" => 50
      }
      |> Product.create_item()

    {:ok, item: item, category: category1}
  end

  @query """
  mutation($id: ID!, $input: ItemInput) {
    updateItem(id: $id, input: $input) {
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
  test "updates an existing item", %{item: item, category: category} do
    conn = build_conn()

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          "id" => item.id,
          "input" => %{
            "name" => "pan desal",
            "category_id" => category.id
          }
        }
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "updateItem" => %{
                 "item" => %{
                   "category" => %{
                     "id" => to_string(category.id),
                     "name" => category.name
                   },
                   "description" => "a kind of bread",
                   "name" => "pan desal",
                   "price" => "50"
                 }
               }
             }
           }
  end
end
