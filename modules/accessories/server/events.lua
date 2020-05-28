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

onRequest('esx_accessories:pay', function()

  local player = xPlayer.fromId(source)
  player:removeMoney(self.Config.Price)
  TriggerClientEvent('esx:showNotification', source, _U('accesories:you_paid', ESX.Math.GroupDigits(self.Config.Price)))

end)

onRequest('esx_accessories:save', function(skin, accessory)

	local _source     = source
	local player      = xPlayer.fromId(_source)
  local item1       = string.lower(accessory) .. '_1'
  local item2       = string.lower(accessory) .. '_2'
  local accessories = player:getAccessories()

  accessories[accessory] = {
    [item1] = skin[item1],
    [item2] = skin[item2],
  }

  player:setAccessories(accessories)

end)

onRequest('esx_accessories:get', function(source, cb, accessory)

  local player       = xPlayer.fromId(source)
  local skin         = player:getAccessories()[accessory]
  local hasAccessory = skin ~= nil

	cb(hasAccessory, skin)

end)

onRequest('esx_accessories:checkMoney', function(source, cb)

  local player = xPlayer.fromId(source)
  cb(player:getMoney() >= self.Config.Price)

end)
