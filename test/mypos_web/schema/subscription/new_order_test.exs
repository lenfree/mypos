defmodule MyposWeb.Schema.Subscription.NewOrderTest do
  use MyposWeb.SubscriptionCase
  alias Mypos.Product.{Item, Category}

  @subscription """
    subscription {
      newOrder {
        customerNumber
      }
    }

  """

  @mutation """
    mutation($input: PlaceOrderInput!) {
      placeOrder(input: $input) {
        order {
          id
        }
      }
    }
  """

  test "new orders can be subscribed to", %{socket: socket} do
    item = item_fixture()

    # setup a subscription
    ref = push_doc(socket, @subscription)
    assert_reply ref, :ok, %{subscriptionId: subscription_id}

    # place an order
    order_input = %{
      "customerNumber" => 24,
      "items" => [
        %{"item_id" => item.id, "quantity" => 2}
      ]
    }

    ref = push_doc(socket, @mutation, variables: %{input: order_input})

    assert_reply(ref, :ok, reply)

    assert %{
             data: %{
               "placeOrder" => %{
                 "order" => %{
                   "id" => _
                 }
               }
             }
           } = reply

    expected = %{
      result: %{data: %{"newOrder" => %{"customerNumber" => 24}}},
      subscriptionId: subscription_id
    }

    assert_push "subscription:data", push
    assert expected == push
  end
end
