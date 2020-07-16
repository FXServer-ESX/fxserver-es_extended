-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

local Command = M("events")
local migrate = M('migrate')

on("esx:db:ready", function()
	migrate.Ensure("vehicleshop", "base")
end)

onClient('vehicleshop:updateVehicle', function(vehicleProps, plate)
  MySQL.Async.execute('UPDATE vehicles SET vehicle = @vehicle WHERE plate = @plate', {
		['@plate']   = plate,
		['@vehicle'] = json.encode(vehicleProps)
	})
end)

onRequest("vehicleshop:checkOwnedVehicle", function(source, cb, plate)
	local player = Player.fromId(source)

	if player then
		MySQL.Async.fetchAll('SELECT 1 FROM vehicles WHERE plate = @plate AND id = @identityId AND owner = @owner', {
			['@plate']      = plate,
			['@identityId'] = player:getIdentityId(),
			['@owner']      = player.identifier
		}, function(result)
			if result then
				if result[1] then
				cb(true)
				else
					cb(false)
				end
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end)

onRequest("vehicleshop:buyVehicle", function(source, cb, model, plate, price, formattedPrice)
	local player = Player.fromId(source)
	local playerData = player:getIdentity()

	if player then
		MySQL.Async.execute('INSERT INTO vehicles (id, owner, plate, vehicle) VALUES (@id, @owner, @plate, @vehicle)', {
			['@id']         = player:getIdentityId(),
			['@owner']      = player.identifier,
			['@plate']      = plate,
			['@vehicle']    = json.encode({model = GetHashKey(model), plate = plate}),
		}, function(rowsChanged)
			-- print(playerData:getFirstName() .. " " .. playerData:getLastName() .. " bought a " .. model .. " for $" .. tostring(formattedPrice))
			cb(true)
		end)
	else
		cb(false)
	end
end)

onRequest("vehicleshop:sellVehicle", function(source, cb, plate, resellPrice)
	MySQL.Async.execute('DELETE FROM vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(rowsChanged)
		cb(true)
	end)
end)

onRequest("vehicleshop:isPlateTaken", function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)

onRequest("vehicleshop:storeAllVehicles", function(source, cb, plate)
	MySQL.Async.execute('UPDATE vehicles SET stored = @stored', {
		['@stored'] = 1,
	}, function(rowsChanged)
		cb(true)
	end)
end)
