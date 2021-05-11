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
local migrate = M('migrate')

on("esx:db:ready", function()
  migrate.Ensure("skin", "core")
end)

onRequest("esx:skin:save", function(source, cb, gender, skin)
  local player = Player.fromId(source)

  MySQL.Async.execute('UPDATE identities SET skin = @skin, gender = @gender WHERE id = @id AND owner = @owner', {
    ['@id']     = player:getIdentityId(),
    ['@owner']  = player.identifier,
    ['@skin']   = json.encode(skin),
    ['@gender'] = gender
  }, function(rowsChanged)
    cb(true)
  end)
end)

onRequest('esx:skin:getSkin', function(source, cb)
  local player = Player.fromId(source)

  MySQL.Async.fetchScalar('SELECT skin FROM identities WHERE id = @identityId',
  {
    ['@identityId'] = player:getIdentityId()
  }, function(skin)

    if skin then
      cb(json.decode(skin))
    end

    cb(nil)
  end)
end)