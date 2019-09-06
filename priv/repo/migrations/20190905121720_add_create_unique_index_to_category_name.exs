defmodule Mypos.Repo.Migrations.AddCreateUniqueIndexToCategoryName do
  use Ecto.Migration

  def change do
    create unique_index(:categories, [:name])
  end
end
