defmodule MyposWeb.Authentication do
  @user_salt "user salt"

  def sign(data) do
    Phoenix.Token.sign(MyposWeb.Endpoint, @user_salt, data)
  end

  def verify(token) do
    Phoenix.Token.verify(MyposWeb.Endpoint, @user_salt, token, max_age: 365 * 24 * 3600)
  end
end
