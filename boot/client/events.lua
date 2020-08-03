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

local module = ESX.Modules['boot']

-- Need a bit of core modules here
M('events')
local Menu = M('ui.menu')
local HUD  = M('game.hud')
local utils = M('utils')

on('esx:ready', function()
  AddTextEntry('FE_THDR_GTAO', 'ESX')
end)

onServer('esx:setMaxWeight', function(newMaxWeight) ESX.PlayerData.maxWeight = newMaxWeight end)

on('esx:onPlayerSpawn', function() ESX.IsDead = false end)
on('esx:onPlayerDeath', function() ESX.IsDead = true end)
AddEventHandler('skinchanger:loadDefaultModel', function() ESX.IsLoadoutLoaded = false end)

AddEventHandler('skinchanger:modelLoaded', function()

  	while not ESX.PlayerLoaded do
		Citizen.Wait(100)
	end

  emit('esx:restoreLoadout')

end)

on('esx:restoreLoadout', function()

  local playerPed = PlayerPedId()
	local ammoTypes = {}

	RemoveAllPedWeapons(playerPed, true)

	for k,v in ipairs(ESX.PlayerData.loadout) do
		local weaponName = v.name
		local weaponHash = GetHashKey(weaponName)

		GiveWeaponToPed(playerPed, weaponHash, 0, false, false)
		SetPedWeaponTintIndex(playerPed, weaponHash, v.tintIndex)

		local ammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)

		for k2,v2 in ipairs(v.components) do
			local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash

			GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
		end

		if not ammoTypes[ammoType] then
			AddAmmoToPed(playerPed, weaponHash, v.ammo)
			ammoTypes[ammoType] = true
		end
	end

	ESX.IsLoadoutLoaded = true
end)

onServer('esx:setAccountMoney', function(account)
	for k,v in ipairs(ESX.PlayerData.accounts) do
		if v.name == account.name then
			ESX.PlayerData.accounts[k] = account
			break
		end
	end

	if Config.EnableHud then
		HUD.UpdateElement('account_' .. account.name, {
			money = math.groupDigits(account.money)
		})
	end
end)

onServer('esx:addInventoryItem', function(item, count, showNotification)

  for k,v in ipairs(ESX.PlayerData.inventory) do
    if v.name == item then

      if v.type == 'item_weapon' then
        ESX.UI.ShowInventoryItemNotification(true, ESX.GetWeaponLabel(v.name), count - v.count)
      else
        ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
      end

			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(true, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

onServer('esx:removeInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then

      if v.type == 'item_weapon' then
        ESX.UI.ShowInventoryItemNotification(false, ESX.GetWeaponLabel(v.name), count - v.count)
      else
        ESX.UI.ShowInventoryItemNotification(false, v.label, math.abs(count - v.count))
      end

			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(false, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

onServer('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

onServer('esx:addWeapon', function(weaponName, ammo)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

  GiveWeaponToPed(playerPed, weaponHash, ammo, false, false)

  ESX.UI.ShowInventoryItemNotification(true, ESX.GetWeaponLabel(weaponName), 1)

end)

onServer('esx:addWeaponComponent', function(weaponName, weaponComponent)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)
	local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash

	GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
end)

onServer('esx:setWeaponAmmo', function(weaponName, weaponAmmo)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	SetPedAmmo(playerPed, weaponHash, weaponAmmo)
end)

onServer('esx:setWeaponTint', function(weaponName, weaponTintIndex)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	SetPedWeaponTintIndex(playerPed, weaponHash, weaponTintIndex)
end)

onServer('esx:removeWeapon', function(weaponName)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	RemoveWeaponFromPed(playerPed, weaponHash)
  SetPedAmmo(playerPed, weaponHash, 0) -- remove leftover ammo

  ESX.UI.ShowInventoryItemNotification(false, ESX.GetWeaponLabel(weaponName), 1)

end)

onServer('esx:removeWeaponComponent', function(weaponName, weaponComponent)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)
	local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash

	RemoveWeaponComponentFromPed(playerPed, weaponHash, componentHash)
end)

onServer('esx:teleport', function(coords)
	local playerPed = PlayerPedId()

	-- ensure decmial number
	coords.x = coords.x + 0.0
	coords.y = coords.y + 0.0
	coords.z = coords.z + 0.0

	utils.game.teleport(playerPed, coords)
end)

onServer('esx:setJob', function(job)
	if Config.EnableHud then
		HUD.UpdateElement('job', {
			job_label   = job.label,
			grade_label = job.grade_label
		})
	end
end)

onServer('esx:spawnVehicle', function(vehicleName)
	local model = (type(vehicleName) == 'number' and vehicleName or GetHashKey(vehicleName))

	if IsModelInCdimage(model) then
		local playerPed = PlayerPedId()
		local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)

		utils.game.createVehicle(model, playerCoords, playerHeading, function(vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		end)
	else
		emit('chat:addMessage', {args = {'^1SYSTEM', 'Invalid vehicle model.'}})
	end
end)

onServer('esx:newPickup', function(pickupId, label, playerId, type, name, components, tintIndex)

	local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
	local entityCoords, forwardVector = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
	local objectCoords = (entityCoords + forwardVector * 1.0)

	local function setupPickup(obj)

		SetEntityAsMissionEntity(obj, true, false)
		PlaceObjectOnGroundProperly(obj)
		FreezeEntityPosition(obj, true)
		SetEntityCollision(obj, false, true)

		ESX.Pickups[pickupId] = {
      id      = pickupId,
			obj     = obj,
			label   = label,
			inRange = false,
			coords  = objectCoords
		}

	end

	if type == 'item_weapon' then

		Citizen.CreateThread(function()

			local weaponHash = GetHashKey(name)

			ESX.Streaming.RequestWeaponAsset(weaponHash)
			local pickupObject = CreateWeaponObject(weaponHash, 50, objectCoords, true, 1.0, 0)
			SetWeaponObjectTintIndex(pickupObject, tintIndex)

			for k,v in ipairs(components) do
				local component = ESX.GetWeaponComponent(name, v)
				GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
			end

			setupPickup(pickupObject)

		end)

	else

		utils.game.createLocalObject('prop_money_bag_01', objectCoords, function(obj)
			setupPickup(obj)
		end)
	end
end)


onServer('esx:newMissingPickups', function(missingPickups)
	for pickupId,pickup in pairs(missingPickups) do
		local pickupObject = nil

		if pickup.type == 'item_weapon' then
			ESX.Streaming.RequestWeaponAsset(GetHashKey(pickup.name))
			pickupObject = CreateWeaponObject(GetHashKey(pickup.name), 50, pickup.coords.x, pickup.coords.y, pickup.coords.z, true, 1.0, 0)
			SetWeaponObjectTintIndex(pickupObject, pickup.tintIndex)

			for k,componentName in ipairs(pickup.components) do
				local component = ESX.GetWeaponComponent(pickup.name, componentName)
				GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
			end
		else
			utils.game.createLocalObject('prop_money_bag_01', pickup.coords, function(obj)
				pickupObject = obj
			end)

			while not pickupObject do
				Citizen.Wait(10)
			end
		end

		SetEntityAsMissionEntity(pickupObject, true, false)
		PlaceObjectOnGroundProperly(pickupObject)
		FreezeEntityPosition(pickupObject, true)
		SetEntityCollision(pickupObject, false, true)

		ESX.Pickups[pickupId] = {
			obj = pickupObject,
			label = pickup.label,
			inRange = false,
			coords = vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z)
		}
	end
end)

onServer('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			emit('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

onServer('esx:removePickup', function(pickupId)
	if ESX.Pickups[pickupId] and ESX.Pickups[pickupId].obj then
		utils.game.deleteObject(ESX.Pickups[pickupId].obj)
		ESX.Pickups[pickupId] = nil
	end
end)

onServer('esx:deleteVehicle', function(radius)
	local playerPed = PlayerPedId()

	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = utils.game.getVehiclesInArea(GetEntityCoords(playerPed), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Citizen.Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				utils.game.deleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = utils.game.getVehicleInDirection, 0

		if IsPedInAnyVehicle(playerPed, true) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Citizen.Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			utils.game.deleteVehicle(entity)
		end
	end
end)