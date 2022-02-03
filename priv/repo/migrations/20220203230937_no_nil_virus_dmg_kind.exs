defmodule ElixirBackend.Repo.Migrations.NoNilVirusDmgKind do
  use Ecto.Migration

  def change do
    alter table("Virus") do
      modify :attack_kind, :"\"ChipType\"", null: false
    end
  end
end
