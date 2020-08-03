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

-- maybe change this with a class skin that inherit perstistance
-- so we can have utils functions to save/retrieve datas if we map player and skin ?
-- cb is optional
module.saveSkin = function(player, skin, cb)
  -- TODO: use ORM to prepare de query
  MySQL.Async.execute('UPDATE identities SET skin = @skin WHERE id = @identityId',
  {
    ['@skin'] = json.encode(skin),
    ['@identityId'] = player:getIdentityId()
  }, function(affectedRows)
    if (cb) then
      cb(skin)
    end
  end)
end

module.findSkin = function(player, cb)
  -- TODO: use ORM to prepare de query
  MySQL.Async.fetchScalar('SELECT skin FROM identities WHERE id = @identityId',
  {
    ['@identityId'] = player:getIdentityId()
  }, function(skin)

    if (skin) then
      return cb(json.decode(skin))
    end
    
    return cb(nil)
  end)
end