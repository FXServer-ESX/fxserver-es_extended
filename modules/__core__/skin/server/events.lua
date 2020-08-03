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

local Command = M("events")
local migrate = M('migrate')

on("esx:db:ready", function()
  migrate.Ensure("skin", "core")
end)

onRequest("skin:save", function(source, cb, skin)
  local player = Player.fromId(source)
  player:field('skin', skin)
  module.saveSkin(player, skin, cb)
end)

onRequest("skin:getIdentitySkin", function(source, cb)
  local player = Player.fromId(source)

  module.findSkin(player, function(skin)
    player:field('skin', skin)  
    cb(skin)
  end)
end)