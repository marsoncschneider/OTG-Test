local config = {
	[0] = {
		--club, coat
		items = {{2382, 1}, {2650, 1}},
		--container rope, shovel, red apple
		container = {{2120, 1}, {2554, 1}, {2674, 2}}
	},
	
	[1] = {
		--equipment spellbook, wand of vortex, magician's robe, mage hat, studded legs, leather boots, scarf
		items = {{2175, 1}, {2190, 1}, {8819, 1}, {8820, 1}, {2468, 1}, {2643, 1}, {2661, 1}},
		--container platinum coin, rope, shovel, mana potion
		container = {{2152, 20}, {7620, 5}, {18559, 1}}
	},
	[2] = {
		--equipment spellbook, snakebite rod, magician's robe, mage hat, studded legs, leather boots scarf
		items = {{2175, 1}, {2182, 1}, {8819, 1}, {8820, 1}, {2468, 1}, {2643, 1}, {2661, 1}},
		--container platinum coin, rope, shovel, mana potion
		container = {{2152, 20}, {7620, 5}, {18559, 1}}
	},
	[3] = {
		--equipment dwarven shield, 5 spear, ranger's cloak, ranger legs scarf, legion helmet
		items = {{2525, 1}, {2389, 5}, {2660, 1}, {8923, 1}, {2643, 1}, {2661, 1}, {2480, 1}},
		--container platinum coin, rope, shovel, health potion, mana potion
		container = {{2152, 20}, {7618, 5}, {7620, 5}, {18559, 1}}
	},
	[4] = {
		--equipment dwarven shield, steel axe, brass armor, brass helmet, brass legs scarf
		items = {{2525, 1}, {8601, 1}, {2465, 1}, {2460, 1}, {2478, 1}, {2643, 1}, {2661, 1}},
		--container platinum coin, jagged sword, daramian mace, rope, shovel, health potion, mana potion
		container = {{2152, 20}, {8602, 1}, {2439, 1}, {7618, 5}, {7620, 5}, {18559, 1}}
	}
	
}


local firstItems = CreatureEvent("firstItems")

function firstItems.onLogin(player)
	
	if player:getLastLoginSaved() == 0 then
		
		local backpack = player:addItem(1987)
		if not backpack then
			return true
		end
				
		local targetVocation = config[player:getVocation():getId()]
		if not targetVocation then
			return true
		end
		
		for i = 1, #targetVocation.items do
			player:addItem(targetVocation.items[i][1], targetVocation.items[i][2])
		end
		for i = 1, #targetVocation.container do
			backpack:addItem(targetVocation.container[i][1], targetVocation.container[i][2])
		end
		
	end
	
	return true
end
firstItems:register()
