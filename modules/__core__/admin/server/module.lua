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

-- @TODO: Make the second run parameter optional
module.Config = run('data/config.lua', {})['Config']
local utils = M("utils")

module.GetPlayerCoords = function(playerId)
	if playerId then
		if GetPlayerPed(playerId) then
		  return GetEntityCoords(GetPlayerPed(playerId))
		else
			return nil
		end
	else
		return nil
	end
end

module.KickPlayer = function(playerId, reason)
	reason = reason or "You were kicked by a staff member."

  local playerName = GetPlayerName(playerId)

	DropPlayer(tostring(playerId), reason)

	-- Display a message in chat when a player in kicked
	if module.Config.enableChatMessageOnKick then
		utils.server.systemMessage(playerName .. " was kicked from the server.")
	end
end

module.BanPlayer = function(playerId, reason)
  local player = Player.fromId(playerId)

	reason = reason or "You were banned by a staff member."

	Ban.create({
    identifier = player:getIdentifier(),
    reason = reason
  }, function()
    local playerName = GetPlayerName(playerId)

    DropPlayer(tostring(playerId), reason)

    -- Display a message in chat when a player in banned
    if module.Config.enableChatMessageOnBan then
      utils.server.systemMessage(playerName .. " was banned from the server.")
    end

	end)
end
