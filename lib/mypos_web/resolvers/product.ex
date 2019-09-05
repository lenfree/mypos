defmodule MyposWeb.Resolvers.Product do
  alias Mypos.Product

  def category_list(_, _params, _) do
    {:ok, Product.list_categories()}
  end

  def category_create(_, %{input: params}, _) do
    case Product.create_category(params) do
      {:ok, changeset} ->
        {:ok, changeset}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
