defmodule Mypos.Repo.Migrations.SetDefaultOrderState do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :state, :string, null: false, default: "created"
    end
  end
end
