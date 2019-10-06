defmodule MyposWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket, schema: MyposWeb.Schema
  ## Channels
  # channel "room:*", MyposWeb.RoomChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket, _connect_info) do
    # This is enabled to allow token/user auth context for graphiql only.
    # Please see https://github.com/absinthe-graphql/absinthe_plug/issues/137
    # for explanation and implementation is an example from below
    # https://github.com/absinthe-graphql/absinthe/blob/master/guides/subscriptions.md
    # TODO: Please fix redundant functions on line 50 and 62.
    user = build_context(params)

    socket =
      Absinthe.Phoenix.Socket.put_options(socket,
        context: %{
          current_user: user
        }
      )

    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     MyposWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil

  defp build_context(params) do
    case Map.has_key?(params, "Authorization") do
      true ->
        with "Bearer " <> token = params["Authorization"],
             {:ok, data} <- MyposWeb.Authentication.verify(token),
             %{} = user <- get_user(data) do
          user
        else
          _ ->
            ""
        end

      _ ->
        ""
    end
  end

  defp get_user(%{id: id, role: role}) do
    Mypos.Accounts.lookup(role, id)
  end
end
