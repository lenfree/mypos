defmodule MyposWeb.PageController do
  use MyposWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
