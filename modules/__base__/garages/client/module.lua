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
local camera = M("camera")

module.GarageMenuLocation        = vector3(227.6369, -990.8311, -99.06071)
module.GarageMenuLocationHeading = 205.80000305176

module.xoffset                   = 0.6
module.yoffset                   = 0.122
module.windowSizeX               = 0.25
module.windowSizY                = 0.15
module.statSizeX                 = 0.24
module.statSizeY                 = 0.01
module.statOffsetX               = 0.55
module.fastestVehicleSpeed       = 200
module.enableVehicleStats        = true

module.DrawDistance              = 100.0
module.ZDiff                     = 0.5
module.MinimumHealthPercent      = 0
module.IsInGarageMenu            = false

module.Zones = {
	MiltonDrive = {		
		VehicleSpawner = {
			Pos         = vector3(-800.4819, 333.4093, 84.763),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(-791.6684, 333.6367, 84.763),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-796.501, 302.271, 85.000),
			Heading     = 180.0
		}
	},
	
	SanAndreasAve = {
		VehicleSpawner = {
			Pos         = vector3(213.6633, -809.0292, 30.1),
			Size        = {x = 2.0, y = 2.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(221.1162, -806.5679, 29.8),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-34.79, -697.73, 32.34),
			Heading     = 350.42
		}
	},
	
	DidionWay = {
		VehicleSpawner = {
			Pos                 = vector3(-259.88, 395.19, 109.12),
			Size                = {x = 3.0, y = 3.0, z = 1.5},
			Type                = 27,
			MarkerColor         = {r = 0, g = 255, b = 0, a = 225},
			GarageMenuLocation = vector3(227.6369, -990.8311, -99.06071)
		},
		VehicleReturn = {
			Pos         = vector3(-264, 396.2157, 109.1),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-259.82, 397.33, 109.01),
			Heading     = 12.15
		}
	},
	
	ImaginationCt265 = {
		VehicleSpawner = {
			Pos         = vector3(-1129.65, -1072.38, 1.15),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225},
			GarageMenuLocation = vector3(227.6369, -990.8311, -99.06071)
		},
		VehicleReturn = {
			Pos         = vector3(-1121.867, -1065.195, 1.1),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-1126.48, -1069.065, 1.1),
			Heading     = 15.87
		}
	},
	
	SteeleWay1150 = {
		VehicleSpawner = {
			Pos         = vector3(-924.81, 211.54, 66.46),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(-931.3825, 213.0508, 66.47),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-931.5, 210.98, 66.46),
			Heading     = 12.15
		}
	},

	Route68 = {
		VehicleSpawner = {
			Pos         = vector3(986.5052, 2648.922, 39.2),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(994.3171, 2650.206, 39.2),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-931.5, 210.98, 66.46),
			Heading     = 12.15
		}
	},

	PaletoBlvd = {
		VehicleSpawner = {
			Pos         = vector3(-231.6472, 6350.395, 31.6),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(-225.2677, 6352.1, 31.2),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-931.5, 210.98, 66.46),
			Heading     = 12.15
		}
	},

	GrapeseedAve = {
		VehicleSpawner = {
			Pos        = vector3(2553.722, 4669.251, 33.1),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(2560.347, 4673.213, 33.2),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-931.5, 210.98, 66.46),
			Heading     = 12.15
		}
	},

	AlgonquinBlvd = {
		VehicleSpawner = {
			Pos         = vector3(1725.834, 3707.835, 33.3),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(1730.628, 3709.852, 33.3),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-931.5, 210.98, 66.46),
			Heading     = 12.15
		}
	},

	AltaSt = {
		VehicleSpawner = {
			Pos         = vector3(-298.0355, -990.6277, 30.2),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 0, g = 255, b = 0, a = 225}
		},
		VehicleReturn = {
			Pos         = vector3(-304.747, -988.2321, 30.2),
			Size        = {x = 3.0, y = 3.0, z = 1.5},
			Type        = 27,
			MarkerColor = {r = 255, g = 0, b = 0, a = 225}
		},
		VehicleSpawnPoint = {
			Pos         = vector3(-308.2314, -986.5532, 30.2),
			Heading     = 338.48635864258
		}
	}
}

module.Init = function()
	Citizen.CreateThread(function()	
		for k,v in pairs(module.Zones) do
			local blip = AddBlipForCoord(v.VehicleSpawner.Pos.x, v.VehicleSpawner.Pos.y, v.VehicleSpawner.Pos.z)

			SetBlipSprite (blip, 357)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.75)
			SetBlipColour (blip, 3)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Garage")
			EndTextCommandSetBlipName(blip)
		end
	end)
end

module.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

module.EnterGarage = function(zone)
	camera.start()
	module.mainCameraScene()
	camera.setPolarAzimuthAngle(250.0, 120.0)
	camera.setRadius(3.5)

	Citizen.CreateThread(function()
		local ped = PlayerPedId()

		local pos = vector3(227.6369, -990.8311, -99.06071)
		SetEntityCoords(ped, module.GarageMenuLocation)
		FreezeEntityPosition(ped, true)
		SetEntityVisible(ped, false)
	end)
end

module.ExitGarage = function()
	Citizen.CreateThread(function()
		local ped = PlayerPedId()

		FreezeEntityPosition(ped, false)
		SetEntityVisible(ped, true)
	end)

	emit('esx:identity:preventSaving', false)

	module.IsInGarageMenu = false
end

module.StartGarageRestriction = function()
	Citizen.CreateThread(function()
		while module.IsInGarageMenu do
			Citizen.Wait(0)

			DisableControlAction(0, 75,  true)
			DisableControlAction(27, 75, true)
		end
	end)
end

module.OpenGarageMenu = function(zone)

	module.savedPosition = module.CurrentActionData.zone.Pos

	DoScreenFadeOut(250)

	while not IsScreenFadedOut() do
	  Citizen.Wait(0)
	end

	module.StartGarageRestriction()
	module.EnterGarage(zone)

	module.IsInGarageMenu = true

	local items = {}

	request('garages:getOwnedVehicles', function(vehicles)
		if vehicles then
			for i=1, #vehicles, 1 do
				if vehicles[i].stored == 1 then
					local name  = GetDisplayNameFromVehicleModel(vehicles[i].vehicleProps.model)
					local plate = module.Trim(vehicles[i].vehicleProps.plate)
					local model = vehicles[i].vehicleProps.model

					local vehicleData = {
						name         = name,
						vehicleProps = vehicles[i].vehicleProps,
						plate        = plate,
						model        = model
					}

					items[#items + 1] = {type = 'button', name = model, label = name .. " [" .. plate .. "]", value = vehicleData}
				elseif vehicles[i].stored == 0 then
					local name  = GetDisplayNameFromVehicleModel(vehicles[i].vehicleProps.model)
					local plate = module.Trim(vehicles[i].vehicleProps.plate)

					local vehicleData = {
						name  = name,
						plate = plate
					}

					items[#items + 1] = {type = 'button', name = 'not_in_garage', label = name .. " - [NOT IN GARAGE]", value = vehicleData}
				end
			end

			items[#items + 1] = {name = 'exit', label = '>> Exit <<', type = 'button'}

			module.garageMenu = Menu('garages.garage', {
				title = "Garage",
				float = 'top|left', -- not needed, default value
				items = items
			})

			module.currentMenu = module.garageMenu

			module.garageMenu:on('item.click', function(item, index)
				if item.name == 'exit' then
					module.DeleteDisplayVehicleInsideGarage()
					module.DestroyGarageMenu()
					DoScreenFadeOut(1000)
		
					while not IsScreenFadedOut() do
						Citizen.Wait(0)
					end
		
					module.ExitGarage()
					module.ReturnPlayer(module.savedPosition)
					camera.destroy()
				elseif item.name == 'not_in_garage' then
					utils.ui.showNotification("Your " .. item.value.name .. " with the plates " .. item.value.plate .. " is not in the garage.")
				else
					module.commit(item.value)
				end
			end)
		end
	end)

	Citizen.Wait(500)

	camera.setPolarAzimuthAngle(220.0, 120.0)
	camera.setRadius(3.5)
	emit('esx:identity:preventSaving', true)

	DoScreenFadeIn(250)
end

module.OpenRetrievalMenu = function(vehicleData)
	local items = {}

	items[#items + 1] = {name = 'yes', label = '>> Yes <<', type = 'button', value = vehicle}
	items[#items + 1] = {name = 'no', label = '>> No <<', type = 'button'}

	if module.garageMenu.visible then
		module.garageMenu:hide()
	end

	module.retrievalMenu = Menu('garages.retrieval', {
		title = "Retrieve " .. vehicleData.name .. " from the garage?",
		float = 'top|left', -- not needed, default value
		items = items
	})
	
	module.currentMenu = module.retrievalMenu

	module.retrievalMenu:on('destroy', function()
		module.garageMenu:show()
	end)

	module.retrievalMenu:on('item.click', function(item, index)
		if item.name == 'no' then
			module.DeleteDisplayVehicleInsideGarage()
			module.currentDisplayVehicle = nil

			module.retrievalMenu:destroy()

			module.currentMenu = module.garageMenu

			module.garageMenu:focus()
		elseif item.name == 'yes' then
			request("garages:removeVehicleFromGarage", function(success)
				if success then

					local ped = PlayerPedId()

					DoScreenFadeOut(250)

					while not IsScreenFadedOut() do
					  Citizen.Wait(0)
					end

					module.DeleteDisplayVehicleInsideGarage()
					module.currentDisplayVehicle = nil
					module.retrievalMenu:destroy()
					module.DestroyGarageMenu()
					module.ExitGarage()
					camera.destroy()
					module.SpawnVehicle(vehicleData.vehicleProps.model, module.CurrentActionData.zoneSpawn.Pos, module.CurrentActionData.zoneSpawn.Heading, function(vehicle)
						TaskWarpPedIntoVehicle(ped, vehicle, -1)
						module.SetVehicleProperties(vehicle, vehicleData.vehicleProps)
						SetVehicleNumberPlateText(vehicle, vehicleData.vehicleProps.plate)
						FreezeEntityPosition(ped, false)
						SetEntityVisible(ped, true)
					end)

					Citizen.Wait(500)

					utils.ui.showNotification("You have taken your vehicle out of the garage.")

					DoScreenFadeIn(250)
				end
			end, vehicleData.vehicleProps.plate)
		end
	end)
end

on('ui.menu.mouseChange', function(value)
	if module.IsInGarageMenu then
		camera.setMouseIn(value)
	end
end)

module.SetVehicleProperties = function(vehicle, props)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleModKit(vehicle, 0)

		if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
		if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
		if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
		if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
		if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
		if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
		if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
		if props.color1 then SetVehicleColours(vehicle, props.color1, colorSecondary) end
		if props.color2 then SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2) end
		if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor) end
		if props.wheelColor then SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor) end
		if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
		if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

		if props.neonEnabled then
			SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
			SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
			SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
			SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
		end

		if props.extras then
			for extraId,enabled in pairs(props.extras) do
				if enabled then
					SetVehicleExtra(vehicle, tonumber(extraId), 0)
				else
					SetVehicleExtra(vehicle, tonumber(extraId), 1)
				end
			end
		end

		if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
		if props.xenonColor then SetVehicleXenonLightsColour(vehicle, props.xenonColor) end
		if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
		if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
		if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
		if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
		if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
		if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
		if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
		if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
		if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
		if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
		if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
		if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
		if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
		if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
		if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
		if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
		if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
		if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
		if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
		if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
		if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
		if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
		if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
		if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
		if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
		if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
		if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
		if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
		if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
		if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
		if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
		if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
		if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
		if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
		if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
		if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
		if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
		if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
		if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
		if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
		if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
		if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
		if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
		if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
		if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end

		if props.modLivery then
			SetVehicleMod(vehicle, 48, props.modLivery, false)
			SetVehicleLivery(vehicle, props.modLivery)
		end
	end
end

module.Round = function(value)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

module.GetVehicleProperties = function(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}

		for extraId=0, 12 do
			if DoesExtraExist(vehicle, extraId) then
				local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
				extras[tostring(extraId)] = state
			end
		end

		return {
			model             = GetEntityModel(vehicle),

			plate             = module.Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = module.Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = module.Round(GetVehicleEngineHealth(vehicle), 1),
			tankHealth        = module.Round(GetVehiclePetrolTankHealth(vehicle), 1),

			fuelLevel         = module.Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = module.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),
			xenonColor        = GetVehicleXenonLightsColour(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleLivery(vehicle)
		}
	else
		return
	end
end

module.SpawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
  
	  Citizen.CreateThread(function()
		  module.RequestModel(model)
  
		  local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		  local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		  local timeout = 0
  
		  SetNetworkIdCanMigrate(networkId, true)
		  SetEntityAsMissionEntity(vehicle, true, false)
		  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		  SetVehicleNeedsToBeHotwired(vehicle, false)
		  SetVehRadioStation(vehicle, 'OFF')
		  SetModelAsNoLongerNeeded(model)
		  RequestCollisionAtCoord(coords.x, coords.y, coords.z)
  
		  -- we can get stuck here if any of the axies are "invalid"
		  while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			  Citizen.Wait(0)
			  timeout = timeout + 1
		  end
  
		  if cb then
			  cb(vehicle)
		  end
	end)
end

module.showVehicleStats = function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if module.vehicleLoaded then
				local playerPed = PlayerPedId()

				if IsPedSittingInAnyVehicle(playerPed) then
					local vehicle = GetVehiclePedIsIn(playerPed, false)

					if DoesEntityExist(vehicle) then
						local model            = GetEntityModel(vehicle, false)
						local hash             = GetHashKey(model)

						local topSpeed         = GetVehicleMaxSpeed(vehicle) * 3.6
						local acceleration     = GetVehicleModelAcceleration(model)
						local gears            = GetVehicleHighGear(vehicle)
						local capacity         = GetVehicleMaxNumberOfPassengers(vehicle) + 1

						local topSpeedStat     = (((topSpeed / module.fastestVehicleSpeed) / 2) * module.statSizeX)
						local accelerationStat = (((acceleration / 1.6) / 2) * module.statSizeX)
						local gearStat         = tostring(gears)
						local capacityStat     = tostring(capacity)

						if topSpeedStat > 0.24 then
							topSpeedStat = 0.24
						end

						if accelerationStat > 0.24 then
							accelerationStat = 0.24
						end
			
						module.RenderBox(module.xoffset - 0.05, module.windowSizeX, (module.yoffset - 0.0325), module.windowSizY, 0, 0, 0, 225)

						module.DrawText("Top Speed", module.xoffset - 0.146, module.yoffset - 0.105)
						module.RenderBox(module.statOffsetX, module.statSizeX, (module.yoffset - 0.07), module.statSizeY, 60, 60, 60, 225)
						module.RenderBox(module.statOffsetX - ((module.statSizeX - topSpeedStat) / 2), topSpeedStat, (module.yoffset - 0.07), module.statSizeY, 0, 255, 255, 225)

						module.DrawText("Acceleration", module.xoffset - 0.138, module.yoffset - 0.065)
						module.RenderBox(module.statOffsetX, module.statSizeX, (module.yoffset - 0.03), module.statSizeY, 60, 60, 60, 225)
						module.RenderBox(module.statOffsetX - ((module.statSizeX - (accelerationStat * 4)) / 2), accelerationStat * 4, (module.yoffset - 0.03), module.statSizeY, 0, 255, 255, 225)

						module.DrawText("Gears", module.xoffset - 0.1565, module.yoffset - 0.025)
						module.DrawText(gearStat, module.xoffset + 0.068, module.yoffset - 0.025)

						module.DrawText("Seating Capacity", module.xoffset - 0.1275, module.yoffset + 0.002)
						module.DrawText(capacityStat, module.xoffset + 0.068, module.yoffset + 0.002)
					end
				end
			else
				break
			end
		end
	end)
end

module.RenderBox = function(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4)
end

module.DrawText = function(string, x, y)
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.5, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(2)
	SetTextEntry("STRING")
	AddTextComponentString(string)
	DrawText(x,y)
end

module.commit = function(vehicleData)
	local playerPed = PlayerPedId()

	module.DeleteDisplayVehicleInsideGarage()

	module.WaitForVehicleToLoad(vehicleData.model)

	module.SpawnLocalVehicle(vehicleData.model, module.GarageMenuLocation, module.GarageMenuLocatioHeading, function(vehicle)
		module.currentDisplayVehicle = vehicle
		
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

		module.SetVehicleProperties(vehicle, vehicleData.vehicleProps)

		FreezeEntityPosition(vehicle, true)

		local model = GetEntityModel(vehicle)

		SetModelAsNoLongerNeeded(model)

		module.OpenRetrievalMenu(vehicleData)

		module.vehicleLoaded = true
		if module.enableVehicleStats then
			module.showVehicleStats()
		end
	end)
end

module.WaitForVehicleToLoad = function(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName("Please wait for the model to load...")
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

module.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		module.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
		local timeout = 0

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb then
			cb(vehicle)
		end
	end)
end

module.RequestModel = function(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

module.DeleteDisplayVehicleInsideGarage = function()
	local attempt = 0

	if module.currentDisplayVehicle and DoesEntityExist(module.currentDisplayVehicle) then
		while DoesEntityExist(module.currentDisplayVehicle) and not NetworkHasControlOfEntity(module.currentDisplayVehicle) and attempt < 100 do
			Citizen.Wait(100)
			NetworkRequestControlOfEntity(module.currentDisplayVehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(module.currentDisplayVehicle) and NetworkHasControlOfEntity(module.currentDisplayVehicle) then
			module.DeleteVehicle(module.currentDisplayVehicle)
			module.currentDisplayVehicle = nil
			module.vehicleLoaded = false
		end
	end
end

module.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end


module.ReturnPlayer = function(pos)
	local ped = PlayerPedId()
	SetEntityCoords(ped, pos)

	Citizen.Wait(500)
	DoScreenFadeIn(250)
end

module.DestroyGarageMenu = function()
	module.garageMenu:destroy()
end

module.StoreVehicle = function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)

		if DoesEntityExist(vehicle) then
			local plate        = module.Trim(GetVehicleNumberPlateText(vehicle))
			local vehicleProps = module.GetVehicleProperties(vehicle)

			request('garages:checkOwnedVehicle', function(result)
				if result then
					emitServer('garages:updateVehicle', plate, vehicleProps)
					emitServer('garages:storeVehicle', plate)
					DoScreenFadeOut(250)

					while not IsScreenFadedOut() do
					Citizen.Wait(0)
					end

					module.DeleteVehicle(vehicle)

					Citizen.Wait(500)
					utils.ui.showNotification("You have stored your vehicle in the garage.")
					DoScreenFadeIn(250)
				end
			end, plate)
		end
	end

	module.CurrentAction = nil
end

function module.mainCameraScene()
	local ped       = GetPlayerPed(-1)
	local pedCoords = GetEntityCoords(ped)
	local forward   = GetEntityForwardVector(ped)
  
	camera.setRadius(1.25)
	camera.setCoords(pedCoords + forward * 1.25)
	camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  
	camera.pointToBone(SKEL_ROOT)
end