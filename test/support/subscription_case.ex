defmodule MyposWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by subscription tests
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      use MyposWeb.ChannelCase
      import Mypos.TestHelpers

      use Absinthe.Phoenix.SubscriptionTest,
        schema: MyposWeb.Schema

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(MyposWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
        {:ok, socket: socket}
      end

      import unquote(__MODULE__), only: [menu_item: 1]
      @valid_attrs %{description: "some description", name: "some name"}
    end
  end

  # handy function for grabbing a fixture
  def menu_item(name) do
    Mypos.Repo.get_by!(Mypos.Product.Item, name: name)
  end
end
