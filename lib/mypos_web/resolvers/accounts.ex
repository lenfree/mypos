defmodule MyposWeb.Resolvers.Accounts do
  alias Mypos.Accounts

  def login(_, %{email: email, password: password, role: role}, _) do
    case Accounts.authenticate(role, email, password) do
      {:ok, user} ->
        token =
          MyposWeb.Authentication.sign(%{
            role: role,
            id: user.id
          })

        {:ok, %{token: token, user: user}}

      _ ->
        {:error, "incorrect email or password"}
    end
  end
end
