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

local lifeCommand = Command("life", "admin", "Send a message as a tweet")
  lifeCommand:addArgument("message", "string", "The message you want to send", true)

  lifeCommand:setHandler(function(player, args, baseArgs)

  local msg
  for k,v in pairs(baseArgs) do
    if msg then
      msg = msg .. ' ' .. v
    else
      msg = v
    end
  end

  local name = player:getName()

  emitClient('rpchat:sendLifeInvaderMessage', -1, player.source, msg, name)

end)

local meCommand = Command("me", "admin", "Send a message as a personal action")
  meCommand:addArgument("message", "string", "The message you want to send", true)

  meCommand:setHandler(function(player, args, baseArgs)
  
  local msg
  for k,v in pairs(baseArgs) do
    if msg then
      msg = msg .. ' ' .. v
    else
      msg = v
    end
  end

  if msg and player.source then
    emitClient('rpchat:sendMe', -1, player.source, msg)
  end
end)

lifeCommand:register()

meCommand:register()