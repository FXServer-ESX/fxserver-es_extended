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

onClient('chatMessage', function(playerId, playerName, message)
  CancelEvent()

  if string.sub(message, 1, string.len('/')) ~= '/' then

    local player = Player.fromId(playerId):getIdentity()
    local firstname = player:getFirstName()
    local lastname = player:getLastName()

    local arg = {args = {'OOC | ' .. firstname .. ' ' .. lastname, message}, color = {128, 128, 128}}

    if module.Config.proximityMode then
      emitClient('rpchat:proximitySendNUIMessage', -1, playerId, arg)
    else 
      emitClient('chat:addMessage', -1, arg)
    end

  end

end)
