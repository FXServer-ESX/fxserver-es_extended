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
local Cache   = M("cache")
local utils   = M("utils")

onClient('garages:updateVehicle', function(plate, vehicleProps)
  local player = Player.fromId(source)

  if player then
    Cache.UpdateVehicle(player.identifier, player:getIdentityId(), plate, vehicleProps)
  end
end)

onRequest('garages:storeVehicleInGarage', function(source, cb, plate)
  local player = Player.fromId(source)
  if player then
    local storeVehicle = Cache.StoreVehicle(player.identifier, player:getIdentityId(), plate)

    if storeVehicle then
      cb(true)
    else
      cb(false)
    end
  else
    cb(false)
  end
end)

onRequest('garages:removeVehicleFromGarage', function(source, cb, plate)
  local player = Player.fromId(source)
  local removeVehicle = Cache.RetrieveVehicle(player.identifier, player:getIdentityId(), plate)

  if removeVehicle then
    cb(true)
  else
    cb(false)
  end
end)

onRequest('garages:getOwnedVehicles', function(source, cb)
  local player = Player.fromId(source)
  local ownedVehicles = Cache.RetrieveOwnedVehicles(player.identifier, player:getIdentityId())

  if ownedVehicles then
    if ownedVehicles[1] then
      cb(ownedVehicles)
    else
      cb(nil)
    end
  end
end)

onRequest("garages:storeAllVehicles", function(source, cb, plate)
  MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE sold = @sold', {
    ['@stored'] = 1,
    ['@sold'] = 0
  }, function()
    print(_U('garages:returned_vehicles_to_garages_server'))
    cb(true)
  end)
end)
