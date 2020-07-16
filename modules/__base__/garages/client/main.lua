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

M('events')
M('serializable')
M('cache')
M('ui.menu')

local HUD   = M('game.hud')
local utils = M("utils")

module.Init()

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(PlayerPedId())
		
		module.IsInMarker = false
		module.LetSleep = true

		if IsPedInAnyVehicle(playerPed, false) then

			if module.CurrentAction == "VehicleSpawner" then
				module.CurrentAction = nil
			end

			for k,v in pairs(module.Zones) do
				if GetDistanceBetweenCoords(playerCoords, v.VehicleReturn.Pos, true) < module.DrawDistance then
					module.LetSleep = false
	
					if v.Type ~= -1 then
						DrawMarker_2(v.VehicleReturn.Type, v.VehicleReturn.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.VehicleReturn.Size.x, v.VehicleReturn.Size.y, v.VehicleReturn.Size.z, v.VehicleReturn.MarkerColor.r, v.VehicleReturn.MarkerColor.g, v.VehicleReturn.MarkerColor.b, v.VehicleReturn.MarkerColor.a, false, false, 2, true, nil, nil, false, true)
					end
	
					if GetDistanceBetweenCoords(playerCoords, v.VehicleReturn.Pos, true) < v.VehicleReturn.Size.x then
						module.IsInMarker    = true
						module.CurrentGarage = k
						module.CurrentPart   = 'VehicleReturn'
					end
				end
			end
		else
			if module.CurrentAction == "store_vehicle" then
				module.CurrentAction = nil
			end

			for k,v in pairs(module.Zones) do
				if GetDistanceBetweenCoords(playerCoords, v.VehicleSpawner.Pos, true) < module.DrawDistance then
					module.LetSleep = false

					if v.VehicleSpawner.Type ~= -1 then
						DrawMarker_2(v.VehicleSpawner.Type, v.VehicleSpawner.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.VehicleSpawner.Size.x, v.VehicleSpawner.Size.y, v.VehicleSpawner.Size.z, v.VehicleSpawner.MarkerColor.r, v.VehicleSpawner.MarkerColor.g, v.VehicleSpawner.MarkerColor.b, v.VehicleSpawner.MarkerColor.a, false, false, 2, true, nil, nil, false, true)
					end

					if GetDistanceBetweenCoords(playerCoords, v.VehicleSpawner.Pos, true) < v.VehicleSpawner.Size.x then
						module.IsInMarker    = true
						module.CurrentGarage = k
						module.CurrentPart   = 'VehicleSpawner'
					end
				end
			end
		end

		if module.IsInMarker and not module.HasAlreadyEnteredMarker or (module.IsInMarker and (module.LastGarage ~= module.CurrentGarage or module.LastPart ~= module.CurrentPart or module.LastParking ~= module.CurrentParking) ) then
			module.HasAlreadyEnteredMarker = true
			module.LastGarage              = module.CurrentGarage
			module.LastPart                = module.CurrentPart

			emit('garages:hasEnteredMarker', module.LastGarage, module.LastPart)
		end

		if not module.IsInMarker and module.HasAlreadyEnteredMarker then
			module.HasAlreadyEnteredMarker = false

			emit('garages:hasExitedMarker', module.LastGarage, module.LastPart)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if module.CurrentAction then
			utils.ui.showHelpNotification(module.CurrentActionMsg, false, false, 1)

			if IsControlJustReleased(0, 38) then
				if module.CurrentAction == 'retrieve_vehicle' then
					module.OpenGarageMenu(module.CurrentActionData)
				elseif module.CurrentAction == "store_vehicle" then
					module.StoreVehicle(module.CurrentActionData)
				end

				module.CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)