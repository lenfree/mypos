defmodule MyposWeb.Schema.Mutation.CategoryDeleteItemTest do
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

    item = List.last(Product.list_categories())

    {:ok, item: item}
  end

  @query """
  mutation($id: ID!) {
    deleteCategoryItem(id: $id) {
      categoryItem {
        name
        description
      }
    }
  }
  """
  test "deletes a category", %{item: item} do
    conn = build_conn()
    conn = post(conn, "/api", query: @query, variables: %{"id" => item.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "deleteCategoryItem" => %{
                 "categoryItem" => %{
                   "name" => "drinks",
                   "description" => "any drinks"
                 }
               }
             }
           }

    expected_count = 1
    assert expected_count == Enum.count(Product.list_categories())
  end
end
