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

-- Features based on admin module of @ArkSeyonet | @ali-exacute | @SkunFly, thanks.

-- local playerPed = PlayerPedId() 										-- do not use if not strictly necessary
-- local sourceI = GetPlayerServerId(PlayerId())			-- do not use if not strictly necessary

local Interact = M('interact')
local Input = M('input')
local utils = M('utils')

module.MenuHiddenList = {}
module.CancelCurrentAction = nil
module.WeaponList = nil

module.OnSelfCommand = function(action, ...)
	module[action](...)
end

module.Init = function()
	request("esx:admin:isAuthorized", function(isAdmin)
		if isAdmin then
			local wList = utils.weapon.getAll()

			module.WeaponList = {}

			for i=1, #wList, 1 do
				if not wList[i].name:match("VEHICLE_(%S+)") then
					table.insert(module.WeaponList, wList[i])
				end
			end

			Input.RegisterControl(Input.Groups.LOOK, Input.Controls.SCRIPTED_FLY_ZUP)

			Input.RegisterControl(Input.Groups.CELLPHONE_NAVIGATE, Input.Controls.FRONTEND_CANCEL)
		end
	end)
end

module.TPTMarker = function(sourceId)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if DoesBlipExist(GetFirstBlipInfoId(8)) then
			local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
	
			for height = 1, 1000, 10 do
	
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
	
				local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], 6000.0)
	
				if foundGround then
					SetPedCoordsKeepVehicle(PlayerPedId(), vector3(waypointCoords["x"], waypointCoords["y"], zPos))
					break
				end
	
				Citizen.Wait(20)
			end

			utils.ui.showNotification(_U('admin:command_tp_res'))
		else
			utils.ui.showNotification(_U('admin:command_tptm_waypoint'))
		end
	end, sourceId)
end

module.TPTPlayer = function(sourceId, playerId)
	request("esx:admin:isAuthorized", function(a)
		if a then	utils.game.teleport(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId))))	end
	end, sourceId)
end

module.SpawnVehicle = function(sourceId, vehicleName)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		local model = (type(vehicleName) == 'number' and vehicleName or GetHashKey(vehicleName))

		if IsModelInCdimage(model) then
			local playerPed = PlayerPedId()
			local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)

			utils.game.createVehicle(model, playerCoords, playerHeading, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			end)
		else
			TriggerEvent('chat:addMessage', {args = {'^1SYSTEM', 'Invalid vehicle model.'}})
		end
	end, sourceId)
end

module.DeleteVehicle = function(sourceId, radius)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if IsPedInAnyVehicle(PlayerPedId(), true) then
			module.delVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
		else
			if radius and tonumber(radius) then
				local vehicles = utils.game.getVehiclesInArea(GetEntityCoords(PlayerPedId()), tonumber(radius) + 0.01)

				for k,entity in ipairs(vehicles) do
					if not IsPedAPlayer(GetPedInVehicleSeat(entity, -1)) and not IsPedAPlayer(GetPedInVehicleSeat(entity, 0)) then -- prevent delete with people inside.
						module.delVehicle(entity)
					end
				end
			end
		end
	end, sourceId)
end

module.delVehicle = function(entity)
	local hasOwner = false

	-- maybe deprecated, read vehicle module to se how works now
	-- local plate = GetVehicleNumberPlateText(entity)

	-- if plate then     -- uncomment this prevent vehicle with owners(players) deleted   |   (if you use 8 digits in plate, need other method to validate this)
	-- 	plate, _ = plate:gsub( "%s+", "" )
	-- 	if plate:len() == 6 then
	-- 		hasOwner = true
	-- 	end
	-- end

	local attempt = 0
	NetworkRequestControlOfEntity(entity)
	SetVehicleHasBeenOwnedByPlayer(entity, false)

	while not NetworkHasControlOfEntity(entity) and attempt < 150 and DoesEntityExist(entity) do
		Citizen.Wait(20)
		NetworkRequestControlOfEntity(entity)
		attempt = attempt + 1
	end

	if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) and not hasOwner then
		utils.game.deleteVehicle(entity)
	end
end

module.FreezeUnfreeze = function(sourceId, action)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if action == 'freeze' then
			FreezeEntityPosition(PlayerPedId(), true)
			SetEntityCollision(PlayerPedId(), false)
			SetPlayerInvincible(PlayerId(), true)
			utils.ui.showNotification(_U('admin:command_freeze_res'))
		elseif action == 'unfreeze' then
			FreezeEntityPosition(PlayerPedId(), false)
			SetEntityCollision(PlayerPedId(), true)
			SetPlayerInvincible(PlayerId(), false)
			utils.ui.showNotification(_U('admin:command_unfreeze_res'))
		end
	end, sourceId)
end

module.RevivePlayer = function(sourceId)
	if IsEntityDead(PlayerPedId()) then
		request("esx:admin:isAuthorized", function(a)
			if not a then return end

			NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), true, true, false)

			ClearPedBloodDamage(PlayerPedId())
			ClearPedLastDamageBone(PlayerPedId())
			ResetPedVisibleDamage(PlayerPedId())
			ClearPedLastWeaponDamage(PlayerPedId())
			RemoveParticleFxFromEntity(PlayerPedId())
			utils.ui.showNotification(_U('admin:command_revive_res'))
		end, sourceId)
	end
end

module.GetUserCoords = function(targetId)
	print(table.unpack(GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(targetId)))))
end

module.GetPlayerList = function(sourceId)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		for _, playerId in ipairs(GetActivePlayers()) do
			print(('Player %s with id %i is in the server'):format(GetPlayerName(playerId), playerId))
		end
	end, sourceId)
end

module.SpectatePlayer = function(sourceId, targetId)
	if module.CancelCurrentAction then
		return utils.ui.showNotification(_U('admin:command_current_active'))
	end

	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		local coords = GetEntityCoords(PlayerPedId())

		FreezeEntityPosition(PlayerPedId(), true)
		SetEntityVisible(PlayerPedId(), false, false)
		RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(targetId)))
		NetworkSetInSpectatorMode(1, targetId)

		module.CancelCurrentAction = function()
			Interact.StopHelpNotification()

			FreezeEntityPosition(PlayerPedId(), false)
			RequestCollisionAtCoord(coords)
			NetworkSetInSpectatorMode(0, targetId)
			SetEntityVisible(PlayerPedId(), true, true)

			utils.game.teleport(PlayerPedId(), coords)
		end

		Interact.ShowHelpNotification("Press ~INPUT_FRONTEND_CANCEL~ to exit spectate mode.")
	end, sourceId)
end

module.SetPlayerHealth = function(sourceId, health)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if health == 100 then
			local tHealth = GetPedMaxHealth(PlayerPedId())
	
			SetEntityHealth(PlayerPedId(), tHealth)
		end

		if health == 0 then
			SetEntityHealth(PlayerPedId(), health)
		end

		utils.ui.showNotification(_U('admin:command_health_res'))
	end, sourceId)
end

module.SetPlayerArmor = function(sourceId, armor)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		SetPedArmour(PlayerPedId(), armor)
  	utils.ui.showNotification(_U('admin:command_armor_res'))
	end, sourceId)
end

module.GiveWeaponPlayer = function(sourceId, weaponName, ammo)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponName), ammo, false, true);
	end)
end
