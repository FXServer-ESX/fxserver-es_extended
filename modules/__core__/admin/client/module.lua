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

local utils = M('utils')
local input = M('input')
M('ui.hud')

module.Frame = nil
module.isOpeningAdminMenu = false

module.OnSelfCommand = function(action, ...)
  module[action](...)
end

module.Init = function()
  -- KeyInput Constructors
  local keyAdminMenu = KeyInput(input.KeyBindings.F9, 'Open Admin Menu', true)

  keyAdminMenu:onPress(function()
    module.openAdminMenu()
  end)

  RegisterCommand("adminmenu", function()
    module.openAdminMenu()
  end, false)

  module.Frame = Frame('admin', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/admin/data/build/index.html', false)

  module.Frame:on('close', function()
    module.closeAdminMenu()
  end)

  module.Frame:on('kick', function(data)
    module.KickPlayer(data.id, data.reason)
  end)

  module.Frame:on('ban', function(data)
    module.BanPlayer(data.id, data.reason)
  end)
end

module.openAdminMenu = function()

  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    -- if we're already loading players, exit
    if module.isOpeningAdminMenu then
      return
    end

    module.isOpeningAdminMenu = true
    request("esx:admin:getPlayers", function(players)
      if not(players == nil) then
        -- map properties that are required, maybe there's a better way to do this (?)
        local dataTable = {}
        for i, v in ipairs(players) do
          dataTable[i] = {
            name        = v.name,
            identity    = v.identity,
            source      = v.source,
            identifier  = v.identifier
          }
        end

        module.Frame:postMessage({
          action = 'updatePlayers',
          data = dataTable
        })
        module.Frame:show()
        module.Frame:focus(true)
      end
      module.isOpeningAdminMenu = false
    end)

  end)

end

module.closeAdminMenu = function()
  module.Frame:hide()
  module.Frame:unfocus()
end

module.KickPlayer = function(playerId, reason)
  emitServer("esx:admin:kickPlayer", playerId, reason)
  local playerName = GetPlayerName(playerId)
  TriggerServerEvent('toDiscord', '**Player kicked.** Player: '..playerName.. ' Reason: '..reason.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
end

module.BanPlayer = function(playerId, reason)
  emitServer("esx:admin:banPlayer", playerId, reason)
  TriggerServerEvent('toDiscord', '**Player banned.** Player: '..playerName.. ' Reason: '..reason.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
end

module.SpawnProp = function(sourceId, propname)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    local count = 0

    RequestModel(propname)

    while not HasModelLoaded(propname) do
      if count >= 100 then
        break
      end

      count = count + 1
      Wait(10)
    end

    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId() , true))
    local prop = CreateObjectNoOffset(GetHashKey(propname), x, y, z, true, true, true)
    PlaceObjectOnGroundProperly(prop)
    TriggerServerEvent('toDiscord', '**Prop placed.** Prop: '..propname.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
  end, sourceId)
end

module.TeleportToMarker = function(sourceId)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    local waypoint = GetFirstBlipInfoId(8)

    if DoesBlipExist(waypoint) then
      local waypointCoords = GetBlipInfoIdCoord(waypoint)

      local playerPed = PlayerPedId()

      for height = 1, 1000, 10 do
        SetPedCoordsKeepVehicle(playerPed, waypointCoords["x"], waypointCoords["y"], height + 0.0)

        local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], 2500.0)

        if foundGround then
          SetPedCoordsKeepVehicle(playerPed, vector3(waypointCoords["x"], waypointCoords["y"], zPos))
          break
        end

        Wait(60)
      end

      utils.ui.showNotification(_U('admin_result_tp'))
      TriggerServerEvent('toDiscord', '**Serveradmin teleported to waypoint.** Waipoint: '..waypointCoords.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
    else
      utils.ui.showNotification(_U('admin_result_teleport_to_marker'))
    end
  end, sourceId)
end

module.TeleportToPlayer = function(sourceId, coords)
  request("esx:admin:isAuthorized", function(a)
    if a then	utils.game.teleport(PlayerPedId(), coords)	end
  end, sourceId)
end

module.TeleportPlayerToMe = function(sourceId, coords)
  request("esx:admin:isAuthorized", function(a)
    if a then	utils.game.teleport(PlayerPedId(), coords)	end
  end, sourceId)
end

module.TeleportToCoords = function(sourceId, x, y, z)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end
    SetPedCoordsKeepVehicle(PlayerPedId(), x, y, z)
    utils.ui.showNotification(_U('admin_result_tp'))
  end, sourceId)
end

module.WarpPlayerIntoVehicle = function(networkId)

  while not NetworkDoesEntityExistWithNetworkId(networkId) do
    Wait(0)
  end

  local vehicle = NetworkGetEntityFromNetworkId(networkId)

  if IsEntityAVehicle(vehicle) then
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
  end
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
      TriggerServerEvent('toDiscord', '**Vehicle spawned.** Vehicle: '..model.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
    else
      utils.ui.showNotification(_U('admin_invalid_vehicle_model'))
    end
  end, sourceId)
end

module.DeleteVehicle = function(sourceId, radius)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, true) then
      module.delVehicle(GetVehiclePedIsIn(playerPed, false))
    else
      if radius and tonumber(radius) then
        local vehicles = utils.game.getVehiclesInArea(GetEntityCoords(playerPed), tonumber(radius) + 0.01)

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

    local playerPed = PlayerPedId()
    local playerId = PlayerId()

    if action == 'freeze' then
      FreezeEntityPosition(playerPed, true)
      SetEntityCollision(playerPed, false)
      SetPlayerInvincible(playerId, true)
      utils.ui.showNotification(_U('admin_result_freeze'))
      local playerName = GetPlayerName(playerPed)
      TriggerServerEvent('toDiscord', '**Player freezed.** Player: '..playerName.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
    elseif action == 'unfreeze' then
      FreezeEntityPosition(playerPed, false)
      SetEntityCollision(playerPed, true)
      SetPlayerInvincible(playerId, false)
      utils.ui.showNotification(_U('admin_result_unfreeze'))
      local playerName = GetPlayerName(playerPed)
      TriggerServerEvent('toDiscord', '**Player unfreezed.** Player: '..playerName.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
    end
  end, sourceId)
end

module.RevivePlayer = function(sourceId)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    local playerPed = PlayerPedId()
    local playerName = GetPlayerName(PlayerPedId)

    NetworkResurrectLocalPlayer(GetEntityCoords(playerPed), true, true, false)

    ClearPedBloodDamage(playerPed)
    ClearPedLastDamageBone(playerPed)
    ResetPedVisibleDamage(playerPed)
    ClearPedLastWeaponDamage(playerPed)
    RemoveParticleFxFromEntity(playerPed)
    utils.ui.showNotification(_U('admin_result_revive'))
    TriggerServerEvent('toDiscord', '**Player revived.** Player: '..playerName.. '', 'https://discord.com/api/webhooks/842304699642282005/n1I4xeWuBduOPdCXWY8ufmPrYb3iVBwgB1KyUV6ZYHZTgmHYC_VSDk0UZPxErZcqE97o')
  end, sourceId)
end

module.GetUserCoords = function(sourceId, targetId, firstName, lastName, coords)
  request("esx:admin:isAuthorized", function(a)
    if targetId and coords.x and coords.y and coords.z then
      print(_U('admin_get_player_coords_result', targetId, firstName, lastName, coords.x, coords.y, coords.z))
      utils.ui.showNotification(_U('admin_get_player_coords_result', targetId, firstName, lastName, coords.x, coords.y, coords.z))
    else
      utils.ui.showNotification(_U('admin_get_player_coords_error'))
    end
  end, sourceId)
end

module.GetPlayerList = function(sourceId, data)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    for _,value in ipairs(data) do
      print(_U('admin_get_players', value.id, value.name, value.firstname, value.lastname, value.ping))
    end
  end, sourceId)
end

module.SpectatePlayer = function(sourceId, targetId)
  if module.CancelCurrentAction then
    return utils.ui.showNotification(_U('admin_result_current_active'))
  end

  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    local playerPed = PlayerPedId()

    local coords = GetEntityCoords(PlayerPedId())

    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)
    RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(targetId)))
    NetworkSetInSpectatorMode(1, targetId)

    module.CancelCurrentAction = function()
      Interact.StopHelpNotification()

      FreezeEntityPosition(playerPed, false)
      RequestCollisionAtCoord(coords)
      NetworkSetInSpectatorMode(0, targetId)
      SetEntityVisible(playerPed, true, true)

      utils.game.teleport(playerPed, coords)
    end

    Interact.ShowHelpNotification(_U('admin_result_spectate'))
  end, sourceId)
end

module.SetPlayerHealth = function(sourceId, health)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    local playerPed = PlayerPedId()
    local maxHealth = GetPedMaxHealth(playerPed)

    if health >= maxHealth then
      SetEntityHealth(playerPed, maxHealth)

      utils.ui.showNotification(_U('admin_result_health'))
    elseif health <= 0 then
      SetEntityHealth(playerPed, health)

      utils.ui.showNotification(_U('admin_result_killed'))
    elseif health > 0 and health < maxHealth then
      SetEntityHealth(playerPed, health)

      utils.ui.showNotification(_U('admin_result_health'))
    end
  end, sourceId)
end

module.SetPlayerArmor = function(sourceId, armor)
  request("esx:admin:isAuthorized", function(a)
    if not a then return end

    SetPedArmour(PlayerPedId(), armor)
    utils.ui.showNotification(_U('admin_result_armor'))
  end, sourceId)
end
