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

M('events')
M('serializable')
M('cache')

Player = Extends(Serializable, 'Player')

function Player:constructor(data)

  self.super:ctor(data)

  if data.identityId == nil then
    self:field('identityId')
  end

end

function Player:killedByPlayer(killerSid, KillerCid, deathCause)

 local victimCoords = self:getCoords(true)
 local killerCoords = math.roundVec3(GetEntityCoords(GetPlayerPed(KillerCid)))

 local distance     = #(victimCoords - killerCoords)
 
  local data = {
    victimCoords = victimCoords,
    killerCoords = killerCoords,
    killedByPlayer = true,
    deathCause     = deathCause,
    distance       = math.round(distance, 1),
    killerServerId = killerServerId,
    killerClientId = killerClientId
  }

  emit('esx:player:death', data)
  emitServer('esx:player:death', data)

end

function Player:killed(deathCause)

  local victimCoords = self:getCoords(true)

  local data = {
    victimCoords = victimCoords,
    killedByPlayer = false,
    deathCause     = deathCause
	}

  emit('esx:player:death', data)
  emitServer('esx:player:death', data)

end

function Player:getCoords(rounded)

  local coords = GetEntityCoords(PlayerPedId())

  if (rounded) then
    print("try to round")
    return math.roundVec3(coords, 1)
  end

  return coords

end

PlayerCacheConsumer = Extends(CacheConsumer)

function PlayerCacheConsumer:provide(key, cb)

  request('esx:cache:player:get', function(exists, data)
    cb(exists, exists and Player(data) or nil)
  end, key)

end

Cache.player = PlayerCacheConsumer()


