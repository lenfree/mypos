defmodule Mypos.Repo.Migrations.AddCreateUniqueIndexToItemTable do
  use Ecto.Migration

  def change do
    create unique_index(:items, [:name])
  end
end
