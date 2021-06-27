local NewNpcsSpawnerRevs = GlobalEvent("NewNpcsSpawnerRevs")
function NewNpcsSpawnerRevs.onStartup()
	
	Game.createNpc('tom', Position(32359, 32233, 7))
	

	
	return true
end


NewNpcsSpawnerRevs:register()
