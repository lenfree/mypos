defmodule MyposWeb.SessionController do
  use MyposWeb, :controller

  require IEx

  use Absinthe.Phoenix.Controller,
    schema: MyposWeb.Schema

  def new(conn, _params) do
    render(conn, "new.html")
  end

  @graphql """
  mutation($email: String!, $password: String!) @action(mode: INTERNAL) {
    login(role: EMPLOYEE, email: $email, password: $password)
  }
  """
  def create(conn, %{data: %{login: result}}) do
    case result do
      %{user: employee} ->
        conn
        |> put_session(:employee_id, employee.id)
        |> put_flash(:info, "Login Successful")
        |> redirect(to: "/admin/items")

      _ ->
        conn
        |> put_flash(:info, "Wrong email or password")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session
    |> redirect(to: "/admin/session/new")
  end
end
