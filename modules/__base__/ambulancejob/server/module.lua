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
local utils = M("utils")

-- COMMANDS
local reviveCommand = Command("revive", "admin", "A simple test huga huga")
reviveCommand:addArgument("PlayerID", "player", "Reviva a Player")

reviveCommand:setHandler(function(player, args, baseArgs)
  emitClient('esx_ambulancejob:revive', player.source)
end)

--Dead command
local deadCommand = Command("dead", "admin", "A simple test huga huga")
deadCommand:addArgument("PlayerID", "player", "Kill a Player")

deadCommand:setHandler(function(player, args, baseArgs)
  emitClient('esx_ambulancejob:dead', player.source)
end)

local testCommand = Command("test", "admin", "A simple test")

testCommand:setHandler(function(player, args, baseArgs)
  emitClient('ambulancejob:test', player.source)
end)

testCommand:register()
deadCommand:register() --Test for kill my self
reviveCommand:register()


  