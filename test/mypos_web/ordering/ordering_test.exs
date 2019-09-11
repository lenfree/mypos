defmodule MyposWeb.OrderingTest do
  use Mypos.DataCase, async: true
  alias Mypos.Ordering
  alias Mypos.Product

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
    |> Enum.map(&Product.create_category/1)

    {:ok, category2} = List.last(category_items)

    [
      %{
        "categoryId" => category2.id,
        "description" => "a kind of bread",
        "name" => "pan coco",
        "price" => 5,
      },
      %{
        "categoryId" => category2.id,
        "description" => "another bread",
        "name" => "pan desal",
        "price" => 3.5,
      }
    ] |> Enum.map(&Product.create_item/1)
  end

  describe "orders" do
    alias Mypos.Ordering.Order
    test "create_order/1 with valid data creates a order" do
      item1 = Repo.get_by(Mypos.Product.Item, name: "pan desal")
      item2 = Repo.get_by(Mypos.Product.Item, name: "pan coco")

      attrs = %{
        ordered_at: "2019-10-17 07:00:00.000000Z",
        state: "created",
        items: [
          %{item_id: item1.id, quantity: 5},
          %{item_id: item2.id, quantity: 2}
        ]
      }

      assert {:ok, %Order{} = order} = Ordering.create_order(attrs)
      assert Enum.map(order.items, &Map.take(&1, [:name, :quantity, :price])) == [
       %{name: "pan desal", quantity: 5, price: item1.price},
       %{name: "pan coco", quantity: 2, price: item2.price},
      ]
      assert order.state == "created"
    end
  end
end
