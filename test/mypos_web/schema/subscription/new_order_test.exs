defmodule MyposWeb.Schema.Subscription.NewOrderTest do
  use MyposWeb.SubscriptionCase

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

  @login """
  mutation ($email: String!, $role: Role!) {
    login(role: $role, password: "super-secret", email: $email) {
      token
    }
  }
  """

  test "new orders can be subscribed to", %{socket: socket} do
    user = Factory.create_user("employee")

    ref =
      push_doc(socket, @login,
        variables: %{
          "email" => user.email,
          "role" => "EMPLOYEE"
        }
      )

    assert_reply(ref, :ok, %{data: %{"login" => %{"token" => token}}}, 1_000)
    item = item_fixture()

    # setup a subscription
    ref = push_doc(socket, @subscription)
    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

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

    assert_push("subscription:data", push)
    assert expected == push
  end

  test "customers can't see other customer orders", %{socket: socket} do
    customer1 = Factory.create_user("customer")

    # login as customer1
    ref =
      push_doc(socket, @login,
        variables: %{
          "email" => customer1.email,
          "role" => "CUSTOMER"
        }
      )

    assert_reply(ref, :ok, %{data: %{"login" => %{"token" => _}}}, 1_000)

    # subscribe to orders
    ref = push_doc(socket, @subscription)
    assert_reply(ref, :ok, %{subscriptionId: _subscription_id})
    # customer1 places order
    place_order(customer1)

    assert_push("subscription:data", push)

    # customer2 places order
    customer2 = Factory.create_user("customer")
    place_order(customer2)
    refute_receive _
  end

  defp place_order(customer) do
    int = :erlang.unique_integer([:positive, :monotonic])

    category =
      category_fixture(%{
        name: "drinks-#{int}"
      })

    item =
      item_fixture(%{
        category_id: category.id,
        name: "h#{int}o"
      })

    order_input = %{
      "customerNumber" => 24,
      "items" => [%{"quantity" => 2, "ItemId" => item.id}]
    }

    IO.inspect(order_input)

    {:ok, %{data: %{"placeOrder" => _}}} =
      Absinthe.run(@mutation, MyposWeb.Schema,
        context: %{current_user: customer, pubsub: MyposWeb.Endpoint},
        variables: %{"input" => order_input}
      )
  end
end
