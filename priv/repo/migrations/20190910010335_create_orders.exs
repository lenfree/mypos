defmodule Mypos.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :customer_number, :serial
      add :items, :map
      add :ordered_at, :utc_datetime, null: false, default: fragment("NOW()")
      add :state, :string

      timestamps()
    end

  end
end
