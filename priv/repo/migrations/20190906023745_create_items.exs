defmodule Mypos.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false
      add :description, :text
      add :added_on, :date, null: false, default: fragment("NOW()")
      add :price, :integer, null: false
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:category_id])
  end
end
