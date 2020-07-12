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
local utils = M("utils")
local IsDead

on('esx:ready', function()
	module.Init()
end)


on('esx:onPlayerSpawn', function() -- [LISTO]
	isDead = false
end)

on('esx:player:death', function(data) -- [LISTO]
	module.OnPlayerDeath()

	module.deathCause = function()
		if data.killedByPlayer then
			return _U('ambulancejob:player_killed_by_player', data.killerClientId, utils.weapon.getLabel(utils.weapon.getFromHash(data.deathCause).name))
			--return _U('ambulancejob:player_killed_by_player', data.killerServerId, utils.weapon.getLabel(utils.weapon.getFromHash(data.deathCause).name))
		else
			if data.deathCause == 0 then
				return _U('ambulancejob:player_suicide')
			else
				return _U('ambulancejob:player_killed_by_npc', utils.weapon.getLabel(utils.weapon.getFromHash(data.deathCause).name))
			end
		end
	end

end)


onServer('esx_ambulancejob:revive', function() -- [LISTO]
	local playerPed = PlayerPedId()
	local coords, heading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)
	emitServer('esx_ambulancejob:setDeathStatus', false)
	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Citizen.Wait(50)
	end

	local formattedCoords = {
		x = math.round(coords.x, 1),
		y = math.round(coords.y, 1),
		z = math.round(coords.z, 1)
	}
	module.RespawnPed(playerPed, formattedCoords, heading)

	StopScreenEffect('DeathFailOut')
	DoScreenFadeIn(800)
end)

---DEAD
onServer('esx_ambulancejob:dead', function() -- [COMPLEMENTO]
	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, 0)
end)

