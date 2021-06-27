local serverInfo = TalkAction("!online")

function serverInfo.onSay(player, words, param)
	local soma = 0
	if spoofPlayers > 0 then
	soma = spoofPlayers
	else
	soma = Game.getPlayerCount()
	end

	local hasAccess = player:getGroup():getAccess()
	local players = Game.getPlayers()
	local playerCount = soma --spoof

	player:sendTextMessage(MESSAGE_INFO_DESCR, playerCount .. " players online.")
	return false
end

serverInfo:separator(" ")
serverInfo:register()
