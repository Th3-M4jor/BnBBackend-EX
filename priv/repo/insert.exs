# Script for populating the database. You can run it as:
#
#     mix run priv/repo/insert.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBackend.Repo.insert!(%ElixirBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Changeset
alias ElixirBackend.{LibObj.Battlechip, LibObj.NCP, LibObj.Virus, Repo}

#chip_fields = ~W(name elem skill range hits targets description effect effduration blight damage kind class custom cr median_hits median_targets)a

values = [
  {Battlechip, name: "Knight", elem: [:break, :object], range: :self, hits: "1-5",
    targets: "1", effect: [:Stagger], damage: {3,6}, kind: :summon, median_hits: 2.5, description: "Summons a Knight onto the field"},
]

Repo.transaction(fn ->
  Enum.each(values, fn {kind, fields} ->
    kind.validate_changeset!(fields)
    fields = Map.new(fields)
    valid_keys = kind.get_valid_keys()
    to_insert = cast(struct(kind), fields, valid_keys)
    true = to_insert.valid?
    Repo.insert!(to_insert)
  end)
  raise "Rollback"
end)
