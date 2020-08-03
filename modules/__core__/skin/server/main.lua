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

local skinCommand = Command("skin", "admin", "Open the skin editor for you or someone else")
skinCommand:addArgument("player", "player", "The player to open the skin editor", true)

skinCommand:setHandler(function(player, args, baseArgs)

  local targetPlayer = args.player

  if (targetPlayer == nil) then
    targetPlayer = player
  end

  emitClient("esx:skin:openEditor", targetPlayer.source, targetPlayer.skin or nil)

end)

skinCommand:setRconAllowed(true)

skinCommand:register()