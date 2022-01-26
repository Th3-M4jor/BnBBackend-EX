defmodule ElixirBackend.Repo.Migrations.AddChipMedians do
  use Ecto.Migration

  def change do
    alter table("Battlechip") do
      add :median_hits, :float, null: false, default: 1.0
      add :median_targets, :float, null: false, default: 1.0
    end
  end
end
