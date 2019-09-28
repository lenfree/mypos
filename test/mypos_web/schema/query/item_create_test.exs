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
    user = Factory.create_user("employee")
    conn = build_conn() |> auth_user(user)

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

  test "must be authorized as an employee to do menu item creation", %{category: category} do
    user = Factory.create_user("customer")
    conn = build_conn() |> auth_user(user)

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
               "createItem" => nil
             },
             "errors" => [
               %{
                 "locations" => [%{"column" => 0, "line" => 2}],
                 "message" => "unauthorized",
                 "path" => ["createItem"]
               }
             ]
           }
  end

  def auth_user(conn, user) do
    token = MyposWeb.Authentication.sign(%{role: user.role, id: user.id})
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
