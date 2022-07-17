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

ncp_fields = ~W(name description cost color custom conflicts)a

ncps = [
	{"Analyze", description: "You may use an Attack Action to make an Info check against the AC of a target. On success, you learn the current HP and AC values of your target as well as the values of one of its Stats and the three Skills related to it. This program can be activated once per round."},

	{"Collect", description: "At the end of combat, you may increase your Busting Level by your Mind. This program also allows you to always receive Battlechips from Mystery Data that does not contain Viruses."},

	{"Hotswap", description: "While you have this Part equipped, you may freely modify the Parts installed in your Navi Customizer and your equipped folder without entering a Buffering Period."},

	{"Port Forward", description: "After all combat participants have rolled their Initiatives, you may choose to swap your Initiative with that of a willing target. Should you tie with another member of the Initiative Order after this, your Perception is used for the tiebreaker."},

	{"Foresight", description: "When you are targeted with an attack that you have been damaged by since the end of your last turn, you may increase your AC against all Attack Rolls of this attack by half your Info. This program can be activated a number of times no greater than your Mind per encounter."},

	{"Custom+1", description: "The number of Battlechips you may use per round is increased by 1 (maximum 3)."},

	{"Preallocate", description: "When you use a Delayed Action, the duration during which it can be triggered becomes a number of rounds equal to your Mind."},

	{"Untrap", description: "When a Trap type attack that would damage you is triggered you may enter a Contested Tech Roll with the one who set the trap. On success, the trap and all its effects are negated. You may use this program a number of times no greater than your Mind per encounter. This program also allows you to immediately remove Viruses from Mystery Data you access."},

	{"Point Blank", description: "When you make an attack with a Battlechip that has a range of Far or greater against a target within your Close range, you may reroll a number of damage dice no greater than your Mind that result in a 1 or 2 once and keep the higher of the two results for each.", conflicts: ["Blind Mode"]},

	{"Virtualization", description: "At the start of an encounter, you may select one target on the field. Your Buster is replaced by the Buster of that target until the end of combat, mimicking its range, area of effect, type, and damage. This program counts the BusterUPs of your target and your Navi Customizer Programs when determining the damage your copied Buster attack deals.", conflicts: ["Break Charge"]},

	{"Undershirt", description: "When you receive damage that would reduce you to 0 HP, you are instead reduced to 1 HP. This program can be activated once per encounter."},

	{"Collision Avoidance", description: "After attacks made against you are fully resolved, you may choose to make a free Move Action if the attack dealt any damage to you.", conflicts: ["Afterimage"]},

	{"Armor+2", description: "Your AC is increased by 2 (maximum 10)."},

	{"Move+1", description: "On each of your turns, you are allowed to make one additional Move Action (maximum 2)."},

	{"Attack+1", description: "When you make a Buster attack, multiply the Stat related to your Buster's to-hit Skill by your level of installed Attack+ parts (maximum 10). Then, add this amount to the result of a single damage roll of your choice."},

	{"HP+2", description: "You may increase the amount of HP you gain from each of your HP Memories by the level of installed HP+ Parts (maximum 10)."},

	{"WeaponLevel+1", description: "When you make a Buster attack, add one damage die to each damage roll you make as part of the attack."},

	{"Type Compatible", description: "When you make an attack with a Battlechip that deals damage of your Element, you may increase the damage this chip deals to a single target by your highest Recommended Skill. For Null Navis, use the Skill associated with your Buster. This program can be activated once each time you use a Battlechip.", conflicts: ["Balance", "Brute Force"]},

	{"Charge Shot", description: "When you make a damage roll as part of a Buster attack, you may select a number of rolled dice no greater than your Body that resulted in a 1 or a 2 and reroll them. When you do, keep the higher of the two rolled results.", conflicts: ["Break Charge"]},

	{"Blind Mode", description: "You are no longer affected by the Blind Status, and while you are within Close range of Invisible targets you may ignore the increase to AC these targets receive from the Status.", conflicts: ["Point Blank"]},

	{"Overclock", description: "When your current HP is less than half of your maximum HP, you may increase the result of all your Attack Rolls by your Spirit."},

	{"Blockchain", description: "While willing targets of your choice are within your Close range, these targets may use the highest Body value of all targets within this group when determining their AC."},

	{"Memory Leak", description: "When you receive damage during combat, the space your occupy becomes terrain to match your Element. Fire Navis set terrain to Lava, Aqua Navis set terrain to Sea, Elec Navis set terrain to Magnet, Wood Navis set terrain to Grass, Break Navis set terrain to Metal, and Recovery Navis set terrain to Holy. Other Elements return panels to normal terrain.", conflicts: ["Trailblazer"]},

	{"Mega+1", description: "The number of Mega class Battlechips that you are allowed to place in a folder is increased by 1 (maximum 3)."},

	{"Spirit+2", description: "At the start of each encounter, your current and maximum number of Spirit Points is increased by 2 (maximum 6)."},

	{"Code Injection", description: "When a Delayed Action you make is triggered you may select a number of willing targets within your Close range no greater than your Spirit. Each of these targets may then immediately make a number of free Move Actions no greater than your Mind before the effect of your Delayed Action takes place."},

	{"Multithread", description: "When a target within your Far range makes a Skill check outside of combat, you may make a Charm check of an equal DC. If you succeed, you increase the result of this target's Skill check by your Spirit."},

	{"Clear", description: "At the start of your turn, you may remove a single Status from yourself. This program can be activated a number of times per encounter no greater than your Spirit."},

	{"Operator Overload", description: "At any time during combat, you may expend Spirit Points to increase any of your Skills at a rate of 1 Spirit Point per Skill Point. At the end of each of your turns after you activate this program, you must roll 1d20. If the result is less than double the number of Spirit Points you've expended to increase your Skills, you lose the ability to activate this program as well as all benefits it has provided you and become Exhausted until the end of combat. You may not increase a Skill past its usual maximum value using this program."},

	{"Fortify", description: "The effects of the Shield and Barrier Statuses are bolstered tby this program. When you gain the Barrier Status, you may increase the amount of damage the barrier can absorb before fading by one tenth of your maximum HP. When you gain the Shield Status, the shield will further reduce damage from incoming attacks by a number of damage dice equal to half your Spirit (minimum 0).", conflicts: ["First Barrier", "Shield", "Reflect"]},

	{"Duel", description: "You may force a target within your Far range to enter a Contested Valor Roll with you. On success, this target becomes unable to make attacks without targeting you. This program can be activated once per round."},

	{"Regen", description: "When you are below half of your maximum HP, you may use an Attack Action to roll a number of hit dice equal to your Spirit and recover the result plus your Endurance in HP. This program can be activated once per encounter."},

	{"Bodyguard", description: "When a target within your Near range is damaged by an attack that does not target you, you may choose to take half the damage of the attack yourself andce the damage the target makes by the same amount. This program can be activated a number of times per encounter no greater than your Body.", conflicts: ["Vengeance"]},

	{"Adaptation", description: "When you take damage from your Weakness, you may reduce the number of extra damage dice rolled by half. Attacks you are Weak to must always deal at least one extra die of damage to you."},

	{"Super Armor", description: "You automatically succeed all Skill checks you make to resist being Pushed, Pulled, or Staggered by attacks.", conflicts: ["Status Guard"]},

	{"Status Guard", description: "When an attack forces you to make a Skill check to resist becoming Blinded, Confused, Locked, or Paralyzed, you may make this check with advantage.", conflicts: ["Super Armor"]},

	{"HP+5", description: "Increase your maximum HP by five times the maximum value of one of your hit dice (maximum 10)."},

	{"Armor+5", description: "Your AC is increased by 5 (maximum 10)."},

	{"Shield", description: "You are able to immediately adopt the Shield Status when you are targeted by an attack. This shield removes a number of dice equal to your Body from the damage roll of attacks that deal a single hit or half this amount from attacks that deal multiple hits. After the attack resolves, you lose the Shield Status. This program can be activated a number of times per round no greater than half your Spirit rounded up.", conflicts: ["Afterimage", "Encampment", "Fortify", "Reflect"]},

	{"Break Charge", description: "When you make a Buster attack, you may immediately remove the Shield Status from your targets on hit and force them to make a Contested Tech Roll against you. On success, you may lower your target's AC by 2 until the start of your next turn. This effect may only be applied to a target once at a time. This program can be activated a number of times per encounter no greater than your Spirit.", conflicts: ["Charge Shot", "Virtualization"]},

	{"Balance", description: "When you deal damage to a target, you may select a number of rolled damage dice no greater than your Body and sacrifice an amount of HP equal to half their combined maximum result. After this, you may increase the result of each die you selected to its maximum possible result.", conflicts: ["Brute Force", "Type Compatible"]},

	{"Followthrough", description: "When you make an attack that deals a single hit with a range of Close, you may choose one target within Close range of any of your initial targets that is unaffected by the attack. This target immediately takes damage equal to half the result of this attack's damage roll.", conflicts: ["Splash"]},

	{"Bladerun", description: "When you deal damage with a Sword Element Battlechip, you may immediately make one free Move Action.", conflicts: ["Sneakrun", "Warp"]},

	{"Gutsy", description: "When you make an attack against a target within Close range, you may force that target to make a Contested Strength Roll against you. On success, the target is Pushed back one space from your Close range to your Near range."},

	{"Vengeance", description: "When a willing target takes damage during combat, you may either make a free Move Action or a Buster attack against your target's attacker. This program can be activated once per round.", conflicts: ["Bodyguard", "Retaliate"]},

	{"Hyperthread", description: "When you make an attack with a Battlechip that deals a single hit, you may halve the damage this attack deals in order to add a second hit to it. This second hit may be aimed at different targets within range."},

	{"Man in the Middle", description: "While you are within Close range of two or more targets that have dealt damage to you during your current encounter, you may choose to make Attack Rolls against them with advantage. If you do, these targets may also make Attack Rolls against you with advantage."},

	{"SIGKILL", description: "When you delete a target with an attack, you may immediately repeat this attack against a new target of your choice without making another Attack Action or using another Battlechip. Each time you use this program, your AC is reduced by 2 until the start of your next turn."},

	{"Attack+3", description: "When you make a Buster attack, multiply the Stat related to your Buster's to-hit Skill by your level of installed Attack+ parts (maximum 10). Then, add this amount to the result of a single damage roll of your choice."},

	{"Reflect", description: "You are able to immediately adopt the Shield Status when you are targeted by an attack. This shield removes a number of dice equal to half your Body rounded up from the damage roll of attacks that deal a single hit or half this amount from attacks that deal multiple hits. After the attack resolves, you lose the Shield Status and may make a damage roll using all the dice you removed from the attack against your attacker. This program can be activated a number of times per round no greater than half your Spirit rounded up.", conflicts: ["Afterimage", "Encampment", "Fortify", "Shield"]},

	{"Trailblazer", description: "When you move off of a space, you transform that space into terrain that matches your Element. Fire leaves behind Lava, Aqua leaves behind Ice, Elec leaves behind Magnet, and Recovery leaves behind Holy. Other Elements leave behind normal terrain."},

	{"Proxy", description: "When you use a Battlechip with a range of Self, you may instead use it on a willing target of your choice."},

	{"Lock On", description: "At the start of your turn, you may choose to sacrifice all your remaining Move Actions in order to make your next attack with advantage."},

	{"First Barrier", description: "At the start of combat, you may adopt the Barrier status. This barrier can absorb 5 damage before fading.", conflicts: ["Afterimage", "Encampment", "Fortify"]},

	{"Pain Prolonger", description: "When you apply a Blight status to a target, you may increase the duration of that Blight by 1 round."},

	{"Torment", description: "When you make a Contested Roll against a target or force it to make a Skill check to inflict a Status on it, you may increase the result of your roll or the DC of the check by the Stat related to the Skill used to determine your result or the DC of the check. This program can be activated once per round after dealing damage with an attack that inflicts a Status."},

	{"Support Change", description: "At any time during your turn, you may swap positions on the field with a willing target. After this, you may grant it one of your Attack Actions to immediately use. This program can be activated a number of times no greater than your Spirit per encounter."},

	{"Splash", description: "When you deal damage with a Battlechip that only affects one target, you may choose up to two targets within that target's Close range and deal the damage of your attack to them as well. This program can be activated once per round.", conflicts: ["Followthrough"]},

	{"Trojan Warfare", description: "When you use Summon type Battlechips, there is no limit to the number of turns a summoned Virus may remain on the field. It will not be removed from battle until its HP reaches 0."},

	{"Custom+2", description: "The number of Battlechips you may use per round is increased by 2 (maximum 3)."},

	{"Execution", description: "When you delete a target, you recover an amount of HP equal to your Affinity."},

	{"Brute Force", description: "When you make Attack Rolls, you may choose to reduce the result by up to your Spirit. On hit, you may increase the result of your damage roll by double the amount you reduced your Attack Roll. You must decide the amount you reduce an Attack Roll by before you make it.", conflicts: ["Balance", "Type Compatible"]},

	{"Sneakrun", description: "When you make Move Actions, you may reposition yourself to the opposite side of a target or construct within your Close range if that space is unoccupied instead of making your Move Action as normal.", conflicts: ["Bladerun", "Warp"]},

	{"Playback", description: "When you are damaged by an attack, you may make a Tech Check with a DC equal to half the damage you received from the attack. On success, you may use your next Attack Action to repeat the attack. This program may be activated once per round."},

	{"Finesse", description: "When you make Strength Checks or Contested Strength Rolls during combat, you may increase the result of your roll by your Agility instead of your Strength. When you make Info Checks or Contested Info Rolls during combat, you may increase the result of your roll by your Perception instead of your Info. This program cannot be activated for Attack Rolls."},

	{"Encampment", description: "You may occupy the same space as any construct. While you do, your AC is increased by 2, attacks that are made against you that miss deal their damage to the construct you share a space with, and attack that hit you have their damage split equally between you and this construct. If you receive Break Element damage, the construct is immediately destroyed and you receive the damage from the attack as normal. This program can be activated a number of times per encounter no greater than your Body.", conflicts: ["First Barrier", "Shield", "Reflect"]},

	{"Retaliate", description: "When you receive damage from an attack, you may enter a Contested Agility Roll with your attacker. On success, you may make a free Buster attack against your target. This program can be activated a number of times no greater than your Body per encounter.", conflicts: ["Bodyguard", "Vengeance"]},

	{"Afterimage", description: "When you would receive damage from an attack, you may choose to make an Agility Check with DC equal to the result of the Attack Roll made against you. On success, you may negate this damage and make a free Move Action. Otherwise, you receive half the damage you normally would. This program cannot be used against attacks that do not make Attack Rolls. This program can be activated a number of times no greater than your Spirit per encounter.", conflicts: ["First Barrier","Shield", "Reflect"]},

	{"Floatshoes", description: "You may choose whether or not you are affected by terrain you occupy or move onto during combat."},

	{"Warp", description: "When you deal damage to a target, you may choose to immediately reposition yourself onto any unoccupied space within its Near range. This program can be activated a number of times no greater than your Body per encounter.", conflicts: ["Bladerun", "Sneakrun"]}
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
  #raise "Rollback"
end)
