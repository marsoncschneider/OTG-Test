local bless = TalkAction("!bless")

function bless.onSay(player, words, param)
	Blessings.BuyAllBlesses(player)
	checkWarmode()
	local version = player:getClient().version
	if version < 1200 then
		return player:sendAdventurerBlessing()
	else
		return  Blessings.sendBlessStatus(player)
	end
	
end

bless:register()
