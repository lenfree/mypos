defmodule MyposWeb.Resolvers.Ordering do
  alias Mypos.Ordering

  def create_order(_, %{input: params}, _) do
    with {:ok, order} <- Ordering.create_order(params) do
      {:ok, %{order: order}}
    end
  end

  def ready_order(_, %{id: id}, _) do
    order = Ordering.get_order!(id)

    with {:ok, order} <-
           Ordering.update_order(
             order,
             %{
               state: "ready"
             }
           ) do
      {:ok, %{order: order}}
    end
  end

  def complete_order(_, %{id: id}, _) do
    order = Ordering.get_order!(id)

    with {:ok, order} <-
           Ordering.update_order(
             order,
             %{
               state: "complete"
             }
           ) do
      {:ok, %{order: order}}
    end
  end
end
