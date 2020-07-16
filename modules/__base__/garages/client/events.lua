
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

on('garages:hasEnteredMarker', function(name, part)
	if part == 'VehicleSpawner' then
		for k,v in pairs(module.Zones) do
			if tostring(k) == tostring(name) then
				module.CurrentAction     = 'retrieve_vehicle'
				module.CurrentActionMsg  = tostring("Press ~INPUT_CONTEXT~ to take a an owned vehicle out of the garage.")
				module.CurrentActionData = {
					zone = v.VehicleSpawner,
					zoneSpawn = v.VehicleSpawnPoint
				}
			end
		end
	elseif part == "VehicleReturn" then
		for k,v in pairs(module.Zones) do
			if tostring(k) == tostring(name) then
				local playerPed = PlayerPedId()

				if IsPedSittingInAnyVehicle(playerPed) then
					local vehicle = GetVehiclePedIsIn(playerPed, false)
		
					if GetPedInVehicleSeat(vehicle, -1) == playerPed then
						local plate = module.Trim(GetVehicleNumberPlateText(vehicle))
						local model = GetEntityModel(vehicle)
						local name = GetDisplayNameFromVehicleModel(model)
						
						request('garages:checkOwnedVehicle', function(result)
							if result then
								module.CurrentAction     = 'store_vehicle'
								module.CurrentActionMsg  = tostring("Press ~INPUT_CONTEXT~ to return your ~y~" .. name .. "~s~ to the garage.")
								module.CurrentActionData = {
									vehicle = vehicle,
									label   = name,
									model   = model,
									plate   = plate,
									zone    = name
								}
							else
								module.CurrentAction    = 'not_owned'
								module.CurrentActionMsg = "~r~You must own this vehicle in order to use this marker."
							end
						end, plate)
					else
						module.CurrentAction    = 'not_driver'
						module.CurrentActionMsg = "~r~You must be in the driver seat in order to use this marker."
					end
				else
					module.CurrentAction    = 'not_in_car'
					module.CurrentActionMsg = "~r~You must be in a vehicle in order to use this marker."
				end
			end
		end
	end
end)

on('garages:hasExitedMarker', function(zone)
	module.CurrentAction = nil
end)