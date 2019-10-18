defmodule MyposWeb.Router do
  use MyposWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin_auth do
    plug MyposWeb.AdminAuth
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

  scope "/admin", MyposWeb do
    pipe_through(:browser)

    resources "/session", SessionController,
      only: [:new, :create, :delete],
      singleton: true
  end

  scope "/admin", MyposWeb do
    pipe_through [:browser, :admin_auth]

    resources "/items", ItemController
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyposWeb do
  #   pipe_through :api
  # end
end
