# Script for listing all zero CR chips from the database. You can run it as:
#
#     mix run priv/repo/get_empty_chip_crs.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBackend.Repo.insert!(%ElixirBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query
alias ElixirBackend.{LibObj.Battlechip, Repo}

chips = Repo.all(from b in Battlechip, where: b.cr == 0)
for chip <- chips do
  IO.puts(chip.name)
end
