# Script for updating the database. You can run it as:
#
#     mix run priv/repo/check_virus_stats.exs
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
for virus <- viruses do
  max_mind = virus.stats["mind"] * 4
  max_body = virus.stats["body"] * 4
  max_spirit = virus.stats["spirit"] * 4

  per = virus.skills[:per] || 0
  inf = virus.skills[:inf] || 0
  tch = virus.skills[:tch] || 0
  str = virus.skills[:str] || 0
  agi = virus.skills[:agi] || 0
  endr = virus.skills[:end] || 0
  chm = virus.skills[:chm] || 0
  vlr = virus.skills[:vlr] || 0
  aff = virus.skills[:aff] || 0

  if per > max_mind or inf > max_mind or tch > max_mind or str > max_body or agi > max_body or endr > max_body or chm > max_spirit or vlr > max_spirit or aff > max_spirit do
    IO.puts("#{virus.name} has too many skills")
  end
end
