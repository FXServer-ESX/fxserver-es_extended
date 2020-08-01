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

module.init()

ESX.SetInterval(1, function()
		local playerPed = GetPlayerPed(-1)

		if module.sitting and not IsPedUsingScenario(playerPed, currentScenario) then
			module.wakeup()
		end

		if IsControlJustPressed(0, 38) and IsControlPressed(0, 21) and IsInputDisabled(0) and IsPedOnFoot(playerPed) then
			if module.sitting then
				module.wakeup()
			else
				local object, distance = utils.game.getClosestObject(Config.Interactables)

				if Config.Debug then
					table.insert(module.debugProps, object)
				end

				if distance < 1.5 then
					local hash = GetEntityModel(object)

					for k,v in pairs(Config.Sitable) do
						if GetHashKey(k) == hash then
							module.sit(object, k, v)
							break
						end
					end
				end
			end
		end
	end
end)
