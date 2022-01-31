defmodule ElixirBackend.Repo.Migrations.NotNullDesc do
  use Ecto.Migration

  def change do
    alter table("Battlechip") do
      modify :description, :text, from: :text, null: false
    end

    alter table("Virus") do
      modify :description, :text, from: :text, null: false
    end
  end
end
