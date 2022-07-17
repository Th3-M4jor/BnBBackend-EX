defmodule ElixirBackend.Repo.Migrations.AddOban do
  use Ecto.Migration

  def up, do: Oban.Migrations.up(version: 11, prefix: "oban_jobs")

  def down, do: Oban.Migrations.down(prefix: "oban_jobs")

end
