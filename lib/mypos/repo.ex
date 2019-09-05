defmodule Mypos.Repo do
  use Ecto.Repo,
    otp_app: :mypos,
    adapter: Ecto.Adapters.Postgres
end
