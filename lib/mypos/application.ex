defmodule Mypos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Mypos.Repo,
      # Start the endpoint when the application starts
      MyposWeb.Endpoint
      # Starts a worker by calling: Mypos.Worker.start_link(arg)
      # {Mypos.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mypos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MyposWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
