defmodule ElixirBackend.Repo.Migrations.VirusUniqueName do
  use Ecto.Migration

  def change do
    create index("Virus", [:name], unique: true)
  end
end
