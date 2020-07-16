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

onClient('garages:updateVehicle', function(plate, vehicleProps)
  MySQL.Async.execute('UPDATE vehicles SET vehicle = @vehicle WHERE plate = @plate', {
		['@vehicle'] = json.encode(vehicleProps),
		['@plate']   = plate,
	})
end)

onClient('garages:storeVehicle', function(plate)
  MySQL.Async.execute('UPDATE vehicles SET stored = @stored WHERE plate = @plate', {
		['@stored'] = 1,
		['@plate']  = plate,
	})
end)

onRequest('garages:checkOwnedVehicle', function(source, cb, plate)
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

onRequest('garages:removeVehicleFromGarage', function(source, cb, plate)
  MySQL.Async.execute('UPDATE vehicles SET stored = @stored WHERE plate = @plate', {
		['@stored'] = 0,
		['@plate']  = plate
	}, function(rowsChanged)
		cb(true)
	end)
end)

onRequest('garages:getOwnedVehicles', function(source, cb)
    local player = Player.fromId(source)

	if player then
		MySQL.Async.fetchAll('SELECT * FROM `vehicles` WHERE `id` = @id AND owner = @owner',
		{
			['@id']    = player:getIdentityId(),
			['@owner'] = player.identifier,
		}, function(result)

			local vehicles = {}
			for i=1, #result, 1 do
				table.insert(vehicles, {
					vehicleProps = json.decode(result[i].vehicle),
					stored       = result[i].stored
				})
			end

			cb(vehicles)

		end)
	else
		cb(nil)
	end
end)