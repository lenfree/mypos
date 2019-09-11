defmodule Mypos.Repo.Migrations.UseDecimalForPriceProductItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
    modify :price, :decimal
    end
  end
end
