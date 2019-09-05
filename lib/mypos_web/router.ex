defmodule MyposWeb.Router do
  use MyposWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through(:api)
    forward("/api", Absinthe.Plug, schema: MyposWeb.Schema)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: MyposWeb.Schema,
      interface: :simple,
      socket: MyposWeb.UserSocket
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyposWeb do
  #   pipe_through :api
  # end
end
