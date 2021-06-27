local theDukeHealFireDamage = CreatureEvent("theDukeHealFireDamage")
function theDukeHealFireDamage.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	print('eu sou o hpchange')
	if primaryType == COMBAT_FIREDAMAGE then
		creature:addHealth(primaryDamage)
		primaryDamage = 0
	end
	
	if not Player(attacker.uid)then
	print(attacker:getName())
	end
	
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

theDukeHealFireDamage:register()
