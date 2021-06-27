local warmode = TalkAction("!warmode")

function warmode.onSay(player, words, param)
	print('WARMODE')
	local guild = player:getGuild()
		if not guild then
			print('no guild')
			return player:sendTextMessage(MESSAGE_FAILURE,'You need to belong to a guild.')
		end
	local guildId = guild:getId()
	player:registerEvent("modalWarmode")
	
	
	if guildId == warmodet1 or guildId == warmodet2 then
	--o player pertence a guild que esta lutando...
	local title = "Honera Warmode Anti Entrosa!"
    local message = "Sua guild esta em batalha, Clique em enter para se juntar a batalha. \n\nResumo: Cidade: ".. warmodeCidades[warmodetempcity].nome .."\nNivelar em level 300: "..warmodewarString[warmodeResumo[2]+1].."\nUsar itens da warmode:"..warmodewarString[warmodeResumo[3]+1].."\nSSA:"..warmodewarString[warmodeResumo[4]+1].."\nMightRing:"..warmodewarString[warmodeResumo[5]+1].."\nUltimate Potions"..warmodewarString[warmodeResumo[6]+1].."\nUE:"..warmodewarString[warmodeResumo[7]+1].."\nRunas:"..warmodewarString[warmodeResumo[8]+1].."\nDuracao: "..warmodetimeString[warmodeResumo[9]+1].." min\nKillsLimit:"..warmodeResumo[10].." "
	 local window = ModalWindow(1840, title, message)
	window:setDefaultEscapeButton(101)
	window:addButton(105, "Enter")
	window:sendToPlayer(player)
	return true
	end
	
	
	--checar se possui um desafio que foi aceito por outra guild e nao houve vencedor
	--neste caso retornar uma mensagem dizendo que o player ja esta em guerra e que deve esperar o fim da mesma
	local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenged` = "..player:getGuild():getId().." AND `accepted` = 1 AND `winner` = 0")
	local check2 = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenger` = "..player:getGuild():getId().." AND `accepted` = 1 AND `winner` = 0")
	if check then
		return player:sendTextMessage(MESSAGE_FAILURE,'Voce ja aceitou uma soliticacao de guerra, aguarde o fim da war para declarar uma nova guerra.')
	end
	if check2 then
		return player:sendTextMessage(MESSAGE_FAILURE,'Sua solicitacao de guerra foi aceita, aguarde o fim da war para declarar uma nova guerra.')
	end
	result.free(check)
	result.free(check2)
	

	
	--aqui vou checar se o player ja possui um desafio para habilitar o botao de Aceitar
	--fazer um select no BD, buscando se a guild do player possui um desafio ativo
	local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenged` = "..player:getGuild():getId().." AND `accepted` = 0 AND `rejected` = 0")
	local request = 0
			repeat
			if check then
				request = request + 1
			end
			until not result.next(check)
			result.free(check)
	--end of aqui vou checar se o player ja possui um desafio para habilitar o botao de Aceitar
	--Aqui vou checar se é possivel habilitar o botao revoke
	local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenger` = "..player:getGuild():getId().." AND `accepted` = 0 AND `rejected` = 0")
	local revoke = 0
			repeat
			if check then
				revoke = revoke + 1
			end
			until not result.next(check)
			result.free(check)
	--end of Aqui vou checar se é possivel habilitar o botao revoke
	--aqui vou checar se é possivel habilitar o botao reject
	local check = db.storeQuery("SELECT * FROM `guild_warmode` WHERE `challenged` = "..player:getGuild():getId().." AND `rejected` = 0 AND `accepted` = 0")
	local reject = 0
	repeat
			if check then
				reject = reject + 1
			end
			until not result.next(check)
			result.free(check)

	--end of aqui vou checar se é possivel habilitar o botao reject
	local title = "Honera Warmode Anti Entrosa!"
    local message = "Bem vindo ao Warmode Anti Entrosa!\n\nPara fechar esta janela presssione [ESC] \n\nOptions:\nInvite - Declarar Guerra\nAccept - Aceitar Declaracao de guerra\nRevoke- Apagar solicitacao de Guerra\nEnter - Entrar na war"
	if request >= 1 and reject >= 1 then
	message = "Bem vindo ao Warmode Anti Entrosa!\n\nPara fechar esta janela presssione [ESC] \n\nVoce tem solicitacoes pendentes"
	end
  
    local window = ModalWindow(1840, title, message)
	window:setDefaultEscapeButton(101)
	if revoke == 0 and request == 0 and revoke == 0 then
	window:addButton(102, "Invite")
	end
	if request >= 1 then
    window:addButton(103, "Info")
	end
	if revoke >= 1 then
	window:addButton(104, "Revoke")
	end
	if reject >= 1 then
	--window:addButton(105, "Reject")
	end
	window:sendToPlayer(player)
	
	warmodetemp[player:getGuid()] = nil
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Warmode!")

	return false
	
end

warmode:register()
