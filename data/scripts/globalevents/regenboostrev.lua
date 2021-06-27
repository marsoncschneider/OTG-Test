function regenBoostClean()
	for i = 1, #memoryBoostG do
		regenBoost(memoryBoostG[i], i)
	end
	addEvent(regenBoostClean, 5 * 60 * 1000) -- checar a cada 5 minutos as storages .. Pode ser alterado para a cada 10 minutos, 30 minutos, 60 minutos
end


local regenBoostStartup = GlobalEvent("regenBoostStartup")
function regenBoostStartup.onStartup()
	-- Marson(28.06.2020 21:27)
	print('[REGEN BOOST] CARREGADO')
	-- Funcionamento: O sistema fará um registro do player no login e no logout através de uma tabela com regen espeficicada
	-- Loop unico dando a regeneraçao para players da tabela sem processos adidionais
	memoryBoostG, memoryBoostH, memoryBoostM = {}, {}, {}
	addEvent(regenBoostClean, 1 * 60 * 1000)
	return true
end
regenBoostStartup:register()

function regenBoost(playerGuid, seq)
	local player = Player(playerGuid)
	if player then
	
	local check = getPlayerStorageValue(player, 25896) - os.time()
	
	if table.contains(memoryBoostG, playerGuid) then
		if check <= 0 then
			table.remove(memoryBoostG, seq)
		end
	else
		if check > 0 then
			table.insert(memoryBoostG, playerGuid)
			local vocation = player:getVocation()
			memoryBoostH[playerGuid] = vocation:getHealthGainAmount()
			memoryBoostM[playerGuid] = vocation:getManaGainAmount()
			
		end
	end
		
	end
end


local regenBoostGlobal = GlobalEvent("regenBoostGlobal")

function regenBoostGlobal.onThink(interval)
	
	for i = 1, #memoryBoostG do
		local guid = memoryBoostG[i]
		local player = Player(guid)
		if player then
		local condition = player:getCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT)
		if not condition then
			player:feed(60)
		end
			--
		else
			table.remove(memoryBoostG, i)
		end
	end
	
	return true
end
regenBoostGlobal:interval(60000)
regenBoostGlobal:register()


