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
	{"Attack+1", description: "You can use this chip as part of any Attack Action where you use another chip that does damage. When dealing damage using the chip paired with this one, you may add one damage die to each damage roll you make."},

	{"Binder", description: "You throw a Melody Virus to a target at range. This virus hops repeatedly on top of the target. Should the target be deleted before the Virus performs the listed number of hits, it will hop to a new target within its Near range to complete the attack."},

	{"Binder2", description: "You throw a Melody Virus to a target at range. This virus hops repeatedly on top of the target. Should the target be deleted before the Virus performs the listed number of hits, it will hop to a new target within its Near range to complete the attack."},

	{"BubbleCross", description: "Your Buster is replaced with a canister that launches pressurized water when you attack. This water explodes on contact with a target. If your attack hits, non-adjacent targets within Close range of your first target are also damaged."},

	{"Bubbler", description: "Your Buster is replaced with a canister that launches pressurized water when you attack. This water explodes on contact with a target. If your attack hits, the target one space behind it along the same line of fire is also damaged."},

	{"Bubble-V", description: "Your Buster is replaced with a canister that launches pressurized water when you attack. This water explodes on contact with a target. If your attack hits, targets in a V-shape diverging from your line of fire behind your target are also damaged."},

	{"CactusBall", description: "The head of a Cactikil Virus is spawned into your hand and you throw it forward in a line of your choice. At Close range, a single hit is dealt and the ball shatters. At Near range, this attack hits three times. At Far, this attack hits twice."},

	{"CactusBall2", description: "The head of a Cactikil Virus is spawned into your hand and you throw it forward in a line of your choice. At Close range, a single hit is dealt and the ball shatters. At Near range, this attack hits three times. At Far, this attack hits twice."},

	{"CrackBomb", description: "A bomb appears in your hand which you lob to a target at range. When the bomb reaches its target, it explodes and spreads to two other spaces adjacent to your initial target's. The affected area becomes Cracked terrain that requires an Endurance check of [DC 10 + Affinity] or become Staggered when moving across it."},

	{"CrossBomb", description: "A bomb appears in your hand which you lob to a target at range. When the bomb reaches its target, it explodes and the attack spreads to three non-adjacent spaces within Close range of your initial target."},

	{"Fan", description: "Gale force winds pick up around you and force every target within your Far range to make an Endurance check of [DC 10 + Charm] or be Pulled a number of spaces equal to your Body closer to you. This check repeats itself at the start of each of your turns for a number of rounds equal to your Spirit."},

	{"FireBurn", description: "You unlease intensely powerful flames in a line of your choice out to range. The force of the heat transforms the spaces along this line to Cracked terrain and affects all targets along the line. Targets moving across these spaces must make an Endurance check of [DC 10 + Affinity] or become Staggered."},

	{"FireBurn2", description: "You unlease intensely powerful flames in a line of your choice out to range. The force of the heat transforms the spaces along this line to Cracked terrain and affects all targets along the line. Targets moving across these spaces must make an Endurance check of [DC 10 + Affinity] or become Staggered."},

	{"HeatCross", description: "Your Buster is replaced with a canister of highly flammable material that combusts on impact with a target. If your attack hits, non-adjacent targets within Close range of your first target are also damaged."},

	{"HeatShot", description: "Your Buster is replaced with a canister of highly flammable material that combusts on impact with a tagret. If your attack hits, the target one space behind it along the same line of fire is also damaged."},

	{"Heat-V", description: "Your Buster is replaced with a canister of highly flammable material that combusts on impact with a tagret. If your attack hits, targets in a V-shape diverging from your line of fire behind your target are also damaged."},

	{"IronBody", description: "When you use this Battlechip, you become Paralyzed and Shielded for a number of rounds equal to half your Body. During this time, all damage you take is reduced by three quarters. You may end these effects at any point by taking a Move Action on your turn. If you suffer Break Element damage, all of these effects immediately end and you take damage as normal."},

	{"IronShell", description: "You bowl the curled shell of an Armadil down the field in a line of your choice out to range. Targets at the end of this line have three hits made against them instead of one."},

	{"IronShell2", description: "You bowl the curled shell of an Armadil down the field in a line of your choice out to range. Targets at the end of this line have three hits made against them instead of one."},

	{"LavaCannon", description: "Your arm transforms into a burning caldera that is able to capture nearby heat. You may absorb up to two spaces of Lava terrain within your Close range and revert that area to normal to increase the damage of this attack by 1d10 for each piece of terrain absorbed."},

	{"LilBomb", description: "A bomb appears in your hand which you lob to a target at range. When the bomb reaches its target, it explodes and spreads to two other spaces adjacent to your initial target's."},

	{"Needler", description: "This chip summons a Needler Virus on an unoccupied space within your Close range. On this turn and at the start of your turn for the next 3 rounds, the Needler fires projectiles in three non-adjacent lines using your Valor to hit."},

	{"Needler2", description: "This chip summons a Needler Virus on an unoccupied space within your Close range. On this turn and at the start of your turn for the next 3 rounds, the Needler fires projectiles in three non-adjacent lines using your Valor to hit."},

	{"Plasma", description: "This chip summons an EleBall Virus on an unoccupied space within your Close range. On this turn and each of your turns for the next 3 rounds, it makes an attack against all targets within its Close range."},

	{"Plasma2", description: "This chip summons an EleBall Virus on an unoccupied space within your Close range. On this turn and each of your turns for the next 3 rounds, it makes an attack against all targets within its Close range."},

	{"Pulsar", description: "You fire a pocket of noise in a line of your choice out to range. Should the pocket impact an object, it resonates with the frequency of the sound and spreads the attack to all targets within its Close range. Targets hit after an object is hit must make a Perception check of [DC 10 + Affinity] or suffer Blight (Wind) at 1d8 damage for 1d4 rounds."},

	{"Pulsar2", description: "You fire a pocket of noise in a line of your choice out to range. Should the pocket impact an object, it resonates with the frequency of the sound and spreads the attack to all targets within its Close range. Targets hit after an object is hit must make a Perception check of [DC 10 + Affinity] or suffer Blight (Wind) at 1d6 damage for 1d4 rounds."},

	{"ShotGun", description: "You load your Buster with a round of explosive ammo and fire it down a line of your choice. On impact with any target, this ammunition bursts. If your attack hits, the target one space behind it along the same line of fire is also damaged."},

	{"StoneBody", description: "When you use this Battlechip, you become Locked and Shielded for a number of rounds equal to half your Body. During this time, all damage you take is reduced by half. You may end these effects at any point by taking a Move Action on your turn. If you suffer Break Element damage, all of these effects immediately end and you take damage as normal."},

	{"TriArrow", description: "Your hand takes the shape of a mechanical bow that fires three arrows in a line of your choice, damaging a single target along it. On hit, targets must make an Agility check of [DC 10 + Perception] or suffer Blight (Sword) at 1d6 damage for 2 rounds."},

	{"TriSpear", description: "Your hand takes the shape of a mechanical bow that fires three spears in a line of your choice, damaging a single target along it. On hit, targets must make an Agility check of [DC 10 + Perception] or suffer Blight (Sword) at 1d8 damage for 2 rounds."},

	{"V-Gun", description: "You load your Buster with a round of explosive ammo and fire it down a line of your choice out to range. On impact with any target, this ammunition bursts. If your attack hits, targets in a V-shape diverging from your line of fire behind your target are also damaged."},

	{"Wind", description: "Gale force winds pick up around you and force every target within your Far range to make an Endurance check of [DC 10 + Charm] or be Pushed back a number of spaces equal to your Body. This check repeats itself at the start of each of your turns for a number of rounds equal to your Spirit."}
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
