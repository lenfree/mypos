defmodule MyposWeb.ItemController do
  use MyposWeb, :controller

  use Absinthe.Phoenix.Controller,
    schema: MyposWeb.Schema

  @graphql """
  query Index @action(mode: INTERNAL)
  {
    item_list {
      items @put{
        category
      }
    }
  }
  """
  def index(conn, result) do
    result |> IO.inspect()
    render(conn, "index.html", items: result.data.item_list.items)
  end
end
