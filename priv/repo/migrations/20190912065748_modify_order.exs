defmodule Mypos.Repo.Migrations.ModifyOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :state, :string
      modify :items, :map
    end
  end
end
