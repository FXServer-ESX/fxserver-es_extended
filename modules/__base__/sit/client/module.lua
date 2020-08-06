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

local utils = M('utils')


module.debugProps, module.sitting, module.lastPos, module.currentSitCoords, module.currentScenario = {}

module.init = function()
  if Config.Debug then
    module.debugMode()
  end
  module.wakeup()
end

module.debugMode = function()
  ESX.SetInterval(1, function()
    for i=1, #debugProps, 1 do
      local coords = GetEntityCoords(debugProps[i])
      local hash = GetEntityModel(debugProps[i])
      local id = coords.x .. coords.y .. coords.z
      local model = 'unknown'

      for i=1, #Config.Interactables, 1 do
        local seat = Config.Interactables[i]

        if hash == GetHashKey(seat) then
          model = seat
          break
        end
      end

      local text = ('ID: %s~n~Hash: %s~n~Model: %s'):format(id, hash, model)

      utils.ui.drawText3D({
        x = coords.x,
        y = coords.y,
        z = coords.z + 2.0
      }, text, 0.5)
    end
  end)
end

module.wakeup = function()
	local playerPed = GetPlayerPed(-1)  
  ClearPedTasks(playerPed)
	module.sitting = false
	--SetEntityCoords(playerPed, module.lastPos)
	emitServer('esx_sit:leavePlace', module.currentSitCoords)
  module.currentSitCoords, module.currentScenario = nil, nil
	FreezeEntityPosition(playerPed, false)
	ClearPedTasks(playerPed)
end

module.sit = function(object, modelName, data)
	local pos = GetEntityCoords(object)
	local objectCoords = pos.x .. pos.y .. pos.z

	request('esx_sit:getPlace', function(occupied)
		if occupied then
			utils.ui.showNotification('Cette place est prise...')
		else
			local playerPed = GetPlayerPed(-1)
			module.lastPos, module.currentSitCoords = GetEntityCoords(playerPed), objectCoords

			emitServer('esx_sit:takePlace', objectCoords)
			FreezeEntityPosition(object, true)

			module.currentScenario = data.scenario
			TaskStartScenarioAtPosition(playerPed, module.currentScenario, pos.x, pos.y, pos.z - data.verticalOffset, GetEntityHeading(object) + 180.0, 0, true, true)
			Citizen.Wait(1000)
			module.sitting = true
		end
	end)
end
