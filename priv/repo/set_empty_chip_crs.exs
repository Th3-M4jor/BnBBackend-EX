# Script for updating all zero CR chips in the database. You can run it as:
#
#     mix run priv/repo/set_empty_chip_crs.exs
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

chips = [
  {"AirSpin", 4},
  {"AirSpin2",9},
  {"AirSword",10},
  {"AntiDamage", 10},
  {"AreaGrab",1},
  {"Attack+1",1},
  {"Barrier",2},
  {"Blinder",1},
  {"Counter",7},
  {"CrackShot",3},
  {"CrossGun",3},
  {"Barrier10",8},
  {"BronzeFist",4},
  {"BubbleWrap",2},
  {"DoubleShot",8},
  {"EnergyBomb",6},
  {"GrassStage",3},
  {"GutsStraight",6},
  {"Geddon",6},
  {"GrassSeed",2},
  {"GutsPunch",3},
  {"HolyPanel",13},
  {"IceWall",6},
  {"Lance",11},
  {"LavaSeed",9},
  {"MagStage",8},
  {"PanelReturn",2},
  {"LavaStage",10},
  {"Maelstrom",4},
  {"Panic",4},
  {"Pawn",6},
  {"RockCube",1},
  {"RockWall",5},
  {"SeaSeed",4},
  {"ShotGun",1},
  {"SilverFist",9},
  {"Spreader",4},
  {"StepSword",7},
  {"Tornado",7},
  {"TyphoonDance",2},
  {"AirShot",1},
  {"WindRack",5},
  {"Vulcan",2},
  {"TopSpin2",13},
  {"V-Gun",2},
  {"Vulcan2",8},
  {"AdamantBody",16},
]

Enum.each(chips, fn {chip, cr} ->
  Repo.get_by!(Battlechip, name: chip)
  |> change(%{cr: cr})
  |> Repo.update!()
end)
