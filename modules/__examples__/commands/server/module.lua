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

module.init = function()
  -- local pingCommand = Command("ping", "admin", "I'll return you a ping, for suuuure")
  -- pingCommand:addArgument("arg1", "player", "Player argument description")

  -- pingCommand:setHandler(function(player, args, baseArgs)
  --   print(player.identifier)
  --   print(args.arg1.identifier)
  -- end)

  -- pingCommand:register()

  -- module.registerAddGroupCommand()
  -- module.registerRemoveGroupCommand()
  module.registerPingCommand()
end

module.registerPingCommand = function()
  local pingCommand = Command("ping", "admin", "I'll return you a ping, for suuuure")
  pingCommand:addArgument("arg1", "player", "Player argument description")

  pingCommand:setHandler(function(player, args, baseArgs)
    print(player.identifier)
    print(args.arg1.identifier)
  end)

  pingCommand:register()

end