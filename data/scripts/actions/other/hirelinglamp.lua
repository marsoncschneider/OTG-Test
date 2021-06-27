local hirelingLamp = Action()

function hirelingLamp.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local spawnPosition = player:getPosition()
	-- MARSONMOD
	local hireName = string.gsub(""..item:getDescription(1).."", "%a hireling lamp.\nIt weighs 10.00 oz.\nThis mysterious lamp summons your very own personal hireling.\nThis item cannot be traded.\nThis magic lamp is the home of ", "")
	hireName = string.gsub(""..hireName.."", "%.", "")
	local resultId = db.storeQuery("SELECT `id` FROM `player_hirelings` WHERE `name`= '"..hireName.."'")
	local id
	if resultId then
		id = result.getNumber(resultId, 'id')
	else
		return false
	end
	result.free(resultId)
	--END OF MARSONMOD
	
	local hireling_id = id
	local house = spawnPosition and spawnPosition:getTile() and spawnPosition:getTile():getHouse() or nil
	if not house then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_FAILURE, "You may use this only inside a house.")
		return false
	elseif house:getDoorIdByPosition(spawnPosition) then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_FAILURE, "You cannot spawn a hireling on the door")
		return false
	elseif getHirelingByPosition(spawnPosition) then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_FAILURE, "You cannot spawn another hireling here.")
		return false
	elseif house:getOwnerGuid() ~= player:getGuid() then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_FAILURE, "You cannot spawn a hireling on another's person house.")
		return false
	end

	local hireling = getHirelingById(hireling_id)

	hireling:setPosition(spawnPosition)
	item:remove(1)
	hireling:spawn()
	spawnPosition:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

hirelingLamp:id(34070)
hirelingLamp:register()
