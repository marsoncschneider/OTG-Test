local pagsegurodelivery = GlobalEvent("pagsegurodelivery")

local coinsTabulation = {
	[1] = 10, --1 real = 10 coins
	[20] = 200,
	[35] = 350,
	[100] = 1000
}

local function pagsegurodeliveryRun()
	
	local registros = db.storeQuery('SELECT * FROM `pagseguro_transactions` where `status` = "DELIVERED"')      
	
	if registros ~= false then
		repeat	
			local account = result.getString(registros, 'name')
			local payamount = result.getNumber(registros, 'payment_amount')
			local transactioncode = result.getString(registros, 'transaction_code')
			
			print("PAGSEGURO: Acc: "..account.."", "Pay:"..payamount.." -> Coins:"..coinsTabulation[payamount].."", "Code:"..transactioncode.."")
			db.query('UPDATE `pagseguro_transactions` SET `status` = "ENTREGUE" WHERE `transaction_code` = "'..transactioncode..'"')
			db.query('UPDATE `accounts` SET `coins` = `coins` + '..coinsTabulation[payamount]..' WHERE `name` = "'..account..'"')
			
			until not result.next(registros)
		result.free(registros)
	end
	
	return true
end

function pagsegurodelivery.onThink(interval)
	pagsegurodeliveryRun()
	return true
end

print('>> PAGSEGURO DELIVERY by Marson')
pagsegurodelivery:interval(60000)
pagsegurodelivery:register()
