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

onRequest('esx_clotheshop:pay', function()
  local player = xPlayer.fromId(source)
  player:removeMoney(module.Config.Price)
  player.showNotification(_U('clotheshop:you_paid', ESX.Math.GroupDigits(module.Config.Price)))
end)

-- TODO: Get Outfits