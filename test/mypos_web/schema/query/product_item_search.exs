defmodule MypostWeb.Schema.Mutation.ProductItemSearchTest do
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
#
    {:ok, category2} = List.first(category_items)

    {:ok, item} = %{
      "categoryId" => category2.id,
      "description" => "a kind of bread",
      "name" => "pan coco",
      "price" => 50,
    } |> Product.create_item

    {:ok, item: item}
  end
#
  @query """
  query Search($term: String!) {
    len: search(matching: $term) {
      ... on Item{
        name
        description
        price
      }
      ... on CategoryItem{
        name
        description
      }
    }
  }
  """
  test "search returns list of matching terms" do
    assert 1 == 1
    conn = build_conn()

    conn = get(conn, "/api", query: @query, variables: %{"term" =>  "i"})

    assert json_response(conn, 200) == %{
      "data" => %{
        "len" => [
          %{
            "description" => "a kind of bread",
            "name" => "pan coco",
             "price" => 50
          },
          %{
            "description" =>
            "kiddies lunch box",
            "name" => "lunch box"
          },
          %{
            "description" => "all drinks",
            "name" => "drinks"
          }
        ]
    }}
  end
end
#
