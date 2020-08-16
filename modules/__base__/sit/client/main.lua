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

local utils    = M('utils')
module.Config = run('data/config.lua', {vector3 = vector3})['Config']

ESX.SetInterval(1, function()
	local playerPed = GetPlayerPed(-1)
	local retval =	IsPedStill(playerPed)
	if module.sitting and not IsPedUsingScenario(playerPed, currentScenario) then
		--module.wakeup()
	end

	if IsControlJustPressed(0, 38) and IsControlPressed(0, 21) and IsInputDisabled(0) and IsPedOnFoot(playerPed) and retval then
		if module.sitting then
			module.wakeup()
		else 
			local coordss = GetEntityCoords(playerPed)
			for i,v in ipairs(module.Config.Interactables) do
				--object, distance = utils.game.getClosestObject(coordss,v)				
				object = GetClosestObjectOfType(coordss.x, coordss.y, coordss.z, module.Config.MaxDistance, GetHashKey(v), false, false, false)
				distance = 1.4
				if object > 0 then
					local hash = GetEntityModel(object)
					for k,v in pairs(module.Config.Sitable) do
						if GetHashKey(k) == hash then
							module.sit(object, k, v)
							break
						end
					end
					break
				end 
			end
			if module.Config.Debug then
				table.insert(module.debugProps, object)
			end
		end
	end 
end)
