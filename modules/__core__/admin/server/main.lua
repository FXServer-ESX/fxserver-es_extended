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

local TPTMarker = Command("tptm", "admin", _U('admin:command_tptm'))
	TPTMarker:addArgument("player", "player", _U('commandgeneric_playerid'))

	TPTMarker:setRconAllowed(true)

	TPTMarker:setHandler(function(player, args)
		if not player then
			player = {source = Config.rconSecureCode}
			if not args.player then
				return print(_U('act_imp'))
			end
		end

		if not args.player then args.player = player end
		emitClient("esx:admin:inPlayerCommand", args.player.source, "TPTMarker", player.source)
end)

local TPTPlayer = Command("tptp", "admin", _U('admin:command_tptp'))
	TPTPlayer:addArgument("player", "player", _U('commandgeneric_playerid'))

	TPTPlayer:setHandler(function(player, args)
		if not args.player or args.player.source == player.source then
			return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('admin:command_error_self')}})
		end

		emitClient("esx:admin:inPlayerCommand", player.source, "TPTPlayer", player.source, args.player.source)
end)

local SpawnVehicleCommand = Command("car", "admin", _U('command_car'))
	SpawnVehicleCommand:addArgument("modelname", "string", _U('command_car_car'))

	SpawnVehicleCommand:setHandler(function(player, args)
		emitClient("esx:admin:inPlayerCommand", player.source, "SpawnVehicle", player.source, args.modelname)
end)

local DeleteVehicleCommand = Command("dv", "admin", _U('command_cardel'))
	DeleteVehicleCommand:addArgument("radius", "number", _U('command_cardel_radius'))

	DeleteVehicleCommand:setHandler(function(player, args)
		if not args.radius then args.radius = module.Config.deleteVehicleRadius end
		emitClient("esx:admin:inPlayerCommand", player.source, "DeleteVehicle", player.source, args.radius)
end)

local FreezePlayer = Command("freeze", "admin", _U('admin:command_freeze'))
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

local UnFreezePlayer = Command("unfreeze", "admin", _U('admin:command_unfreeze'))
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

local RevivePlayer = Command("revive", "admin", _U('admin:command_revive'))
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

local GetCoords = Command("coords", "admin", _U('admin:command_get_coords'))
	GetCoords:addArgument("player", "player", _U('commandgeneric_playerid'))

	GetCoords:setRconAllowed(true)

	GetCoords:setHandler(function(player, args)
		if not player then
			if args.player then
				return print(table.unpack(GetEntityCoords(GetPlayerPed(args.player.source))))
			end

			return print( ('%s - ?help: coords "PlayerId"'):format(_U('act_imp')))
		end

		if not args.player then args.player = player end
		emitClient("esx:admin:inPlayerCommand", player.source, "GetUserCoords", args.player.source)
end)

local GetPlayerList = Command("players", "admin", _U('admin:command_player_list'))

	GetPlayerList:setRconAllowed(true)

	GetPlayerList:setHandler(function(player)
		if not player then
			for _, playerId in ipairs(GetPlayers()) do
				print(('Player %s with id %i'):format(GetPlayerName(playerId), playerId))
			end

			return
		end

		emitClient("esx:admin:inPlayerCommand", player.source, "GetPlayerList", player.source)
end)

local SpectatePlayer = Command("spect", "admin", _U('admin:command_spectate'))
	SpectatePlayer:addArgument("player", "player", _U('commandgeneric_playerid'))

	SpectatePlayer:setHandler(function(player, args)
		if not args.player or args.player.source == player.source then
			return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('admin:command_error_self')}})
		end

		emitClient("esx:admin:inPlayerCommand", player.source, "SpectatePlayer", player.source, args.player.source)
end)

TPTMarker:register()

TPTPlayer:register()

SpawnVehicleCommand:register()

DeleteVehicleCommand:register()

FreezePlayer:register()

UnFreezePlayer:register()

RevivePlayer:register()

GetCoords:register()

GetPlayerList:register()

SpectatePlayer:register()
