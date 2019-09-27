defmodule Factory do
  alias Mypos.Repo
  alias Mypos.Accounts

  def create_user(role) do
    int = :erlang.unique_integer([:positive, :monotonic])

    params = %{
      name: "Person #{int}",
      email: "fake-#{int}@example.com",
      password: "super-secret",
      role: role
    }

    %Accounts.User{}
    |> Accounts.User.changeset(params)
    |> Repo.insert!()
  end
end
