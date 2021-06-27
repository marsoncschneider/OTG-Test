local fieryHearts = CreatureEvent("fieryHearts")
function fieryHearts.onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	print('evento death')
end
fieryHearts:register()
