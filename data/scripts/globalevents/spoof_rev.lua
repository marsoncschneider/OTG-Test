local checkSpoofCount = GlobalEvent("checkSpoofCount")

local function checkSpoofCountRun()
	--print('BackgroundWorker: Spoof')
	
	local auxTable = {}
	local spoofGuids = {464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488}
	spoofPlayers = Game.getPlayerCount() + (configManager.getNumber(configKeys.SPOOF_GAIN) * Game.getPlayerCount())
	local realPlayers = 0
	local players = Game.getPlayers() --aqui checaremos se há algum char exited
	local contagem2 = 0
	for _, online in ipairs(Game.getPlayers()) do
		if online:isPlayer() then
		contagem2 = contagem2 + 1
		end
	end
	
	--print("DEBUG", contagem2)
	local registros = db.storeQuery('SELECT `player_id` FROM `players_online`')      
	
	if registros ~= false then
		repeat	
			local player_id = result.getNumber(registros, 'player_id')
			table.insert(auxTable, player_id)
			realPlayers = realPlayers + 1
		until not result.next(registros)
		result.free(registros)
	end
	
	if spoofPlayers > realPlayers then
		--print("tentarei inserir um registro na DB")
		--passo 1.. checar se spoof nao está na tabela
		for i = 1, #spoofGuids do
			local spoofId = spoofGuids[i]
			
			
			if not table.contains(auxTable, spoofId) then
				
				db.query("INSERT INTO `players_online` (`player_id`) VALUES (".. spoofId ..") ON DUPLICATE KEY UPDATE `player_id` = ".. spoofId)
				--print("Inseri na tabela dos players online, BOB ESPONJA")
				addEvent(checkSpoofCountRun, 1000)
				return true
			else --aqui tentamos criar um player entre os spoofs, porem como ele já estava online > aproveitar para 
			--DAR Ou REMOVER LEVEL --o ot servlist check apenas o level
			--dar ou remover skill (somente quando for removido level)
			local var = math.random(0, 100)
			if var > 98 then
			var =  math.random(0, 1)
			db.query('UPDATE `players` SET `level` = level + '..var..' WHERE `id` = ' .. spoofId .. '')
			end
			end
			
			
			
		end
	else -- algum player deslogou entao tem mais spoofs do que deveria ter
	local rand = math.random(1, #spoofGuids)
	local winner = spoofGuids[rand]
	db.query("DELETE FROM `players_online` WHERE player_id = "..winner.."")
	if spoofPlayers > 0 and spoofPlayers ~= realPlayers then
	addEvent(checkSpoofCountRun, 5000)
	end
	return true
	end

	
	

	
end

function checkSpoofCount.onThink(interval)

checkSpoofCountRun()

	return true
end
print('Initialization: Spoof Background Worker - OK')
spoofPlayers = 0
checkSpoofCount:interval(60000)
checkSpoofCount:register()
