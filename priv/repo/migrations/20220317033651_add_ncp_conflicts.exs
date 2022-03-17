defmodule ElixirBackend.Repo.Migrations.AddNcpConflicts do
  use Ecto.Migration

  def change do
    alter table("NaviCust") do
      add :conflicts, {:array, :string}
    end
  end
end
