# Script for populating the database. You can run it as:
#
#     mix run priv/repo/update/ncps.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBackend.Repo.insert!(%ElixirBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Changeset
alias ElixirBackend.{LibObj.NCP, Repo}

ncp_fields = ~W(name description cost color custom)a

ncps = [
  {"Shield", cost: 56}
]

Repo.transaction(fn ->
  Enum.each(ncps, fn {ncp_name, changes} ->
    NCP.validate_changeset!(changes)
    changes = Map.new(changes)
    change_set = Repo.get_by!(NCP, name: ncp_name)
    |> cast(changes, ncp_fields)
    true = change_set.valid?
    Repo.update!(change_set)
  end)
  raise "Rollback"
end)
