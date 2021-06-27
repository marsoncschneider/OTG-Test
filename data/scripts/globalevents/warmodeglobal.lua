
function updatewinnerWarmode(challengerId, challengedId, updateWinner)
	
	if nextAgendaRemove ~= 0 then
		for i = 1, #warmodeagenda do
			if warmodeagenda[i] == nextAgendaRemove then
				nextAgendaRemove = 0
				table.remove(warmodeagenda, i)
			end
		end
	end
	if updateWinner == 0 then
		return false
	end
	db.query("UPDATE `guild_wars` SET `ended` = '".. os.time() .."', `status` = 4 WHERE `guild_wars`.`id` = "..currentWarId..";")
	db.query("UPDATE `guild_warmode` SET `winner` = "..updateWinner.." WHERE `challenger` = "..challengerId.." AND `challenged` = "..challengedId.." AND `winner` = 0 AND `accepted` = 1")
	--limpar tudo para a proxima execução:
	
	warvariables = {}
	warmodetemp = {}
	warmodeagenda = {}
	warmodet1 = 0
	warmodet2 = 0
	warmodeteamA = {}
	warmodeteamB = {}
	warmodetempcity = 0
	warmodeRunning = 0
	warmodeKillsLimit = 0
	warmodeDeathsT1 = 0
	warmodeDeathsT2 = 0
	warmodeKillAux = {}
	challengerName = ''
	challengedName = ''
	challengerId = 0
	challengedId = 0
	globalwarmodeLevel = 0
	warmodeitensAllow = {}
	warmodeitensBlock = {}
	globalwarmodeItens = 0
	globalwarmodeUE = 0
	globalwarmodeRunas = 0
	warmodeResumo = {}
	
	checkWarmode() --se esta linha nao esta comentada, ao finalizar uma war o sistema vai procurar uma nova war, mesmo que ainda nao seja a proxima hora
end

function endWarmode()
	local updateWinner = 0
	print("endWarmode")
	--aqui a funcao que acaba com a WAR
	-- warmodeRunning 
	if warmodeRunning == 0 then
		--Warmode Running significa que a guerra nao esta iniciada
		return true
	end
	if warmodeRunning <= os.time() then
		--neste caso a guerra foi iniciada e nao terminada
		--se o valor for menor ou igual ao os.time podemos acabar a war, pois ja acabou o tempo de war
		warmodeRunning = 0 -- chave
		--A War acabou por tempo, o time com mais kills Ganha
		--possibilidades...Time1 tem mais kills, time2 tem mais kills, ambos tem a mesma quantidade de kills
		local texto = '[Warmode] A War acabou por tempo!'
		if warmodeDeathsT1 > warmodeDeathsT2 then
			texto = ''..texto..' Parabens a Guild Vencedora '..challengerName..'!'
			updateWinner = warmodet1
			elseif warmodeDeathsT1 < warmodeDeathsT2 then
			texto = ''..texto..' Parabens a Guild Vencedora '..challengedName..'!'
			updateWinner = warmodet2
			elseif warmodeDeathsT1 == warmodeDeathsT2 then
			texto = ''..texto..' Parabens para ambas as guilds por este emocionante empate! '..#warmodeKillAux..''
			updateWinner = -1
		end
		
		broadcastMessage(texto, MESSAGE_STATUS_WARNING)
		for i = 1, #warmodeKillAux do
			local tempPlayer = Player(warmodeKillAux[i])
			if tempPlayer then
				print("removendo players da tabela porque a war acabou")
				--table.remove(warmodeKillAux, i)
				tempPlayer:unregisterEvent("killWarmode")
				tempPlayer:teleportTo(tempPlayer:getTown():getTemplePosition())
				if globalwarmodeLevel == 1 then
					tempPlayer:remove()
				end
			end
		end
		warmodeKillAux = {}
		updatewinnerWarmode(warmodet1, warmodet2, updateWinner) --função marota
		return true
	end
	--supondo que a funcao foi chamada no kill vamos checar a soma de deaths, e se algum time ficou sem membros
	if warmodeKillsLimit > 0 then --checar se foi ativado o limitador de kills
		if (warmodeDeathsT1 + warmodeDeathsT2) >= warmodeKillsLimit then
			warmodeRunning = 0
			--A War acabou por ter sido atingido o limite de kills, o time com mais kills ganha
			--possibilidades...Time1 tem mais kills, time2 tem mais kills, ambos tem a mesma quantidade de kills
			local texto = '[Warmode] O limite de Kills foi atingido!'
			if warmodeDeathsT1 > warmodeDeathsT2 then
				texto = ''..texto..' Parabens a Guild Vencedora '..challengerName..'!'
				updateWinner = warmodet1
				elseif warmodeDeathsT1 < warmodeDeathsT2 then
				texto = ''..texto..' Parabens a Guild Vencedora '..challengedName..'!'
				updateWinner = warmodet2
				elseif warmodeDeathsT1 == warmodeDeathsT2 then
				texto = ''..texto..' Parabens!!! para ambas as guilds, '..challengerName..' e '..challengedName..' por este emocionante empate! '..#warmodeKillAux..''
				updateWinner = -1
			end
			broadcastMessage(texto, MESSAGE_STATUS_WARNING)
			for i = 1, #warmodeKillAux do
				local tempPlayer = Player(warmodeKillAux[i])
				if tempPlayer then
					print("removendo players da tabela porque a war acabou")
					--table.remove(warmodeKillAux, i)
					tempPlayer:unregisterEvent("killWarmode")
					tempPlayer:teleportTo(tempPlayer:getTown():getTemplePosition())
					if globalwarmodeLevel == 1 then
						tempPlayer:remove()
					end
				end
			end
			warmodeKillAux = {}
			updatewinnerWarmode(warmodet1, warmodet2, updateWinner) --função marota
			return true
		end
	end
	
	if warmodeDeathsT1 > 0 or warmodeDeathsT2 > 0 then
		if warmodeDeathsT2 == #warmodeteamA then
			--neste caso a quantidade de deaths do timeA é igual a soma de membros do time, logo, todos morreram
			warmodeRunning = 0
			--A War acabou porque o time1 ficou vazio.. O time2 Ganhou
			broadcastMessage("[Warmode] Parabens a Guild "..challengedName.." por ter eliminado todos os integrantes da Guild "..challengerName.."", MESSAGE_STATUS_WARNING)
			updateWinner = challengedId
			--return true
		end
		if warmodeDeathsT1 == #warmodeteamB then
			--neste caso a quantidade de deaths do timeB é igual a soma de membros do time, logo, todos morreram
			warmodeRunning = 0
			--A War acabou porque o time2 ficou vazio.. O time1 Ganhou
			broadcastMessage("[Warmode] Parabens a Guild "..challengerName.." por ter eliminado todos os integrantes da Guild "..challengedName.."", MESSAGE_STATUS_WARNING)
			updateWinner = challengerId
			--return true
		end
		
		if warmodeRunning == 0 then
			for i = 1, #warmodeKillAux do
				local tempPlayer = Player(warmodeKillAux[i])
				if tempPlayer then
					tempPlayer:unregisterEvent("killWarmode")
					tempPlayer:teleportTo(tempPlayer:getTown():getTemplePosition())
					if globalwarmodeLevel == 1 then
						tempPlayer:remove()
					end
				end
			end
		end
		warmodeKillAux = {}
		updatewinnerWarmode(warmodet1, warmodet2, updateWinner)
	end
end	

function checkWarmode()
	if warmodeRunning ~= 0 then
		--ha uma war em andamento
		return false
	end
	local horas = tonumber(os.date("%H"))
	local minutos = tonumber(os.date("%M"))
	local remaining = 60 - minutos
	print('eu sou o checkWarmode... '..horas..':'..minutos..'!')
	addEvent(checkWarmode, 60000 * remaining)
	--aqui fazer um select no banco de dados, onde accepted = 1 and winner = 0 and p11 = horas
	local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `winner` = 0 AND `accepted` = 1 AND `p11` = "..horas.."")
	local challenger, challenged, p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
	if check then
		challenger = result.getNumber(check, "challenger")
		challenged = result.getNumber(check, "challenged")
		p1 = result.getNumber(check, "p1") --cidade
		table.insert(warmodeResumo, p1)
		p2 = result.getNumber(check, "p2") --level
		table.insert(warmodeResumo, p2)
		p3 = result.getNumber(check, "p3") --warmodeitens
		table.insert(warmodeResumo, p3)
		p4 = result.getNumber(check, "p4") --ssa
		table.insert(warmodeResumo, p4)
		p5 = result.getNumber(check, "p5") --might ring
		table.insert(warmodeResumo, p5)
		p6 = result.getNumber(check, "p6") --potions
		table.insert(warmodeResumo, p6)
		p7 = result.getNumber(check, "p7") --UE
		table.insert(warmodeResumo, p7)
		p8 = result.getNumber(check, "p8") --Runas
		table.insert(warmodeResumo, p8)
		p9 = result.getNumber(check, "p9") --TempoMaximo
		table.insert(warmodeResumo, p9)
		p10 = result.getNumber(check, "p10") --limite de kills
		table.insert(warmodeResumo, p10)
		p11 = result.getNumber(check, "p11") --horario
		table.insert(warmodeResumo, p11)
		globalwarmodeLevel = p2
		nextAgendaRemove = p11
		globalwarmodeItens = p3
		globalwarmodeUE = p7
		globalwarmodeRunas = p8
		--check SSA
		if p4 == 1 then
			table.insert(warmodeitensAllow, 2197)
			else
			table.insert(warmodeitensBlock, 2197)
		end
		--end of check SSA
		--check might ring 2164
		if p5 == 1 then
			table.insert(warmodeitensAllow, 2164)
			else
			table.insert(warmodeitensBlock, 2164)
		end
		--end of check might ring
		--check of potions
		for i = 1, #warmodeUltimatePot do
			if p6 == 1 then
				table.insert(warmodeitensAllow, warmodeUltimatePot[i])
				else
				table.insert(warmodeitensBlock, warmodeUltimatePot[i])
			end
		end
		--end of check of potions
		--check of runas
		for i = 1, #warmodeRunas do
			if p8 == 1 then
				table.insert(warmodeitensAllow, warmodeRunas[i])
				else
				table.insert(warmodeitensBlock, warmodeRunas[i])
			end
		end
		--end of check of runas
	end
	result.free(check)
	if not check then
		return true
	end
	
	local check = db.storeQuery("SELECT * FROM `guilds` WHERE `id` = "..challenger.."")
	if check then
		challengerName = result.getString(check, "name")
		challengerId = result.getNumber(check, "ownerid")
	end
	result.free(check)
	
	local check = db.storeQuery("SELECT * FROM `guilds` WHERE `id` = "..challenged.."")
	if check then
		challengedName = result.getString(check, "name")
		challengedId = result.getNumber(check, "ownerid")
	end
	result.free(check)
	
	--Agora com os dados montar a batalha
	-- Texto exemplo... Atencao A Guild X desafiou a Guild Y para uma batalha que vai iniciar agora!
	broadcastMessage("[Warmode] Atencao! A Guild "..challengerName.." desafiou a Guild "..challengedName.." para uma batalha que vai iniciar agora! Use o comando !war, para juntar-se a sua guild.", MESSAGE_STATUS_WARNING)
	--Aqui criar o registro na DB para subir os escudos da war
	local check = db.storeQuery("SELECT * FROM `guild_wars` WHERE `guild1` = "..challenger.." AND `ended` = 0")
	if check then
		db.storeQuery("DELETE FROM `guild_wars` WHERE `guild1` = "..challenger.." AND `ended` = 0")
	end
	result.free(check)
	local check = db.storeQuery("SELECT * FROM `guild_wars` WHERE `guild1` = "..challenged.." AND `ended` = 0")
	if check then
		db.storeQuery("DELETE FROM `guild_wars` WHERE `guild1` = "..challenged.." AND `ended` = 0")
	end
	result.free(check)
	--CRIAR O INSERT
		db.query("INSERT INTO `guild_wars`(`guild1`, `guild2`, `name1`, `name2`, `status`, `started`, `ended`) VALUES ("..challenger..","..challenged..",'"..challengerName.."','"..challengedName.."',1,".. os.time() ..", 0)")
		
	--end of Aqui criar o registro na DB para subir os escudos da war
	warmodet1 = challenger
	warmodet2 = challenged
	nextAgendaRemove = p11
	warmodetempcity = p1 
	
	local segundos = (60 * tonumber(warmodetimeString[p9]))
	warmodeRunning = os.time() + segundos
	addEvent(endWarmode, segundos * 1000) --p9*30
	warmodeKillsLimit = p10
	--Neste ponto a war ja comecou
	-- condicoes para fazer a war acabar
	-- 1: Se algum dos times ficar sem membros
	-- 2: Se a soma de kills dos dois times somar o limite
	-- 3: Caso o tempo maximo de war foi atingido
end



local warmodeGlobal = GlobalEvent("warmodeGlobal")
function warmodeGlobal.onStartup()
	print('WARMODE STARTUP NEW')
		--*********************************************************************************************************************************************************
	-- CONFIG : Marson Schneider 24/10/2020 UPDATED 07/04/2021
	--*********************************************************************************************************************************************************
	warvariables = {}
	warmodetemp = {}
	warmodeagenda = {}
	warmodet1 = 0
	warmodet2 = 0
	warmodeteamA = {}
	warmodeteamB = {}
	warmodetempcity = 0
	warmodeRunning = 0
	warmodeKillsLimit = 0
	warmodeCidades = {
		[1] = {nome = 'Thais'},
		[2] = {nome = 'Edron'}
	}
	warmodecityPos = {
		['Thais'] = {Position(108, 99, 7), Position(50, 68, 6)},  --Thais...Posicao onde o time1 vai, posicao onde o time2 vai
		['Edron'] = {Position(206, 286, 6), Position(122, 268, 6)} --Edron {x = 206, y = 286, z = 6},  {x = 122, y = 268, z = 5}
	}
	currentWarId = nil
	warmodeResumo = {}
	warmodeDeathsT1 = 0
	warmodeDeathsT2 = 0
	warmodeKillAux = {}
	challengerName = ''
	challengedName = ''
	challengerId = 0
	challengedId = 0
	nextAgendaRemove = 0
	print('warvariables')
	globalwarmodeLevel = 0
	globalwarmodeItens = 0
	warmodeitensAllow = {}
	warmodeitensBlock = {}
	globalwarmodeUE = 0
	globalwarmodeRunas = 0
	warmodetimeString = {'10', '20', '30', '50'}
	warmodewarString = {'OFF', 'ON'}
	--potions bloqueadas pelo paremetro
	warmodeUltimatePot = {8473, 26029, 26030, 26031}
	--runas bloqueadas pelo paremetro
	warmodeRunas = {2260, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 2274, 2275, 2277, 2278, 2279, 2280, 2285, 2286, 2287, 2288, 2289, 2290, 2291, 2292, 2293, 2294, 2295, 2296, 2301, 2302, 2303, 2304, 2305, 2308, 2310, 2311, 2313, 2315, 2316}
	--aqui os itens que a warmode dá
	warmodevocationsItems = {
		-- sorcerer
		[1] = {
			23719, -- the scorcher
			2512, -- wooden shield
			2647, --plate legs
			2643, --leather boots
			2463, --plate armor
			2461 --leather helmet
		},
		-- druid
		[2] = {
			23721, -- the chiller
			2512, -- wooden shield
			2647, --plate legs
			2643, --leather boots
			2463, --plate armor
			2461 --leather helmet
			
		},
		-- paladin
		[3] = {
			2456, -- bow
			23839, -- 100 arrows
			2647, --plate legs
			2643, --leather boots
			2463, --plate armor
			2461 --leather helmet
		},
		-- knight
		[4] = {
			2379, -- dagger
			2512, -- wooden shield
			2647, --plate legs
			2643, --leather boots
			2463, --plate armor
			2461 --leather helmet
			
		}
	}
	
	
	--aqui a funcao para trabalhar com horarios > %H	hour, using a 24-hour clock (23) [00-23], %M	minute (48) [00-59]
	--o script vai rodar no startup, sendo assim, pegar 59 - os minutos atuais, = minutos faltando. Usar os minutos faltando como variavel para chamar a proxima execução
	local horas = os.date("%H", os.time())
	local minutos = os.date("%M", os.time())
	local remaining = 60 - minutos
	--end of aqui a funcao para trabalhar com horarios
	
	--aqui funcao para preencher o warmode agenda
	--selecionar tudo onde, accepted = 1, winner = 0 >>> Ja foi aceito, aguardando a hora da guerra
	local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `winner` = 0")
	repeat
		if check then
			local aux = result.getNumber(check, "p11")
			table.insert(warmodeagenda, aux)
		end
	until not result.next(check)
	result.free(check)
	--end of aqui funcao para preencher o warmode agenda
	
	addEvent(checkWarmode, 60000 * remaining) --aqui o evento inicia no primeiro segundo da proxima hora
	--checkWarmode() --aqui ao iniciar o server o sistema ja busca inioiar uma war
	return true
end
warmodeGlobal:register()
