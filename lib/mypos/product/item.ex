defmodule Mypos.Product.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :added_on, :date
    field :description, :string
    field :name, :string
    field :price, :decimal
    field :allergy_info, {:array, :map}
    belongs_to(:category, Mypos.Product.Category)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :added_on, :price, :category_id, :allergy_info])
    |> validate_required([:name, :description, :price])
    |> unique_constraint(:name)
    |> assoc_constraint(:category)
    |> foreign_key_constraint(:category_id)
  end
end
