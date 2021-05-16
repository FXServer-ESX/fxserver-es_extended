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

--M('events')
--M('ui.hud')
--local utils = M('utils')
--
--onServer('esx:atm:deposit', function()
--    print('You have deposited money into the bank')
--    utils.ui.showNotification("Money deposited")
--end)

local utils = M('utils')

onServer('esx:atm:openATM', function(firstName, lastName, accounts)

  local playerPed = PlayerPedId()
  local closeToATM = false
  local object

  for _,v in ipairs(module.Config.ATM) do
    local playerCoords = GetEntityCoords(playerPed)
    local closestObject = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, module.Config.MaxDistance, GetHashKey(v.object), 0, 0, 0)
    local coordsObject  = GetEntityCoords(closestObject)
    local distanceDiff  = #(coordsObject - playerCoords)

    if (distanceDiff < module.Config.MaxDistance) then
      closeToATM = true
      object = v
      object.coords = playerCoords
      object.name = closestObject
      break
    end
  end

  if closeToATM then
    if not module.OpenStatusATM then
      TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_ATM", object.coords.x, object.coords.y, object.coords.z, GetEntityHeading(object.name), 0, true, true)
      Wait(2000)
      module.OpenATM(firstName, lastName, accounts)
    end
  else
    utils.ui.showNotification(_U('atm_not_close'))
  end

end)

