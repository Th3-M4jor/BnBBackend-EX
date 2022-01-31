# Script for populating the database. You can run it as:
#
#     mix run priv/repo/update/chips.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBackend.Repo.insert!(%ElixirBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Changeset
alias ElixirBackend.{LibObj.Battlechip, Repo}

chip_fields = ~W(name elem skill range hits targets description effect effduration blight damage kind class custom cr median_hits median_targets)a

chips = [
	{"ZapRing2", description: "You shoot an electrified ring down the battlefield in a line out to range. On hit, the target must make an Affinity check of [DC 10 + Valor] or become Paralyzed until the start of your next turn."}
]

Repo.transaction(fn ->
  Enum.each(chips, fn {chip, changes} ->
    Battlechip.validate_changeset!(changes)
    changes = Map.new(changes)
    change_set = Repo.get_by!(Battlechip, name: chip)
    |> cast(changes, chip_fields)
    true = change_set.valid?
    Repo.update!(change_set)
  end)
  raise "Rollback"
end)
