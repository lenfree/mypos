defmodule Mypos.Accounts do
  import Ecto.Query, warn: false
  alias Mypos.Repo
  alias Pbkdf2

  alias Mypos.Accounts.User

  def authenticate(role, email, password) do
    user = Repo.get_by(User, role: to_string(role), email: email)
    with %{password_hash: digest} <- user,
         true <- Pbkdf2.verify_pass(password, digest) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def lookup(role, id) do
    Repo.get_by(User, role: to_string(role), id: id)
  end
end
