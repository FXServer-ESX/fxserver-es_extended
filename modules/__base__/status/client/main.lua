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

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(300)

		if IsPauseMenuActive() and not isPaused then
			isPaused = true
			emit('esx_status:setDisplay', 0.0)
		elseif not IsPauseMenuActive() and isPaused then
			isPaused = false 
			emit('esx_status:setDisplay', 0.5)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.UpdateInterval)

		emitServer('esx_status:update', module.getStatusData(true))
	end
end)
