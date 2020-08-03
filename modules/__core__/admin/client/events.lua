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
local utils = M('utils')

onServer('esx:admin:tptmRequested', function()
  local WaypointHandle = GetFirstBlipInfoId(8)

  if DoesBlipExist(WaypointHandle) then
    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

    for height = 1, 1000 do
      SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

      local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

      if foundGround then
        SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

        break
      end

      Citizen.Wait(5)
    end

    utils.ui.showNotification("Teleported.")
  else
    utils.ui.showNotification("Please place your waypoint.")
  end
end)
