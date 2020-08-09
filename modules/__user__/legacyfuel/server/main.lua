--ESX = nil
--TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--RegisterServerEvent('LegacyFuel:PayFuel')
--AddEventHandler('LegacyFuel:PayFuel', function(price)
--	local xPlayer = ESX.GetPlayerFromId(source)
--	local amount  = round(price, 0)
--
--	xPlayer.removeMoney(amount)
--end)

local Vehicles = {}

RegisterServerEvent('LegacyFuel:UpdateServerFuelTable')
AddEventHandler('LegacyFuel:UpdateServerFuelTable', function(plate, fuel)
	local found = false

	for i = 1, #Vehicles do
		if Vehicles[i].plate == plate then 
			found = true
			
			if fuel ~= Vehicles[i].fuel then
				table.remove(Vehicles, i)
				table.insert(Vehicles, {plate = plate, fuel = fuel})
			end
			break 
		end
	end

	if not found then
		table.insert(Vehicles, {plate = plate, fuel = fuel})
	end
end)

RegisterServerEvent('LegacyFuel:CheckServerFuelTable')
AddEventHandler('LegacyFuel:CheckServerFuelTable', function(plate)
	for i = 1, #Vehicles do
		if Vehicles[i].plate == plate then
			local vehInfo = {plate = Vehicles[i].plate, fuel = Vehicles[i].fuel}

			TriggerClientEvent('LegacyFuel:ReturnFuelFromServerTable', source, vehInfo)

			break
		end
	end
end)

--RegisterServerEvent('LegacyFuel:CheckCashOnHand')
--AddEventHandler('LegacyFuel:CheckCashOnHand', function()
--	local xPlayer = ESX.GetPlayerFromId(source)
--	local cb 	  = xPlayer.getMoney()
--
--	TriggerClientEvent('LegacyFuel:RecieveCashOnHand', source, cb)
--end)

function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end
