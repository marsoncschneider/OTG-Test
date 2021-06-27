function question(player, var)
	local offers = {{11,12,13,14}, {21,22,23,24}, {31,32,33,34}, {41,42,43,44}, {51,52,53,54}}
	local choices = offers[var]
	local window = ModalWindow(152, 'Sistema de apostas!', 'Selecione a quantidade:')
	window:addButton(100, "Apostar")
	window:addButton(102, "Cancel")
	window:addChoice(choices[1], "1000 gp (1k)")
	window:addChoice(choices[2], "10000 gp (10k)")
	window:addChoice(choices[3], "100000 gp (100k)")
	window:addChoice(choices[4], "1000000 gp (1kk)")
	window:sendToPlayer(player)
end

function jokey(horses, vencedores)
	for i = 1, 5 do
		horses[i]:remove()
	end
	
	if #vencedores >= 1 then
		local vencedor = vencedores[1]
		jokeywin[vencedor] = jokeywin[vencedor] + 1
		broadcastMessage("Corrida de cavalos: O cavalo "..vencedor.." "..HorseNames[vencedor].." venceu!", MESSAGE_EVENT_ADVANCE)
		if #vencedores >= 1 and #apostadores >= 1 then
			for i = 1, #apostadores do
				p = Player(apostadores[i])   
				local premios = {pBet1[getPlayerGUID(p)], pBet2[getPlayerGUID(p)], pBet3[getPlayerGUID(p)], pBet4[getPlayerGUID(p)], pBet5[getPlayerGUID(p)]}
				local valor = premios[vencedor]
				valor = valor * 2
				p:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Sua aposta no vencedor '..HorseNames[vencedor]..' foi: '..premios[vencedor]..' e seu premio: '..valor..'')
				doPlayerAddMoney(p, valor)
				p:teleportTo(pBetPos[getPlayerGUID(p)])
				p:setGhostMode(false)
			end	
			pBet1, pBet2, pBet3, pBet4,	pBet5, apostadores = {}, {}, {}, {}, {}, {}
		end
	end
end	

function jokeyRun(horses, pos, run, seq, vencedores, ganhou)	
	local nextpos = pos
	nextpos.x = nextpos.x + 1
	local cavalo = Creature(horses)
	if cavalo then
		cleanTilejokey(nextpos)
		local path = cavalo:getPathTo(nextpos, 0, 0, true, true)
		doMoveCreature(cavalo, path[1])
		if run == 7 and seq == 1 then
			if #apostadores >= 1 then
				for u = 1, #apostadores do
					player = Player(apostadores[u])
					player:setGhostMode(true)
					player:teleportTo(Position(1081, 900, 5))
				end
			end
		end
		if run == 14 then
			table.insert(vencedores, seq)
			if #vencedores == 1 then
				cavalo:getPosition():sendMagicEffect(CONST_ME_TUTORIALARROW)	
			end
		end
	end
end	

function cleanTilejokey(position)
	local creature = Creature(getTopCreature(position).uid)
	if creature then
		creature:teleportTo(Position(1081, 900, 5))
	end
	local items = position:getTile():getItems()
	if items then
		for i = 1, #items do
			local item = items[i]
			item:remove()
		end
	end
end


local jockeyStartup = GlobalEvent("jockeyStartup")
function jockeyStartup.onStartup()
	print('[BET ON HORSES]')
	pBet1, pBet2, pBet3, pBet4, pBet5, pBetPos, apostadores, jokeywin = {}, {}, {}, {}, {}, {}, {}, {0,0,0,0,0}
	HorseNames = {'Chico', 'Pe de Pano', 'Zangado', 'Pocoyo', 'Mustang'}
	Game.loadMap('data/world/betonhorses/horserace.otbm')
	
	addEvent(function() Game.createNpc("Alec", Position(1069, 906, 5)) end, 10 * 1000)
	return true
end
jockeyStartup:register()

local jokeyGlobal = GlobalEvent("jokeyGlobal")
function jokeyGlobal.onThink(interval)
	print("jokeyGlobal")
	if #apostadores >= 1 then
		for i = 1, #apostadores do
			player = Player(apostadores[i])
			pBetPos[getPlayerGUID(player)] = player:getPosition()
			player:setGhostMode(true)
			player:teleportTo(Position(1064, 900, 5))
		end
	end
    
	local positions = {Position(1066, 904, 5), Position(1066, 902, 5), Position(1066, 900, 5), Position(1066, 898, 5), Position(1066, 896, 5)}
	local horses = {Game.createNpc("jokey1", positions[1]), Game.createNpc("jokey1", positions[2]), Game.createNpc("jokey1", positions[3]), Game.createNpc("jokey1", positions[4]), Game.createNpc("jokey1", positions[5])}
	vencedores = {}
	
	local spectators = Game.getSpectators(Position(1074, 901, 5), false, true, 7, 7, 5, 5)
	for i = 1, #spectators do
		for p = 1, 5 do
			spectators[i]:say(''..HorseNames[p]..'', TALKTYPE_MONSTER_SAY, false, spectators[i], positions[p])
		end
	end
	
	for i = 1, 5 do
		horses[i]:setDirection(DIRECTION_EAST)
		doChangeSpeed(horses[i], getCreatureBaseSpeed(horses[i]))
		local color = {114, 0, 113, 107, 79}
		horses[i]:setOutfit({lookBody = color[i], lookAddons = 2, lookType = 128, lookHead = 97, lookMount = 392, lookLegs = 95, lookFeet = 115})
	end
	
	local speed, delay = 450, 1
	for run = 1, 14 do
		local xa, xb = -15, 15
		for h = 1, 5 do
			speed = speed + math.random(xa, xb)
			addEvent(jokeyRun, speed*delay, horses[h].uid, positions[h], run, h, vencedores)
		end
		delay = delay + 1
	end
	addEvent(jokey, (450*delay)+1000, horses, vencedores)   
	return true
end
jokeyGlobal:interval(120000)
jokeyGlobal:register()

local jokeyModal = CreatureEvent("jokeyModal")
function jokeyModal.onModalWindow(player, modalWindowId, buttonId, choiceId)
	local title = "Sistema de apostas!"
	
	if pBet1[getPlayerGUID(player)] == nil then
		pBet1[getPlayerGUID(player)], pBet2[getPlayerGUID(player)], pBet3[getPlayerGUID(player)], pBet4[getPlayerGUID(player)], pBet5[getPlayerGUID(player)] = 0,0,0,0,0
	end
	
	if buttonId == 100 and choiceId > 0 then
		local valores = {1000, 10000, 100000, 1000000}
		if choiceId >= 1 and choiceId < 6 then
			question(player, choiceId)
		elseif choiceId >= 11 and choiceId < 20 and getPlayerMoney(player) >= valores[choiceId-10] then
			doPlayerRemoveMoney(player, valores[choiceId-10])
			pBet1[getPlayerGUID(player)] = pBet1[getPlayerGUID(player)] + valores[choiceId-10]
		elseif choiceId >= 21 and choiceId < 30 and getPlayerMoney(player) >= valores[choiceId-20] then
			doPlayerRemoveMoney(player, valores[choiceId-20])
			pBet2[getPlayerGUID(player)] = pBet2[getPlayerGUID(player)] + valores[choiceId-20]
		elseif choiceId >= 31 and choiceId < 40 and getPlayerMoney(player) >= valores[choiceId-30] then
			doPlayerRemoveMoney(player, valores[choiceId-30])
			pBet3[getPlayerGUID(player)] = pBet3[getPlayerGUID(player)] + valores[choiceId-30]
		elseif choiceId >= 41 and choiceId < 50 and getPlayerMoney(player) >= valores[choiceId-40]then
			doPlayerRemoveMoney(player, valores[choiceId-40])
			pBet4[getPlayerGUID(player)] = pBet4[getPlayerGUID(player)] + valores[choiceId-40]
		elseif choiceId >= 51 and choiceId < 60 and getPlayerMoney(player) >= valores[choiceId-50] then
			doPlayerRemoveMoney(player, valores[choiceId-50])
			pBet5[getPlayerGUID(player)] = pBet5[getPlayerGUID(player)] + valores[choiceId-50]	
		end
	end
	
	local bid1, bid2, bid3, bid4, bid5 = pBet1[getPlayerGUID(player)], pBet2[getPlayerGUID(player)], pBet3[getPlayerGUID(player)], pBet4[getPlayerGUID(player)], pBet5[getPlayerGUID(player)]
	local totalcorridas = jokeywin[1]+jokeywin[2]+jokeywin[3]+jokeywin[4]+jokeywin[5]
	
	local message = "Estatisticas: \nCorridas atualmente realizadas: "..totalcorridas.."\n1: "..HorseNames[1].." > "..jokeywin[1].." Vitorias: "..string.format("%.0f", jokeywin[1]/totalcorridas*100).."%\n2: "..HorseNames[2].." > "..jokeywin[2].." Vitorias: "..string.format("%.0f", jokeywin[2]/totalcorridas*100).."%\n3: "..HorseNames[3].." > "..jokeywin[3].." Vitorias: "..string.format("%.0f", jokeywin[3]/totalcorridas*100).."%\n4: "..HorseNames[4].." > "..jokeywin[4].." Vitorias: "..string.format("%.0f", jokeywin[4]/totalcorridas*100).."%\n5: "..HorseNames[5].." > "..jokeywin[5].." Vitorias: "..string.format("%.0f", jokeywin[5]/totalcorridas*100).."%\n\nEscolha seu cavalo:\n(Gold disponivel: "..getPlayerMoney(player)..")"
	
	local window = ModalWindow(152, title, message)
	window:addChoice(1, "1: "..HorseNames[1].." - Gold: "..bid1.."")
	window:addChoice(2, "2: "..HorseNames[2].." - Gold: "..bid2.."")
	window:addChoice(3, "3: "..HorseNames[3].." - Gold: "..bid3.."")
	window:addChoice(4, "4: "..HorseNames[4].."  - Gold: "..bid4.."")
	window:addChoice(5, "5: "..HorseNames[5].."  - Gold: "..bid5.."")
	window:addButton(100, "Apostar")
	window:addButton(101, "Ok")
	window:addButton(102, "Cancel")
	
	if buttonId == 102 or buttonId == 101 then
		player:unregisterEvent('jokey')
	else
		window:sendToPlayer(player)
	end
		
	local wager = bid1+bid2+bid3+bid4+bid5
	if not table.contains(apostadores, player.uid) and wager > 0 then
		table.insert(apostadores, player.uid)
	end
end
jokeyModal:register()

local jokeyStepin = MoveEvent()
function jokeyStepin.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	
	if table.contains(apostadores, player.uid) then
		player:teleportTo(fromPosition)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Aguarde ate a corrida comecar.')
	else
		player:teleportTo(player:getTown():getTemplePosition())
	end
	
	return true
end
jokeyStepin:aid(29503)
jokeyStepin:register()