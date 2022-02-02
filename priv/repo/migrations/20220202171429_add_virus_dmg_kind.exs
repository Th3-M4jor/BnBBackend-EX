defmodule ElixirBackend.Repo.Migrations.AddVirusDmgKind do
  use Ecto.Migration

  def change do
    # add_query = "ALTER TABLE virus ADD COLUMN dmg_kind \"ChipType\""

    alter table("Virus") do
      add :attack_kind, :"\"ChipType\""
    end
  end
end
