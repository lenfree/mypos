defmodule MyposWeb.Router do
  use MyposWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :graphql do
    plug MyposWeb.Context
  end

  scope "/" do
    pipe_through(:graphql)

    forward(
      "/api",
      Absinthe.Plug,
      schema: MyposWeb.Schema
    )

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: MyposWeb.Schema,
      socket: MyposWeb.UserSocket
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyposWeb do
  #   pipe_through :api
  # end
end
