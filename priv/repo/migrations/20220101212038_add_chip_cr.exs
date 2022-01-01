defmodule ElixirBackend.Repo.Migrations.AddChipCr do
  use Ecto.Migration

  def change do
    alter table("Battlechip") do
      add :cr, :integer, null: false, default: 0
    end
  end
end
