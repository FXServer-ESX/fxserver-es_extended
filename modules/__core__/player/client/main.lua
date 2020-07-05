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

local interval

interval = ESX.SetInterval(100, function()

  if NetworkIsPlayerActive(PlayerId()) then
    ESX.ClearInterval(interval)
    emitServer('esx:player:join')
  end

end)

Citizen.CreateThread(function()
	local isDead = false

	while true do
		Citizen.Wait(0)
		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()

			if IsPedFatallyInjured(playerPed) and not isDead then
				isDead = true

				local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

				if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					Player:PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					Player:PlayerKilled(deathCause)
				end

			elseif not IsPedFatallyInjured(playerPed) then
				isDead = false
			end
		end
	end
end)
