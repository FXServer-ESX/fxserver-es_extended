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

onRequest('esx:identity:register', function(source, cb, data)

  local player = Player.fromId(source)

  Identity.registerForPlayer(data, player, cb)

end)

onRequest('esx:identity:selectIdentity', function(source, cb, identityId)

  local player = Player.fromId(source)

  Identity.findOne({id = identityId}, function(identity)
    if identity == nil then
      return cb(nil)
    end

    Identity.loadForPlayer(identity, player)

    cb(identity:serialize())
  end)

end)

onRequest('esx:cache:identity:get', function(source, cb, id)

  local player = Player.fromId(source)

  local instance = Identity.all[id]

  if instance then

    cb(true, {instance:serialize()})

  else

    Identity.allFromPlayer(player, cb, true)

  end

end)

onRequest('esx:identity:getSavedPosition', function(source, cb, id)
  local player = Player.fromId(source)

  MySQL.Async.fetchAll('SELECT position FROM identities WHERE id = @identityId AND owner = @owner', {
    ['@identityId'] = player:getIdentityId(),
    ['@owner']      = player.identifier
  }, function(result)
    if result then
      if result[1] then
        local pos = json.decode(result[1].position)
        cb(pos)
      else
        cb(false)
      end
    else
      cb(false)
    end
  end)
end)

onClient('esx:identity:updatePosition', function(position)
  local player = Player.fromId(source)

  MySQL.Async.execute('UPDATE identities SET position = @position WHERE id = @id AND owner = @owner', {
    ['@position'] = json.encode(position),
    ['@id']       = player:getIdentityId(),
    ['@owner']    = player.identifier
  })
end)