local killWarmode = CreatureEvent("killWarmode")
function killWarmode.onKill(player, target)
    print("funcaoKill!!")
	if target:isPlayer() then
		--Aqui um atacante que faz parte da war matou alguem
		--Checar o guid do target, para ver de qual time ele é
		
		local checkteam = 0
		for b = 1, #warmodeteamA do
			if target:getGuid() == warmodeteamA[b] then
				checkteam = checkteam + 1
			end
			if player:getGuid() == warmodeteamA[b] then
				checkteam = checkteam + 1
			end
		end
		checkteam = 0
		for c = 1, #warmodeteamB do
			if target:getGuid() == warmodeteamB[c] then
				checkteam = checkteam + 1
			end
			if player:getGuid() == warmodeteamB[c] then
				checkteam = checkteam + 1
			end
		end
		if checkteam >= 2 then
			print('Matou player do mesmo time')
		end
		
		for i = 1, #warmodeKillAux do
			if target:getGuid() == warmodeKillAux[i] then
				print("um player que estava dentro da war, foi morto")
				for b = 1, #warmodeteamA do
					if target:getGuid() == warmodeteamA[b] then
						--dar 1 ponto pro time atacante
						warmodeDeathsT2 = warmodeDeathsT2 + 1 
					end
				end
				for c = 1, #warmodeteamB do
					if target:getGuid() == warmodeteamB[c] then
						--dar 1 ponto pro time atacante
						warmodeDeathsT1 = warmodeDeathsT1 + 1 
					end
					table.remove(warmodeKillAux, i)
				end
				
				endWarmode()
			end
		end
		
		
	end
	--print(currentWarId)
	--print(target)
	--print('truehistory', getGuildId(getPlayerGuildName(player)))
	if not delayTable then
		delayTable = {}
	end
	if not delayTable[target:getGuid()] then
		delayTable[target:getGuid()] = 0
	end
	
	if delayTable[target:getGuid()] < os.time() then
		
		if checkteam < 2 then
			db.query("INSERT INTO `guildwar_kills`(`killer`, `target`, `killerguild`, `targetguild`, `warid`, `time`) VALUES ('"..player:getName().."','".. target:getName().."',"..getGuildId(getPlayerGuildName(player))..","..getGuildId(getPlayerGuildName(target))..","..currentWarId..",".. os.time() ..")")
		end
		delayTable[target:getGuid()] = os.time()
		print('fiz o insert')
		else
		print('tentei insert mas deu locked')
	end
	--db.query("INSERT INTO `guild_wars`(`guild1`, `guild2`, `name1`, `name2`, `status`, `started`, `ended`) VALUES ("..challenger..","..challenged..",'"..challengerName.."','"..challengedName.."',1,".. os.time() ..", 0)")
	
	
	return true
end
killWarmode:register()




local modalWarmode = CreatureEvent("modalWarmode")
function modalWarmode.onModalWindow(player, modalWindowId, buttonId, choiceId)
	print('ONMODAL')
	if buttonId == 101 then
		player:unregisterEvent("modalWarmode")
		warvariables = {}
		return false
	end
	
	local guild = player:getGuild()
	if not guild then
		return player:sendTextMessage(MESSAGE_FAILURE, 'You need to belong to a guild.')
	end
	local guildId = guild:getId()
	local guildPlayers = {}
	
	
    if modalWindowId == 1840 then
		if buttonId == 105 then
			--entrar na war
			local contain = 0
			local temp = warmodecityPos[warmodeCidades[warmodetempcity].nome]
			if guildId == warmodet1 then
				
				for i = 1, #warmodeteamA do
					if warmodeteamA[i] == player:getGuid() then
						contain = 1
					end
				end
				--if contain == 0 then
				if contain == 0 then
					table.insert(warmodeteamA, player:getGuid())
					table.insert(warmodeKillAux, player:getGuid())
					player:teleportTo(temp[1])
					else
					--aqui remover 1 da contagem de pontos do time B
					warmodeDeathsT2 = warmodeDeathsT2 - 1
					
					player:teleportTo(temp[1])
				end
			end
			
			if guildId == warmodet2 then
				
				for i = 1, #warmodeteamB do
					if warmodeteamB[i] == player:getGuid() then
						contain = 1
					end
				end
				--if contain == 0 then
				if contain == 0 then
					table.insert(warmodeteamB, player:getGuid())
					table.insert(warmodeKillAux, player:getGuid())
					player:teleportTo(temp[2])
					else
					--aqui remover um da contagem de pontos do time A
					warmodeDeathsT1 = warmodeDeathsT1 - 1
					
					player:teleportTo(temp[2])
				end
			end
			player:sendTextMessage(MESSAGE_FAILURE, 'Boa sorte.')
			local check = db.storeQuery("SELECT `id` FROM `guild_wars` ORDER BY `id` DESC LIMIT 1")
			currentWarId = result.getNumber(check, "id")
			print(currentWarId)
			--se chegamos ate aqui o player pode se juntar a area do warmode
			--teleportar o player para a area dos itens
			--se o player entrou, agora temos que contar as suas kills > RegisterEvent
			--warmodeCidades[warmodetempcity].nome
			--warmodecityPos[warmodetempcity]
			result.free(check)
			
			player:registerEvent("killWarmode")
			--fazer uma condicao ao logar que remove esse evento, incondicionalmente visto que a area do warmode precisa ser no logout
			--Inserir os players que ganharam essa condition em uma tabela
			--Matar um player faz com que o mesmo seja removido da tabela
			--No fim da war todos que estiverem dentro dessa tabela terao esse evento removido caso estejam online(caso contrario o logar acima resolvera)
			-- ***************************************************************************************************
			--aqui remover os itens que nao sao permitidos
			--passo1: Checar todos os parametros com referencia a itens:
			--SSA id 2197
			--might ring id 2164
			--ultimate potions (hp:8473 mana:26029 spirit:26030 supremehp:26031 ) 8473, 26029, 26030, 26031
			--runas: 2260, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 2274, 2275, 2277, 2278, 2279, 2280, 2285, 2286, 2287, 2288, 2289, 2290, 2291, 2292, 2293, 2294
			-- 2295, 2296, 2301, 2302, 2303, 2304, 2305, 2308, 2310, 2311, 2313, 2315, 2316
			--se um parametro de item esta ativo, inserir em itens permitidos
			if globalwarmodeItens == 1 then
				
				--caso 1 somente Itens da war ativos: checar todos os itens do player remover todos os itens, exceto os permitidos
				local containers = {}
				
				for i = 1, 11 do
					local sitem = getPlayerSlotItem(player, i)
					--aqui estamos varrendo os slots
					if sitem.uid > 0 then
						if isContainer(sitem.uid) then
							--aqui é container
							table.insert(containers, sitem.uid)
							else
							--aqui é item
							--table.insert(items, sitem)
							-- aqui localizamos um item
							-- o padrao é remover, exceto se for um container ou se faz parte dos itens permitidos
							local remover = 1
							for i = 1, #warmodeitensAllow do
								if sitem.itemid == warmodeitensAllow[i] then
									remover = 0
								end
							end
							
							if remover == 1 then
								local inbox = player:getInbox()
								local item = Item(sitem.uid)
								if item and inbox then
									item:moveTo(inbox)
								end
							end
							
							
						end
					end
				end
				
				while #containers > 0 do
					--aqui estamos varrendo os containers encontrados no player
					for k = (getContainerSize(containers[1]) - 1), 0, -1 do
						local tmp = getContainerItem(containers[1], k)
						if isContainer(tmp.uid) then
							table.insert(containers, tmp.uid)
							
							else
							--table.insert(items, tmp.uid)
							--aqui localizamos item
							local remover = 1 
							for i = 1, #warmodeitensAllow do
								if tmp.itemid == warmodeitensAllow[i] then
									remover = 0
								end
							end
							
							if remover == 1 then
								local inbox = player:getInbox()
								local item = Item(tmp.uid)
								if item and inbox then
									item:moveTo(inbox)
								end
							end
							
						end
					end
					table.remove(containers, 1)
				end
				--Aqui dar os itens da vocação
				
				local temp = warmodevocationsItems[player:getVocation():getBase():getId()]
				for i = 1, #temp do
					player:addItem(temp[i], 1)
				end
				
				
				--end of aqui dar os itens da vocação
				else
				--caso 2 itens da war desativados: permitir o player entrar, remover apenas itens nao permitidos
				
				local containers = {}
				
				for i = 1, 11 do
					local sitem = getPlayerSlotItem(player, i)
					--aqui estamos varrendo os slots
					if sitem.uid > 0 then
						if isContainer(sitem.uid) then
							--aqui é container
							table.insert(containers, sitem.uid)
							else
							--aqui é item
							--table.insert(items, sitem)
							-- aqui localizamos um item
							-- o padrao é remover, exceto se for um container ou se faz parte dos itens permitidos
							local remover = 0
							for i = 1, #warmodeitensBlock do
								if sitem.itemid == warmodeitensBlock[i] then
									remover = 1
								end
							end
							
							if remover == 1 then
								local inbox = player:getInbox()
								local item = Item(sitem.uid)
								if item and inbox then
									item:moveTo(inbox)
								end
							end
							
							
						end
					end
				end
				
				while #containers > 0 do
					--aqui estamos varrendo os containers encontrados no player
					for k = (getContainerSize(containers[1]) - 1), 0, -1 do
						local tmp = getContainerItem(containers[1], k)
						if isContainer(tmp.uid) then
							table.insert(containers, tmp.uid)
							
							else
							--table.insert(items, tmp)
							--aqui localizamos item
							local remover = 0 
							for i = 1, #warmodeitensBlock do
								if tmp.itemid == warmodeitensBlock[i] then
									remover = 1
								end
							end
							
							if remover == 1 then
								local inbox = player:getInbox()
								local item = Item(tmp.uid)
								if item and inbox then
									item:moveTo(inbox)
								end
							end
							
						end
					end
					table.remove(containers, 1)
				end
			end
			
			
			
			--end of aqui remover os itens que nao sao permitidos
			--****************************************************************************************************
			
			
			--Aplicar parametro do level
			--checar se o parametro do level esta ativo
			if globalwarmodeLevel == 1 then
				db.query("INSERT INTO `guild_warmode_level`(`player_guid`, `level`, `healthmax`, `experience`, `manamax`, `cap`, `login`) VALUES ("..player:getGuid()..","..player:getLevel()..","..player:getMaxHealth()..","..player:getExperience()..","..player:getMaxMana()..",".. player:getCapacity()/100 ..", 0)")
				
				
				-- Guardar: `player_guid`, `level`, `healthmax`, `experience`, `manamax`,  `cap`
				--depois checar o level do player
				local playerLevel = player:getLevel()
				
				--se o level do player é menor
				if playerLevel < 300 then
					db.query("UPDATE `guild_warmode_level` SET `login`= 1 WHERE `player_guid` ="..player:getGuid().."")
					--aqui dentro adicionar a xp ate chegar ao level 300
					local newexperience = 441084800 - player:getExperience()
					player:addExperience(newexperience)
				end
				--se o level do player é maior
				if playerLevel > 300 then
					--aqui remover o player para ajustar o seu level atraves de um update no DB
					local vocation = player:getVocation()
					local guid = player:getGuid()
					player:remove()
					local hp = 130 + (vocation:getHealthGain() * 300)
					local mana = vocation:getManaGain() * 300
					--local cap = 40000 + (vocation:getCapacityGain() * 300) --recomendado nao alterar a cap
					local experience = 441084800
					db.query("UPDATE `players` SET `level`= 300, `experience` = "..experience..", `healthmax` = "..hp..", `health` = "..hp..", `mana` = "..mana..", `manamax` = "..mana.." WHERE `id` ="..guid.."")
				end				
			end
			--end of checar se o parametro do level esta ativo
			
			
			
			
		end
		if buttonId == 103 then
			local title = "War Info!"
			local message = "Aqui voce podera aceitar ou rejeitar solicitacoes de guerra\n\nNext para ver mais Detalhes:"
			local window = ModalWindow(1847, title, message)
			window:addButton(100, "Next")
			window:addButton(101, "Cancel")
			window:setDefaultEnterButton(100)
			window:setDefaultEscapeButton(101)
			
			local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenged` = "..player:getGuild():getId().." AND `rejected` = 0 AND `winner` = 0")
			
			local i = 1
			repeat
				if check then
					local list = db.storeQuery("SELECT * FROM `guilds` WHERE `id` ="..result.getNumber(check, "challenger").."")
					window:addChoice(result.getNumber(check, "challenger"), ""..result.getString(list, "name").."")
					i = i + 1
				end
			until not result.next(check)
			result.free(check)
			result.free(list)
			if i > 1 then
				window:sendToPlayer(player)
				else
				return player:sendTextMessage(MESSAGE_FAILURE, 'Nao ha solicitacoes para serem aceitadas.')
			end
			
		end
		if buttonId == 104 then
			--REVOKE > Apagar solicitacao de guerra...
			local title = "War Revoke!"
			local message = "Aqui voce podera cancelar solicitações de guerra"
			local window = ModalWindow(1846, title, message)
			window:addButton(100, "Next")
			window:addButton(101, "Cancel")
			window:setDefaultEnterButton(100)
			window:setDefaultEscapeButton(101)
			-- fazer um select mostrando todas as guilds.
			local list = db.storeQuery("SELECT * FROM `guilds`")
			local aux = 0
			if true then
				repeat
					if result.getNumber(list, "id") ~= guildId then
						
						local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenger` ="..player:getGuild():getId().." AND `challenged` = "..result.getNumber(list, "id").." AND `accepted` = 0 AND `rejected` = 0")
						
						if check then
							window:addChoice(result.getNumber(list, "id"), ""..result.getString(list, "name").."")
							aux = aux + 1
						end
						result.free(check)
					end
				until not result.next(list)
				result.free(list)
			end
			
			if aux > 0 then
				window:sendToPlayer(player)
				else
				return player:sendTextMessage(MESSAGE_FAILURE, 'Nao ha solicitacoes para serem removidas.')
			end
		end
		
		if buttonId == 102 then
			-- INVITAR GUILD PARA WAR
			--Checks: Checar se tem guild, se nao tiver mandar info
			--Caso tenha guild, as opçoes selecionaveis serao as guilds existentes exceto a sua propria.
			local title = "War Invite!"
			local message = "Aqui voce podera selecionar uma guild para desafiar!"
			local window = ModalWindow(1841, title, message)
			
			window:addButton(100, "Next")
			window:addButton(101, "Cancel")
			
			-- fazer um select mostrando todas as guilds.
			local list = db.storeQuery("SELECT * FROM `guilds`")
			local i = 1
			if true then
				local v = ''
				repeat
					if result.getNumber(list, "id") ~= guildId then
						local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenger` ="..player:getGuild():getId().." AND `challenged` = "..result.getNumber(list, "id").." AND `rejected` = 0 AND `winner` = 0")
						if not check then
							window:addChoice(result.getNumber(list, "id"), "Id:"..result.getNumber(list, "id").." - "..result.getString(list, "name").."")
							i = i + 1 
						end
						result.free(check)
					end
				until not result.next(list)
				result.free(list)
			end
			window:setDefaultEnterButton(100)
			window:setDefaultEscapeButton(101)
			if i > 1 then
				db.query("DELETE FROM `guild_wars_invite` WHERE `guild_id` = "..guildId.."")
				window:sendToPlayer(player)
				else
				return player:sendTextMessage(MESSAGE_FAILURE, 'nao ha guilds para desafiar')
			end
		end
		
		elseif modalWindowId == 1841 then
		--aqui guardar a guild desafiada..
		print('aqui eu checkei o choiceID para atualizar o warmode temp'..choiceId..'')
		if choiceId >= 1 then
			local list = db.storeQuery("SELECT `id` FROM `guilds` WHERE `id` ="..choiceId.."")
			if result.getNumber(list, "id") == choiceId then
				if not warmodetemp[player:getGuid()] then
					warmodetemp[player:getGuid()] = choiceId
				end
			end
			result.free(list)	
		end
		
		-- fazer um select no banco de dados por player com a mesma guild que a do Player
		if buttonId == 102 then
			--agora converter o choiceid em guid atraves da sequencia guildPlayers
			local list = db.storeQuery("SELECT `player_id` FROM `guild_membership` WHERE `guild_id` ="..guildId.."")
			local guildPlayers = {}
			if true then
				repeat
					local nomeid = result.getNumber(list, "player_id")
					table.insert(guildPlayers, nomeid)
				until not result.next(list)
				result.free(list)
			end
			db.query("INSERT INTO `guild_wars_invite` (`player_guid`, `guild_id`) VALUES (".. guildPlayers[choiceId] ..", ".. guildId ..") ON DUPLICATE KEY UPDATE `player_guid` = ".. guildPlayers[choiceId])
		end
		if buttonId == 103 then
			db.query("DELETE FROM `guild_wars_invite` WHERE `guild_id` = "..guildId.."")
		end
		if buttonId == 106 then
			local list = db.storeQuery("SELECT `player_guid` FROM `guild_wars_invite` WHERE `guild_id` ="..guildId.."")
			local i = 1
			local guildPlayers = {}
			if true then
				repeat
					i = i + 1 
					local nomeid = result.getNumber(list, "player_guid")
					local nome = db.storeQuery("SELECT `name` FROM `players` WHERE `id` ="..nomeid.."")
					nome = result.getString(nome, "name")
					table.insert(guildPlayers, nome)
				until not result.next(list)
				result.free(list)
			end
			
			local title = "Voce selecionou os membros"
			local message = 'Total de membros invitados:  '..#guildPlayers..' \n\n\n'
			for i = 1, #guildPlayers do
				message = ""..message..""..i.." - "..guildPlayers[i].."\n"
			end
			message = ""..message.."\nClique em OK para ver as variaveis da guerra"
			local window = ModalWindow(1843, title, message)
			window:setDefaultEnterButton(100)
			window:setDefaultEscapeButton(101)
			window:addButton(101, "Cancel")
			window:addButton(100, "OK")
			window:sendToPlayer(player)
			return true
		end
		
		local list = db.storeQuery("SELECT `player_id` FROM `guild_membership` WHERE `guild_id` ="..guildId.."")
		local guildPlayers = {}
		if true then
			repeat
				local nomeid = result.getNumber(list, "player_id")
				table.insert(guildPlayers, nomeid)
			until not result.next(list)
			result.free(list)
		end
		
		local tabelaAux, seq, inside = {}, {}, {}
		
		for i = 1, #guildPlayers do
			local id = guildPlayers[i]
			local nome = db.storeQuery("SELECT `name` FROM `players` WHERE `id` ="..id.."")
			nome = result.getString(nome, "name")
			
			local invited = db.storeQuery("SELECT `player_guid` FROM `guild_wars_invite` WHERE `player_guid` ="..id.."")
			local invite = result.getNumber(invited, "player_guid")
			
			if invite == id then
				table.insert(inside, i)
				else
				table.insert(seq, i)
				table.insert(tabelaAux, nome)
			end
		end
		result.free(nome)
		result.free(invited)
		
		
		local title = "Selecione os membros da sua guild!"
		local message = ""
		if #seq >= 1 then
			message = "Aqui uma lista dos membros que ainda nao foram invitados"
			else
			message = "Todos os membros ja foram selecionados"
		end
		local window = ModalWindow(1841, title, message)
		if #inside >= 1 then
			window:addButton(106, "Next")
		end
		window:addButton(101, "Cancel")
		if #seq >= 1 then
			window:addButton(102, "Add")
		end
		window:addButton(103, "Reset")
		
		for i = 1, #tabelaAux do
			window:addChoice(seq[i], ""..tabelaAux[i].."")
		end
		
		window:setDefaultEnterButton(100)
		window:setDefaultEscapeButton(101)
		
		if buttonId ~= 101 then
			window:sendToPlayer(player)
		end
		
		elseif modalWindowId == 1843 then
		if buttonId == 102 then
			local temp = warvariables[player:getGuid()]
			if choiceId >= 1 then
				
				if choiceId == 1 then
					if temp[choiceId] < #warmodeCidades then
						temp[choiceId] = temp[choiceId] + 1
						else
						temp[choiceId] = 1
					end
					elseif choiceId == 9 then
					if temp[choiceId] < #warmodetimeString then
						temp[choiceId] = temp[choiceId] + 1
						else
						temp[choiceId] = 1
					end
					elseif choiceId == 10 then
					if temp[choiceId] < 150 then
						temp[choiceId] = temp[choiceId] + 50
						else
						temp[choiceId] = 0
					end
					elseif choiceId == 11 then
					--inicio of Agendador
					local repet = 1
					
					while repet >= 1 do
						if temp[choiceId] < 23 then
							temp[choiceId] = temp[choiceId] + 1
							
							if table.contains(warmodeagenda, temp[choiceId]) then
								repet = repet + 1
							end
							
							else
							temp[choiceId] = 0
							if table.contains(warmodeagenda, temp[choiceId]) then
								repet = repet + 1
							end
						end
						repet = repet -1
					end
					--end of Agendador
					else
					if temp[choiceId] == 0 then
						temp[choiceId] = 1
						else
						temp[choiceId] = 0
					end
				end
			end
		end
		if buttonId == 103 then
			local opt = warvariables[player:getGuid()]
			local title = "Resumo da War"
			local message = "Resumo da war! \n\nCidade: "..warmodeCidades[opt[1]].nome.."\nNivelar Level: "..warmodewarString[opt[2]+1].."\nBau de itens: "..warmodewarString[opt[3]+1].."\nSSA: "..warmodewarString[opt[4]+1].."\nMight Ring: "..warmodewarString[opt[5]+1].."\nUltimate Potions: "..warmodewarString[opt[6]+1].."\nUE: "..warmodewarString[opt[7]+1].."\nRunas:"..warmodewarString[opt[8]+1].."\nDuracao:"..warmodetimeString[opt[9]+1].."\nLimite de kills:"..opt[10].."\nHorario:"..opt[11]..":00"
			local window = ModalWindow(1844, title, message)
			window:addButton(100, "Next")
			window:addButton(101, "Cancel")
			window:setDefaultEnterButton(100)
			window:setDefaultEscapeButton(101)
			window:sendToPlayer(player)
			--return true
			else
			if #warmodeagenda >= 23 then
				return player:sendTextMessage(MESSAGE_FAILURE, 'Agenda de horarios cheia.')
			end
			local title = "Regras da War"
			local message = "Aqui voce pode selecionar as variaveis da guerra! \n\nTodos level 300: Da o level 300 players com level menor durante a war\n\nWarmode itens: Todos os player lutarao com os itens fornecidos pelo warmode.\nTempo maximo: Tempo para o fim da war\nKills limit: Se ativado ao atingir a quantidade a war e encerrada \nDEBUG: Hora do server "..tonumber(os.date("%H")).."\nAgende a war no hora atual para comecar imediatamente"
			local window = ModalWindow(1843, title, message)
			-- criar modulo onde as variaveis serao armazenadas fazendo vinculo ao player
			
			if not warvariables[player:getGuid()] then
				warvariables[player:getGuid()] = {}
				for i = 1, 11 do
					table.insert(warvariables[player:getGuid()], 0)
				end
				local temp = warvariables[player:getGuid()]
				temp[1] = 1
				temp[4] = 1
				temp[5] = 1
				temp[6] = 1
				temp[7] = 1
				temp[8] = 1
				temp[9] = 1
				temp[11] = 18
				
				--inicio of Agendador
				local repet = 1
				
				while repet >= 1 do
					if temp[11] < 23 then
						temp[11] = temp[11] + 1
						
						if table.contains(warmodeagenda, temp[11]) then
							repet = repet + 1
						end
						
						else
						temp[11] = 0
						if table.contains(warmodeagenda, temp[11]) then
							repet = repet + 1
						end
					end
					repet = repet -1
				end
				--end of Agendador
			end
			
			local opt = warvariables[player:getGuid()]
			
			window:addChoice(1, "City: "..warmodeCidades[opt[1]].nome.."")
			window:addChoice(2, "Todos level 300 - "..warmodewarString[opt[2]+1].."")
			window:addChoice(3, "Warmode Itens - "..warmodewarString[opt[3]+1].."")			
			window:addChoice(4, "SSA - "..warmodewarString[opt[4]+1].."")
			window:addChoice(5, "Might ring - "..warmodewarString[opt[5]+1].."")
			window:addChoice(6, "Ultimate Potions - "..warmodewarString[opt[6]+1].."")
			window:addChoice(7, "UE - "..warmodewarString[opt[7]+1].."")
			window:addChoice(8, "Runas - "..warmodewarString[opt[8]+1].."")
			window:addChoice(9, "Tempo Maximo - "..warmodetimeString[opt[9]].." Minutos")
			window:addChoice(10, "Kills limit - "..opt[10].."")
			window:addChoice(11, "Horario - "..opt[11]..":00")
			
			window:addButton(103, "Next")
			window:addButton(101, "Cancel")
			window:addButton(102, "Toogle")
			window:setDefaultEnterButton(100)
			window:setDefaultEscapeButton(101)
			window:sendToPlayer(player)
		end
		elseif modalWindowId == 1844 then
		if buttonId == 101 then
			player:unregisterEvent("modalWarmode")
			return true
		end
		local title = "sucess!"
		local message = "A solicitacao de guerra foi salva com sucesso!!! >>Para facilitar os testes tentaremos iniciar a guerra assim que a outra guild aceitar<<"
		--remover o horario selecionado das opções
		local opt = warvariables[player:getGuid()]
		table.insert(warmodeagenda, opt[11])
		
		local window = ModalWindow(1845, title, message)
		window:addButton(100, "OK")
		window:setDefaultEnterButton(100)
		
		player:unregisterEvent("modalWarmode")
		--guardar no banco de dados as seguinte informaÃ§Ãµes..
		-- GuildId de quem desafiou e de quem foi desafiado
		
		local list = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenger` ="..player:getGuild():getId().." AND `challenged` = "..warmodetemp[player:getGuid()].." AND `rejected` = 0 AND `winner` = 0")
		
		if not list then
			local opt = warvariables[player:getGuid()]
			db.query("INSERT INTO `guild_warmode` (`challenger`, `challenged`, `accepted`, `p1`, `p2`, `p3`, `p4`, `p5`, `p6`, `p7`, `p8`, `p9`, `p10`, `p11`) VALUES (".. player:getGuild():getId() ..", ".. warmodetemp[player:getGuid()] ..", ".. 0 ..", "..opt[1]..","..opt[2]..","..opt[3]..","..opt[4]..","..opt[5]..","..opt[6]..","..opt[7]..","..opt[8]..","..opt[9]..","..opt[10]..", "..opt[11]..")")
			window:sendToPlayer(player)
			else
			return player:sendTextMessage(MESSAGE_FAILURE, 'Voce ja desafiou essa guild')
		end
		result.free(list)
		elseif modalWindowId == 1846 then
		db.query("DELETE FROM `guild_warmode` WHERE `challenger` = "..player:getGuild():getId().." AND `challenged` = "..choiceId.." AND `rejected` = 0 AND `accepted` = 0")
		--recalcular a agenda
		warmodeagenda = {}
		local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `winner` = 0")
		repeat
			if check then
				local aux = result.getNumber(check, "p11")
				table.insert(warmodeagenda, aux)
				print("Agenda:", aux)
			end
		until not result.next(check)
		result.free(check)
		--end of aqui funcao para preencher o warmode agenda
		return player:sendTextMessage(MESSAGE_FAILURE, 'A solicitacao foi deletada com sucesso.')
		
		elseif modalWindowId == 1847 then
		local title = "Resumo da War"
		--fazer um select no db pelo challenged, buscar os parametros atraves do select
		local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenger` ="..choiceId.." AND `challenged` = "..player:getGuild():getId().." AND `winner` = 0")
		local p1 = result.getNumber(check, "p1")
		local p2 = result.getNumber(check, "p2")
		local p3 = result.getNumber(check, "p3")
		local p4 = result.getNumber(check, "p4")
		local p5 = result.getNumber(check, "p5")
		local p6 = result.getNumber(check, "p6")
		local p7 = result.getNumber(check, "p7")
		local p8 = result.getNumber(check, "p8")
		local p9 = result.getNumber(check, "p9")
		local p10 = result.getNumber(check, "p10")
		local p11 = result.getNumber(check, "p11")
		result.free(check)
		
		local check = db.storeQuery("SELECT * FROM `guild_wars_invite` WHERE `guild_id` ="..choiceId.."")
		local desafiantes = 0
		repeat
			desafiantes = desafiantes + 1
		until not result.next(check)
		result.free(check)
		--aqui guardei a guild para a proxima tela
		warmodetemp[player:getGuid()] = choiceId
		
		
		local message = "Resumo da war! \n\nNumero de desafiantes: "..desafiantes.." \nCidade: "..p1.."\nNivelar Level: "..warmodewarString[p2+1].."\nSomente itens da WAR: "..warmodewarString[p3+1].."\nSSA: "..warmodewarString[p4+1].."\nMight Ring: "..warmodewarString[p5+1].."\nUltimate Potions: "..warmodewarString[p6+1].."\nUE: "..warmodewarString[p7+1].."\nRunas: "..warmodewarString[p8+1].."\nDuracao: "..warmodetimeString[p9+1].."\nKills limit: "..p10.."\nHorario:"..p11..":00"
		local window = ModalWindow(1848, title, message)
		window:addButton(102, "Reject")
		window:addButton(100, "Accept")
		window:addButton(101, "Cancel")
		window:setDefaultEnterButton(100)
		window:setDefaultEscapeButton(101)
		window:sendToPlayer(player)
		elseif modalWindowId == 1848 then
		if buttonId == 100 then
			db.query("UPDATE `guild_warmode` set `accepted` = 1 WHERE `challenger` = "..warmodetemp[player:getGuid()].." AND `challenged` = "..player:getGuild():getId().." AND `rejected` = 0")
			checkWarmode()
			return player:sendTextMessage(MESSAGE_FAILURE, 'A solicitacao foi aceita com sucesso. >>Para facilitar os testes tentaremos iniciar a war agora<< .. Digite !war para entrar')
			
		end
		if buttonId == 102 then
			db.query("UPDATE `guild_warmode` set `rejected` = 1 WHERE `challenger` = "..warmodetemp[player:getGuid()].." AND `challenged` = "..player:getGuild():getId().." AND `accepted` = 0")
			--recalcular a agenda
			warmodeagenda = {}
			local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `winner` = 0")
			repeat
				if check then
					local aux = result.getNumber(check, "p11")
					table.insert(warmodeagenda, aux)
					print("Agenda:", aux)
				end
			until not result.next(check)
			result.free(check)
			--end of aqui funcao para preencher o warmode agenda
			return player:sendTextMessage(MESSAGE_FAILURE, 'A solicitacao foi deletada com sucesso.')
		end
		
		else
		player:unregisterEvent("modalWarmode")
	end
	return true
end
modalWarmode:register()


local modalWarmodeLogin = CreatureEvent("modalWarmodeLogin")

function modalWarmodeLogin.onLogin(player)
	print('funcao onLogin')
	
	
	local check = db.storeQuery("SELECT * FROM `guild_warmode_level` WHERE `player_guid` = "..player:getGuid().."")
	local login, ajuste, experience
	local oldlevel = 0
	local hp, mana, cap
	if check then
		--este player tem um registro de alteração de level
		--Caso a war esteja em andamento registrar o evento de kills novamente
		login = result.getNumber(check, "login")
		oldlevel = result.getNumber(check, "level")
		
		hp = result.getNumber(check, "healthmax")
		mana = result.getNumber(check, "manamax")
		cap = result.getNumber(check, "cap")
		experience = result.getNumber(check, "experience")
		if login == 0 then --aqui o level do player era maior que 300
			player:registerEvent("killWarmode")
			print("registrei o evento do kill")
			db.query("UPDATE `guild_warmode_level` SET `login`= 1 WHERE `player_guid` ="..player:getGuid().."")
			--teleportar novamente
			
			local contain = 0
			local temp = warmodecityPos[warmodeCidades[warmodetempcity].nome]
			player:teleportTo(temp[1])
			if guildId == warmodet1 then
				
				
				player:teleportTo(temp[1])
				print("tentei dar tp")
				
			end
			
			if guildId == warmodet2 then
				
				
				player:teleportTo(temp[2])
				print("tentei dar tp")
				
			end
			
		end
		if login == 1 then --aqui ele ja estava com o status correto, sendo assim, se logou novamente, voltar o level antigo depois de checar se o mesmo ainda esta em um dos times
			ajuste = 1
			player:teleportTo(player:getTown():getTemplePosition())
		end
		
	end
	
	result.free(check)
	
	
	
	
	--aqui, caso o player esteja logando, conferir se o mesmo faz parte da tabela de players com evento
	--se ele faz parte, remover da tabela, pois o evento nao esta mais registrado
	if login ~= 0 then
		for i = 1, #warmodeKillAux do
			if player:getGuid() == warmodeKillAux[i] then
				print("um player que estava dentro da war, logou")
				table.remove(warmodeKillAux, i)
				player:teleportTo(player:getTown():getTemplePosition())
			end
		end
	end
	
	if ajuste == 1 then
		--aqui, checar se o oldLevel e menor ou maior que o atualizar
		if oldlevel < player:getLevel() or oldlevel > player:getLevel() then
			--aqui o player ganhou ou perdeu level ao entrar, sendo assim, precisa restaurar no BD
			local guid = player:getGuid()
			player:remove()
			db.query("UPDATE `players` SET `level`= "..oldlevel..", `experience` = "..experience..", `healthmax` = "..hp..", `health` = "..hp..", `mana` = "..mana..", `manamax` = "..mana..", `cap` = "..cap.." WHERE `id` ="..guid.."")
			db.query("DELETE FROM `guild_warmode_level` WHERE `player_guid` = "..guid.."")
		end	
		
		--NEW remover os itens do warmode se o parametro esta de itens está ativo
		if globalwarmodeItens == 1 then
			local temp = warmodevocationsItems[player:getVocation():getBase():getId()]
			for i = 1, #temp do
				player:removeItem(temp[i], 1)
			end
		end
		--end NEW remover os itens do warmode se o parametro esta de itens está ativo
	end
	return true
end

modalWarmodeLogin:register()
