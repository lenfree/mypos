defmodule Mypos.TestHelpers do
  alias Mypos.{
    Product,
    Ordering
  }

  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        price: attrs[:price] || 5.6,
        description: attrs[:description] || "sourdough loaf",
        name: attrs[:name] || "sourdough",
        category_id: attrs[:category_id] || category_fixture().id
      })
      |> Product.create_item()

    item
  end

  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: attrs[:description] || "bread",
        name: attrs[:name] || "bread"
      })
      |> Product.create_category()

    category
  end
end
