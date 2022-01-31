# Script for populating the database. You can run it as:
#
#     mix run priv/repo/update/viruses.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBackend.Repo.insert!(%ElixirBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Changeset
alias ElixirBackend.{LibObj.Virus, Repo}

virus_fields = ~W(name element hp ac stats skills drops description cr abilities damage dmgelem blight custom)a

viruses = [
  {"HardHead", skills: %{"VLR" => 7}}
]

Repo.transaction(fn ->
  Enum.each(viruses, fn {virus_name, changes} ->
    Virus.validate_changeset!(changes)
    changes = Map.new(changes)
    change_set = Repo.get_by!(Virus, name: virus_name)
    |> cast(changes, virus_fields)
    true = change_set.valid?
    Repo.update!(change_set)
  end)
  raise "Rollback"
end)
