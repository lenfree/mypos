defmodule Mypos.OrderingTest do
  use Mypos.DataCase

  alias Mypos.Ordering

  describe "orders" do
    alias Mypos.Ordering.Order

    @valid_attrs %{
      customer_number: 42,
      items: %{},
      ordered_at: "2010-04-17T14:00:00Z",
      state: "some state"
    }
    @update_attrs %{
      customer_number: 43,
      items: %{},
      ordered_at: "2011-05-18T15:01:01Z",
      state: "some updated state"
    }
    @invalid_attrs %{
      customer_number: nil,
      ordered_at: nil,
      items: [%{item_id: 2}]
    }

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ordering.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Ordering.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Ordering.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Ordering.create_order(@valid_attrs)
      assert order.customer_number == 42
      assert order.items == []
      assert order.ordered_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert order.state == "some state"
    end

    #    test "create_order/1 with invalid data returns error changeset" do
    #      assert {:error, %Ecto.Changeset{}} = Ordering.create_order(@invalid_attrs)
    #    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Ordering.update_order(order, @update_attrs)
      assert order.customer_number == 43
      assert order.items == []
      assert order.ordered_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert order.state == "some updated state"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Ordering.update_order(order, @invalid_attrs)
      assert order == Ordering.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Ordering.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Ordering.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Ordering.change_order(order)
    end
  end
end
