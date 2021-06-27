local LEVEL_LOWER = 1
local LEVEL_SAME = 2
local LEVEL_HIGHER = 3

local DISTANCE_BESIDE = 1
local DISTANCE_CLOSE = 2
local DISTANCE_FAR = 3
local DISTANCE_VERYFAR = 4

local directions = {
	[DIRECTION_NORTH] = "north",
	[DIRECTION_SOUTH] = "south",
	[DIRECTION_EAST] = "east",
	[DIRECTION_WEST] = "west",
	[DIRECTION_NORTHEAST] = "north-east",
	[DIRECTION_NORTHWEST] = "north-west",
	[DIRECTION_SOUTHEAST] = "south-east",
	[DIRECTION_SOUTHWEST] = "south-west"
}

local messages = {
	[DISTANCE_BESIDE] = {
		[LEVEL_LOWER] = "is below you",
		[LEVEL_SAME] = "is standing next to you",
		[LEVEL_HIGHER] = "is above you"
	},
	[DISTANCE_CLOSE] = {
		[LEVEL_LOWER] = "is on a lower level to the",
		[LEVEL_SAME] = "is to the",
		[LEVEL_HIGHER] = "is on a higher level to the"
	},
	[DISTANCE_FAR] = "is far to the",
	[DISTANCE_VERYFAR] = "is very far to the"
}

function onCastSpell(creature, variant)
	
	local spoof, playerposx, playerposy , playerposz = 0
	local positionDifference = {x = 0, y = 0, z = 0}
	
	local target = Player(variant:getString())
	if not target or target:getGroup():getAccess() and not creature:getGroup():getAccess() then
		--Aqui como o player não está no game, consultar na DB
		local registros = db.storeQuery('SELECT `id`, `posx`, `posy`, `posz` FROM `players` WHERE `name` = "'..variant:getString()..'"')      
		if registros ~= false then
			spoof = 1 --player existe no banco de dados, porem não está online
			creature:getPosition():sendMagicEffect(CONST_ME_POFF)
			repeat	
				playerid = result.getNumber(registros, 'id')
				playerposx = result.getNumber(registros, 'posx')
				playerposy = result.getNumber(registros, 'posy')
				playerposz = result.getNumber(registros, 'posz')
			until not result.next(registros)
			result.free(registros)		
			local registros2 = db.storeQuery('SELECT `player_id` FROM `players_online` WHERE `player_id` = "'..playerid..'"') 
			if registros2 ~= false then
				result.free(registros2)
			else	--Aqui ele existe no banco de dados, mas nao está na tabela players_online
				creature:sendTextMessage(MESSAGE_FAILURE, 'A player with this name is not online')
				--creature:sendCancelMessage('A player with this name is not online') --OBS1
				return true
			end	
		else	--nesse ponto o player nao existe na DB
			creature:sendTextMessage(MESSAGE_FAILURE, 'A player with this name is not online')
			--creature:sendTextMessage(MESSAGE_INFO_DESCR, RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE) --OBS2
			creature:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true 	--se nao existe na DB retornar que ele não existe
		end	
	end
	local creaturePosition = creature:getPosition()
	
	
	if spoof == 1 then
		positionDifference = {x = creaturePosition.x - playerposx,	y = creaturePosition.y - playerposy,	z = creaturePosition.z - playerposz}
	else
		local targetPosition = target:getPosition()
		positionDifference = {x = creaturePosition.x - targetPosition.x,	y = creaturePosition.y - targetPosition.y,	z = creaturePosition.z - targetPosition.z}
		
	end
	
	local maxPositionDifference, direction = math.max(math.abs(positionDifference.x), math.abs(positionDifference.y))
	if maxPositionDifference >= 5 then
		local positionTangent = positionDifference.x ~= 0 and positionDifference.y / positionDifference.x or 10
		if math.abs(positionTangent) < 0.4142 then
			direction = positionDifference.x > 0 and DIRECTION_WEST or DIRECTION_EAST
			elseif math.abs(positionTangent) < 2.4142 then
			direction = positionTangent > 0 and (positionDifference.y > 0 and DIRECTION_NORTHWEST or DIRECTION_SOUTHEAST) or positionDifference.x > 0 and DIRECTION_SOUTHWEST or DIRECTION_NORTHEAST
			else
			direction = positionDifference.y > 0 and DIRECTION_NORTH or DIRECTION_SOUTH
		end
	end
	
	local level = positionDifference.z > 0 and LEVEL_HIGHER or positionDifference.z < 0 and LEVEL_LOWER or LEVEL_SAME
	local distance = maxPositionDifference < 5 and DISTANCE_BESIDE or maxPositionDifference < 101 and DISTANCE_CLOSE or maxPositionDifference < 275 and DISTANCE_FAR or DISTANCE_VERYFAR
	local message = messages[distance][level] or messages[distance]
	if distance ~= DISTANCE_BESIDE then
		message = message .. " " .. directions[direction]
	end
	
	creature:sendTextMessage(MESSAGE_INFO_DESCR, variant:getString() .. " " .. message .. ".")
	creaturePosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end
