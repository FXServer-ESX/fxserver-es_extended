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

on('esx:player:load', function(player)
  Identity.allFromPlayer(player, function(hasBeenFound, identities)
    if not(hasBeenFound) then
      emitClient("esx:character:request:select", player:getSource())
    else
      emitClient("esx:character:request:select", player:getSource(), identities)
    end
  end, true)
end)

onRequest('esx:character:creation', function(source, cb, data)

  local player = Player.fromId(source)

  Identity.registerForPlayer(data, player, cb)

end)

onRequest("esx:character:fetchSkin", function(source, cb, id)
  local player = Player.fromId(source)

  MySQL.Async.fetchScalar('SELECT skin FROM identities WHERE id = @identityId',
  {
    ['@identityId'] = id
  }, function(skin)

    if (skin) then
      return cb(json.decode(skin))
    end
    
    return cb(nil)
  end)
end)