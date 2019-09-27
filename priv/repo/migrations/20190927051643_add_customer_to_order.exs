defmodule Mypos.Repo.Migrations.AddCustomerToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :customer_id, references(:users)
    end
  end
end
