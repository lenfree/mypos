defmodule MyposWeb.Resolvers.Product do
  alias Mypos.Product

  def category_list(_, _params, _) do
    categories = Product.list_categories()
    {:ok, %{category_items: categories}}
  end

  def category_create(_, %{input: params}, _) do
    case Product.create_category(params) do
      {:ok, category_item} ->
        {
          :ok,
          %{category_item: category_item}
        }

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
    end
  end

  def category_delete(_, %{id: id}, _) do
    category = Product.get_category!(id)

    case Product.delete_category(category) do
      {:ok, category_item} ->
        {:ok, %{category_item: category_item}}

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
    end
  end

  def category_update(_, %{id: id, input: params}, _) do
    category = Product.get_category!(id)

    case Product.update_category(category, params) do
      {:ok, category_item} ->
        {:ok, %{category_item: category_item}}

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
    end
  end

  def item_list(_, _args, _) do
    {:ok, %{items: Product.list_items()}}
  end

  def item_create(_, %{input: params}, _) do
    case Product.create_item(params) do
      {:ok, item} ->
        {
          :ok,
          %{item: item}
        }

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
    end
  end

  def item_update(_, %{id: id, input: params}, _) do
    item = Product.get_item!(id)

    case Product.update_item(item, params) do
      {:ok, item} ->
        {:ok, %{item: item}}

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
    end
  end

  def item_delete(_, %{id: id}, _) do
    item = Product.get_item!(id)

    case Product.delete_item(item) do
      {:ok, item} ->
        {:ok, %{item: item}}

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
    end
  end

  def transform_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn {key, value} ->
      %{key: key, message: value}
    end)
  end

  def format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def search(_, %{matching: term}, _) do
    {:ok, Product.search(term)}
  end
end
