local fileToUpdate = "data/update.lua"
dofile(fileToUpdate)

local update = GlobalEvent("Update")
function update.onStartup()
	if updated then
		db.query("UPDATE `players` SET `posx` = 0, `posy` = 0, `posz` = 0;")
		local readFile = io.open(fileToUpdate,'r')
		if readFile then
			io.input(readFile)
			local str = io.read()
			io.close(readFile)
			local ae = string.match(str,"updated = true")
			if ae then
				afterUpdate = 'updated = false'
				local updateFile=io.open(fileToUpdate, "w")
				io.output(updateFile)
				io.write(afterUpdate)
				io.close(updateFile)
				print(">> All players sent to temple. Check if 'data/update.lua' contains 'updated = false'.")
			end
		end
	end
	
	for i = 1, #startupGlobalStorages do
		Game.setStorageValue(startupGlobalStorages[i], 0)
	end

	local time = os.time()
	db.asyncQuery('TRUNCATE TABLE `players_online`')

	-- reset Daily Reward status
	db.query('UPDATE `players` SET `isreward` = '..DAILY_REWARD_NOTCOLLECTED)

	-- reset storages and allow purchase of boost in the store
	db.query('UPDATE `player_storage` SET `value` = 0 WHERE `player_storage`.`key` = 51052')

	-- reset familiars message storage
	db.query('DELETE FROM `player_storage` WHERE `key` = '..Storage.PetSummonEvent10)
	db.query('DELETE FROM `player_storage` WHERE `key` = '..Storage.PetSummonEvent60)

	-- delete canceled and rejected guilds
	db.asyncQuery('DELETE FROM `guild_wars` WHERE `status` = 2')
	db.asyncQuery('DELETE FROM `guild_wars` WHERE `status` = 3')

	-- Delete guilds that are pending for 3 days
	db.asyncQuery('DELETE FROM `guild_wars` WHERE `status` = 0 AND (`started` + 72 * 60 * 60) <= ' .. os.time())

	db.asyncQuery('DELETE FROM `players` WHERE `deletion` != 0 AND `deletion` < ' .. time)
	db.asyncQuery('DELETE FROM `ip_bans` WHERE `expires_at` != 0 AND `expires_at` <= ' .. time)
	db.asyncQuery('DELETE FROM `market_history` WHERE `inserted` <= \z
	' .. (time - configManager.getNumber(configKeys.MARKET_OFFER_DURATION)))

	-- Move expired bans to ban history
	local banResultId = db.storeQuery('SELECT * FROM `account_bans` WHERE `expires_at` != 0 AND `expires_at` <= ' .. time)
	if banResultId ~= false then
		repeat
			local accountId = result.getNumber(banResultId, 'account_id')
			db.asyncQuery('INSERT INTO `account_ban_history` (`account_id`, `reason`, `banned_at`, \z
			`expired_at`, `banned_by`) VALUES (' .. accountId .. ', \z
			' .. db.escapeString(result.getString(banResultId, 'reason')) .. ', \z
			' .. result.getNumber(banResultId, 'banned_at') .. ', ' .. result.getNumber(banResultId, 'expires_at') .. ', \z
			' .. result.getNumber(banResultId, 'banned_by') .. ')')
			db.asyncQuery('DELETE FROM `account_bans` WHERE `account_id` = ' .. accountId)
		until not result.next(banResultId)
		result.free(banResultId)
	end

	-- Ferumbras Ascendant quest
	for i = 1, #GlobalStorage.FerumbrasAscendant.Habitats do
		local storage = GlobalStorage.FerumbrasAscendant.Habitats[i]
		Game.setStorageValue(storage, 0)
	end

	-- Check house auctions
	local resultId = db.storeQuery('SELECT `id`, `highest_bidder`, `last_bid`, (SELECT `balance` FROM \z
	`players` WHERE `players`.`id` = `highest_bidder`) AS `balance` FROM `houses` WHERE `owner` = 0 AND \z
	`bid_end` != 0 AND `bid_end` < ' .. time)
	if resultId ~= false then
		repeat
			local house = House(result.getNumber(resultId, 'id'))
			if house then
				local highestBidder = result.getNumber(resultId, 'highest_bidder')
				local balance = result.getNumber(resultId, 'balance')
				local lastBid = result.getNumber(resultId, 'last_bid')
				if balance >= lastBid then
					db.query('UPDATE `players` SET `balance` = ' .. (balance - lastBid) .. ' WHERE `id` = ' .. highestBidder)
					house:setOwnerGuid(highestBidder)
				end
				db.asyncQuery('UPDATE `houses` SET `last_bid` = 0, `bid_end` = 0, `highest_bidder` = 0, \z
				`bid` = 0 WHERE `id` = ' .. house:getId())
			end
		until not result.next(resultId)
		result.free(resultId)
	end

	-- Client XP Display Mode
	-- 0 = ignore exp rate /stage
	-- 1 = include exp rate / stage
	Game.setStorageValue(GlobalStorage.XpDisplayMode, 0)

	-- Hireling System
	HirelingsInit()

	-- Load otg-br-custom map (data/world/custom/otg-br-custom.otbm)
	loadCustomMap()
	
	
	return true
end
update:register()
