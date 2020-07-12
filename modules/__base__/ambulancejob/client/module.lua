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

M('constants')
M('events')
M('ui.menu')
local utils = M("utils")
-- Properties
module.Config = run('data/config.lua', {vector3 = vector3})['Config']

local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
LoadLocale('ambulancejob', Config.Locale, translations)

local firstSpawn = true

module.Init = function()
	if firstSpawn then
		firstSpawn = false
		request('esx_ambulancejob:getDeathStatus', function(shouldDie)
			if shouldDie then
				utils.ui.showNotification(_U('ambulancejob:combatlog_message'))
				module.RemoveItemsAfterRPDeath()
			end
		end)
	end
end

module.RespawnPed = function(ped, coords, heading) --[LISTO]
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
	PlaySoundFrontend(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", 1)

	emitServer('esx:onPlayerSpawn')
	emit('esx:onPlayerSpawn')
end

module.OnPlayerDeath = function() --[NO LISTO]
	isDead = true
	--ESX.UI.Menu.CloseAll()
	emitServer('esx_ambulancejob:setDeathStatus', true)

	module.StartDeathTimer()
	--StartDistressSignal()

	AnimpostfxPlay('DeathFailOut', 0, true)
	PlaySoundFrontend(-1, 'Bed', 'WastedSounds', 1)
end

module.StartDeathTimer = function() --[NO LISTO]
	local canPayFine = false

	--[[if Config.EarlyRespawnFine then
		ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(canPay)
			canPayFine = canPay
		end)
	end--]]

	local earlySpawnTimer = math.round(module.Config.EarlyRespawnTimer / 1000)
	local bleedoutTimer = math.round(module.Config.BleedoutTimer / 1000)

	Citizen.CreateThread(function()
		-- early respawn timer

		-- bleedout timer
		while bleedoutTimer > 0 and isDead do
			Citizen.Wait(1000)

			if bleedoutTimer > 0 then
				bleedoutTimer = bleedoutTimer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		local text, timeHeld
		timeHeld = 0

		if module.Config.ShowCauseOfDeath then
			module.openthisMenu(module.deathCause())
		end

		while earlySpawnTimer > 0 and isDead do
			Citizen.Wait(0)
			text = _U('ambulancejob:respawn_available_in', module.secondsToClock(earlySpawnTimer))
			lentext = string.len(text)

			DrawRect(0.5, 0.818, (0.0047 * lentext), 0.05, 0, 0, 0, 220)
			module.DrawGenericTextThisFrame()

			SetTextEntry('STRING')
			AddTextComponentString(text)
			DrawText(0.5, 0.805)
		end

		-- bleedout timer
		while bleedoutTimer > 0 and isDead do
			Citizen.Wait(0)

			text = _U('ambulancejob:respawn_bleedout_in', module.secondsToClock(bleedoutTimer))
			lentext = string.len(text)

			if not Config.EarlyRespawnFine then
				text = text .. _U('ambulancejob:respawn_bleedout_prompt')

				if IsControlPressed(0, 38) and timeHeld > 60 then
					module.RemoveItemsAfterRPDeath()
					break
				end
			--[[elseif Config.EarlyRespawnFine and canPayFine then
				text = text .. _U('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))

				if IsControlPressed(0, 38) and timeHeld > 60 then
					TriggerServerEvent('esx_ambulancejob:payFine')
					module.RemoveItemsAfterRPDeath()
					break
				end--]]
			end

			if IsControlPressed(0, 38) then
				timeHeld = timeHeld + 1
			else
				timeHeld = 0
			end

			DrawRect(0.50, 0.825, (0.0047 * lentext), 0.065, 0, 0, 0, 220)
			module.DrawGenericTextThisFrame()

			SetTextEntry('STRING')
			AddTextComponentString(text)
			DrawText(0.5, 0.8)
		end

		if bleedoutTimer < 1 and isDead then
			module.RemoveItemsAfterRPDeath()
			if menu ~= nil then
				menu:destroy()
				menu = nil
			end
		end
	end)
end

module.secondsToClock = function(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return 0, 0
	else
		local hours = string.format('%02.f', math.floor(seconds / 3600))
		local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))

		return mins, secs
	end
end

module.DrawGenericTextThisFrame = function()
	SetTextFont(0)
	SetTextScale(0.0, 0.31)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
end


module.openthisMenu = function(a) --[NO LISTO]  
  
	menu = Menu('ambulancejob', {
		float = 'center|middle',
		title = _U('ambulancejob:player_death'),
		items = {
			{name = 'dead_message', label = a},
			{name = 'exit',    label = 'Close', type = 'button'},
		}
	})

	menu:on('item.click', function(item, index)
		if item.name == 'exit' then
			menu:destroy()
 			menu = nil
		end
	end)
end

module.RemoveItemsAfterRPDeath = function()
	emitServer('esx_ambulancejob:setDeathStatus', false)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end

		--ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
			local formattedCoords = {
				x = module.Config.RespawnPoint.coords.x,
				y = module.Config.RespawnPoint.coords.y,
				z = module.Config.RespawnPoint.coords.z
			}

			--ESX.SetPlayerData('loadout', {}) --[NOT READY]
			module.RespawnPed(PlayerPedId(), formattedCoords, module.Config.RespawnPoint.heading)

			AnimpostfxStop('DeathFailOut')
			DoScreenFadeIn(800)
		--end)
	end)
end

onServer('ambulancejob:test', function()
	local a = utils.parse('test')
	print(a)
end)

--utils.game.createLocalVehicle('infernus', vector3(341.0, -1397.3, 32.5), 0.0, cb)