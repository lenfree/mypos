defmodule MyposWeb.Schema.Mutation.CategoryCreateItemTest do
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
  end

  @query """
  mutation($input: CategoryItemInput!) {
    createCategoryItem(input: $input) {
      categoryItem{
        name
        description
      }
    }
  }
  """

  test "should create an item and list of categories should be 2" do
    conn = build_conn()

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          "input" => %{
            "name" => "bags",
            "description" => "all types of bags"
          }
        }
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "createCategoryItem" => %{
                 "categoryItem" => %{
                   "name" => "bags",
                   "description" => "all types of bags"
                 }
               }
             }
           }

    expected_count = 2
    assert expected_count == Enum.count(Product.list_categories())
  end

  @query """
  mutation($input: CategoryItemInput!) {
    createCategoryItem(input: $input) {
      categoryItem{
        name
        description
      }
      errors{
        key
        message
      }
    }
  }
  """
  test "should return name has already been taken" do
    conn = build_conn()

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{"input" => %{"name" => "lunch box", "description" => "kiddies lunch box"}}
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "createCategoryItem" => %{
                 "categoryItem" => nil,
                 "errors" => [
                   %{
                     "key" => "name",
                     "message" => "has already been taken"
                   }
                 ]
               }
             }
           }
  end
end
