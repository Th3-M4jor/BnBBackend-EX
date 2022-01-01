# Script for updating the database. You can run it as:
#
#     mix run priv/repo/gen_chip_cr.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBackend.Repo.insert!(%ElixirBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Changeset
alias ElixirBackend.{LibObj.Battlechip, LibObj.Virus, Repo}

viruses = Repo.all(Virus)
chip_cr_list = for virus <- viruses, [_, drop] <- virus.drops, not String.contains?(drop, "Zenny") do
  {drop, virus.cr}
end |> Enum.sort() |> Enum.dedup_by(fn {chip, cr} -> chip end)

IO.inspect(chip_cr_list, pretty: true)

Enum.each(chip_cr_list, fn {chip, cr} ->
  Repo.get_by!(Battlechip, name: chip)
  |> change(%{cr: cr})
  |> Repo.update!()
end)
