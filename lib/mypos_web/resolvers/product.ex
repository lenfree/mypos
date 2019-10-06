defmodule MyposWeb.Resolvers.Product do
  alias Mypos.Product

  def category_list(_, _params, _) do
    categories = Product.list_categories()
    {:ok, %{category_items: categories}}
  end

  def category_create(_, %{input: params}, _) do
    with {:ok, category_item} <- Product.create_category(params) do
      {
        :ok,
        %{category_item: category_item}
      }
    end
  end

  def category_delete(_, %{id: id}, _) do
    category = Product.get_category!(id)

    with {:ok, category_item} <- Product.delete_category(category) do
      {:ok, %{category_item: category_item}}
    end
  end

  def category_update(_, %{id: id, input: params}, _) do
    category = Product.get_category!(id)

    with {:ok, category_item} <- Product.update_category(category, params) do
      {:ok, %{category_item: category_item}}
    end
  end

  def item_list(_, _args, _) do
    {:ok, %{items: Product.list_items()}}
  end

  def item_create(_, %{input: params}, _resolution) do
    with {:ok, item} <- Product.create_item(params) do
      {
        :ok,
        %{item: item}
      }
    end
  end

  def item_update(_, %{id: id, input: params}, _) do
    item = Product.get_item!(id)

    with {:ok, item} <- Product.update_item(item, params) do
      {:ok, %{item: item}}
    end
  end

  def item_delete(_, %{id: id}, _) do
    item = Product.get_item!(id)

    with {:ok, item} <- Product.delete_item(item) do
      {:ok, %{item: item}}
    end
  end

  def search(_, %{matching: term}, _) do
    {:ok, Product.search(term)}
  end
end
