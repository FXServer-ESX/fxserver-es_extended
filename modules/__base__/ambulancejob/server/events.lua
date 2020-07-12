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


--[[RegisterNetEvent('esx_ambulancejob:setDeathStatus')
AddEventHandler('esx_ambulancejob:setDeathStatus', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
		MySQL.Sync.execute('UPDATE users SET is_dead = @isDead WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier,
			['@isDead'] = isDead
		})
	end
end)--]]


--[[local playersHealing, deadPlayers = {}, {}

onClient('esx:onPlayerDeath', function(test)
	print(test)
	deadPlayers[source] = 'dead'
	--TriggerClientEvent('esx_ambulancejob:setDeadPlayers', -1, deadPlayers)
end)--]]


--M('player')
local migrate = M('migrate')

on("esx:db:ready", function() -- [LISTO]
	migrate.Ensure("ambulancejob", "base")
end)

onRequest('esx_ambulancejob:getDeathStatus', function(source, cb) -- [NO LISTO]
	player = Player.fromId(source)

	MySQL.Async.fetchScalar('SELECT is_dead FROM identities WHERE id = @identityId', {
		['@identityId'] = player:getIdentityId()
	}, function(isDead)
		if isDead == true then
			print(('[^2INFO^7] identityId %s attempted combat logging'):format(player:getIdentityId()))
		end
		cb(isDead)
	end)
end)

onClient('esx_ambulancejob:setDeathStatus', function(isDead)
	player = Player.fromId(source)

	if type(isDead) == 'boolean' then
		MySQL.Sync.execute('UPDATE identities SET is_dead = @isDead WHERE id = @identityId', {
			['@identityId'] = player:getIdentityId(),
			['@isDead'] = isDead
		})
	end
end)

