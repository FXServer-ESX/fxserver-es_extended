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

M('command')
local utils = M('utils')

Config.rconSecureCode = utils.string.random(24, true)

local SpawnProp = Command("spawnprop", "admin", _U('admin_command_spawn_prop'))
SpawnProp:addArgument("propname", "string", _U('admin_command_propname'))
SpawnProp:setHandler(function(player, args)
  if args.propname then
    emitClient("esx:admin:inPlayerCommand", player.source, "SpawnProp", player.source, args.propname)
  end
end)

local TeleportToMarker = Command("tpm", "admin", _U('admin_command_tp_to_marker'))
TeleportToMarker:setHandler(function(player, args)

  emitClient("esx:admin:inPlayerCommand", player.source, "TeleportToMarker", player.source)
end)

local TeleportToPlayer = Command("tp", "admin", _U('admin_command_tp_to_player'))
TeleportToPlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
TeleportToPlayer:setHandler(function(player, args)
  if not args.player or args.player.source == player.source then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_self')}})
  end

  emitClient("esx:admin:inPlayerCommand", player.source, "TeleportToPlayer", player.source, GetEntityCoords(GetPlayerPed(args.player.source)))
end)

local TeleportPlayerToMe = Command("tptm", "admin", _U('admin_command_tp_to_me'))
TeleportPlayerToMe:addArgument("player", "player", _U('commandgeneric_playerid'))
TeleportPlayerToMe:setHandler(function(player, args)
  if not args.player or args.player.source == player.source then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_self')}})
  end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "TeleportPlayerToMe", player.source, GetEntityCoords(GetPlayerPed(player.source)))
end)

local TeleportToCoords = Command("tpc", "admin", _U('admin_command_tp_to_coords'))
TeleportToCoords:addArgument("x", "number", _U('commandgeneric_x'))
TeleportToCoords:addArgument("y", "number", _U('commandgeneric_y'))
TeleportToCoords:addArgument("z", "number", _U('commandgeneric_z'))
TeleportToCoords:setHandler(function(player, args)
  emitClient("esx:admin:inPlayerCommand", player.source, "TeleportToCoords", player.source, args.x + 0.0, args.y + 0.0, args.z + 0.0)
end)

local SpawnVehicleCommand = Command("car", "admin", _U('admin_command_car'))
SpawnVehicleCommand:addArgument("modelname", "string", _U('admin_command_car_hashname'))
SpawnVehicleCommand:setHandler(function(player, args)
  emitClient("esx:admin:inPlayerCommand", player.source, "SpawnVehicle", player.source, args.modelname)
end)

local DeleteVehicleCommand = Command("dv", "admin", _U('admin_command_cardel'))
DeleteVehicleCommand:addArgument("radius", "number", _U('admin_command_cardel_radius'))
DeleteVehicleCommand:setHandler(function(player, args)
  if not args.radius then args.radius = Config.Modules.Admin.deleteVehicleRadius end

  emitClient("esx:admin:inPlayerCommand", player.source, "DeleteVehicle", player.source, args.radius)
end)

local FreezePlayer = Command("freeze", "admin", _U('admin_command_freeze'))
FreezePlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
FreezePlayer:setRconAllowed(true)
FreezePlayer:setHandler(function(player, args)
  if not player then
    player = {source = Config.rconSecureCode}

    if not args.player then
      return print(_U('act_imp'))
    end
  end

  if not args.player then args.player = player end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "FreezeUnfreeze", player.source, "freeze")
end)

local UnFreezePlayer = Command("unfreeze", "admin", _U('admin_command_unfreeze'))
UnFreezePlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
UnFreezePlayer:setRconAllowed(true)
UnFreezePlayer:setHandler(function(player, args)
  if not player then
    player = {source = Config.rconSecureCode}

    if not args.player then
      return print(_U('act_imp'))
    end
  end

  if not args.player then args.player = player end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "FreezeUnfreeze", player.source, "unfreeze")
end)

local RevivePlayer = Command("revive", "admin", _U('admin_command_revive'))
RevivePlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
RevivePlayer:setRconAllowed(true)
RevivePlayer:setHandler(function(player, args)
  if not player then
    player = {source = Config.rconSecureCode}

    if not args.player then
      return print(_U('act_imp'))
    end
  end

  if not args.player then args.player = player end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "RevivePlayer", player.source)
end)

local GetCoords = Command("coords", "admin", _U('admin_command_get_coords'))
GetCoords:addArgument("player", "player", _U('commandgeneric_playerid'))
GetCoords:setRconAllowed(true)
GetCoords:setHandler(function(player, args)
  if not player then
    if args.player then
      return print(table.unpack(GetEntityCoords(GetPlayerPed(args.player.source))))
    end

    return print( ('%s - ?help: coords "%s"'):format(_U('act_imp'), _U('commandgeneric_playerid')))
  end

  if not args.player then args.player = player end

  local foundPlayer = Player.fromId(args.player.source)

  if foundPlayer then
    local playerData = foundPlayer:getIdentity()

    emitClient("esx:admin:inPlayerCommand", player.source, "GetUserCoords", player.source, args.player.source, playerData:getFirstName(), playerData:getLastName(), GetEntityCoords(GetPlayerPed(args.player.source)))
  end
end)

local GetPlayerList = Command("players", "admin", _U('admin_command_player_list'))
GetPlayerList:setRconAllowed(true)
GetPlayerList:setHandler(function(player)
  local dataTable = {}

  for _, playerId in ipairs(GetPlayers()) do
    local ply = Player.fromId(playerId)
    local playerData = ply:getIdentity()

    table.insert(dataTable, {
      name = GetPlayerName(playerId),
      firstname = playerData:getFirstName(),
      lastname = playerData:getLastName(),
      id = playerId,
      ping = GetPlayerPing(playerId)
    })

    -- print("Player ["..GetPlayerName(playerId).."] "..firstname.." "..lastname.."("..playerId..") - Ping: " .. ping)
    -- print(('Player %s with id %s ping = %s'):format(""..GetPlayerName(playerId).." | "..firstname..""..lastname, playerId, ping))
  end

  emitClient("esx:admin:inPlayerCommand", player.source, "GetPlayerList", player.source, dataTable)
end)

local SpectatePlayer = Command("spect", "admin", _U('admin_command_spectate_player'))
SpectatePlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
SpectatePlayer:setHandler(function(player, args)
  if not args.player or args.player.source == player.source then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_self')}})
  end

  emitClient("esx:admin:inPlayerCommand", player.source, "SpectatePlayer", player.source, args.player.source)
end)

local SetPlayerHealth = Command("health", "admin", _U('admin_command_set_player_health'))
SetPlayerHealth:addArgument("player", "player", _U('commandgeneric_playerid'))
SetPlayerHealth:addArgument("amount", "number", _U('commandgeneric_amount'))
SetPlayerHealth:setHandler(function(player, args)
  if not args.player then args.player = player end
  if not args.amount then args.amount = 100 end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "SetPlayerHealth", player.source, args.amount)
end)

local KillPlayer = Command("kill", "admin", _U('admin_command_kill_player'))
KillPlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
KillPlayer:setHandler(function(player, args)
  if not args.player then args.player = player end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "SetPlayerHealth", player.source, 0)
end)

local SetPlayerArmor = Command("armor", "admin", _U('admin_command_set_player_armor'))
SetPlayerArmor:addArgument("player", "player", _U('commandgeneric_playerid'))
SetPlayerArmor:addArgument("amount", "number", _U('commandgeneric_amount'))
SetPlayerArmor:setHandler(function(player, args)
  if not args.player then args.player = player end
  if not args.amount then args.amount = 100 end

  emitClient("esx:admin:inPlayerCommand", args.player.source, "SetPlayerArmor", player.source, args.amount)
end)

local KickPlayer = Command("kick", "admin", _U('admin_command_kick_player'))
KickPlayer:addArgument("player", "player", _U('commandgeneric_playerid'))
KickPlayer:addArgument("reason", "string", _U('commandgeneric_reason'))
KickPlayer:setRconAllowed(true)
KickPlayer:setHandler(function(player, args)
  if not args.player then args.player = player end

  local foundPlayer = Player.fromId(args.player.source)
  playerId = args.player.source

  if foundPlayer then
    module.KickPlayer(playerId, args.reason)
  end
end)

local KickAll = Command("kickall", "admin", _U('admin_command_kick_all_player'))
KickAll:setRconAllowed(true)
KickAll:setHandler(function(player, args)
  for _, playerId in ipairs(GetPlayers()) do
    local player = Player.fromId(playerId)
    DropPlayer(playerId, "You have been kicked in preparation for a pending server restart.")
  end
end)

SpawnProp:register()
TeleportToMarker:register()
TeleportToPlayer:register()
TeleportPlayerToMe:register()
TeleportToCoords:register()
SpawnVehicleCommand:register()
DeleteVehicleCommand:register()
FreezePlayer:register()
UnFreezePlayer:register()
RevivePlayer:register()
GetCoords:register()
GetPlayerList:register()
SpectatePlayer:register()
SetPlayerHealth:register()
KillPlayer:register()
SetPlayerArmor:register()
KickPlayer:register()
KickAll:register()
