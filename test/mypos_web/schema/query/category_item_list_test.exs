defmodule MyposWeb.Schema.Query.CategoryListItemTest do
  use MyposWeb.ConnCase, async: true
  alias Mypos.{Product}

  setup do
    category_items = [
      %{
        "name" => "bags",
        "description" => "all types of bags"
      },
      %{
        "name" => "backpacks",
        "description" => "all backpacks"
      }
    ]

    category_items
    |> Enum.map(&Product.create_category/1)
  end

  @query """
  {
    categoryList{
      categoryItems{
        name
        description
      }
    }
  }
  """
  test "should return all categories" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "categoryList" => %{
                 "categoryItems" => [
                   %{"name" => "bags", "description" => "all types of bags"},
                   %{"name" => "backpacks", "description" => "all backpacks"}
                 ]
               }
             }
           }
  end
end
