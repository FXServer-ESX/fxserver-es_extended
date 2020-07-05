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

PlayerCacheConsumer = Extends(CacheConsumer)

function PlayerCacheConsumer:provide(key, cb)

  request('esx:cache:player:get', function(exists, data)
    cb(exists, exists and Player(data) or nil)
  end, key)

end

Cache.player = PlayerCacheConsumer()

function Player:PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
  local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance     = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {x = math.round(victimCoords.x, 1), y = math.round(victimCoords.y, 1), z = math.round(victimCoords.z, 1)},
		killerCoords = {x = math.round(killerCoords.x, 1), y = math.round(killerCoords.y, 1), z = math.round(killerCoords.z, 1)},

		killedByPlayer = true,
		deathCause     = deathCause,
		distance       = math.round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

  emit('esx:onPlayerDeath', data)
  emitServer('esx:onPlayerDeath', data)
end

function Player:PlayerKilled(deathCause)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = {x = math.round(victimCoords.x, 1), y = math.round(victimCoords.y, 1), z = math.round(victimCoords.z, 1)},

		killedByPlayer = false,
		deathCause     = deathCause
	}

  emit('esx:onPlayerDeath', data)
  emitServer('esx:onPlayerDeath', data)
end

