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

-- TODO: Draw3D functions should be in their own module with a queue.

local utils = M("utils")

module.Draw3DTextOverheadWithTimeout = function(ped,text,scale,font,radius)

  module.timeoutState = true

  Citizen.CreateThread(function()

    Citizen.Wait(5000)
    module.timeoutState = false

  end)
  
  Citizen.CreateThread(function()

    while module.timeoutState == true do 

      Citizen.Wait(1)

      local senderCoords = GetEntityCoords(ped)

      if Vdist2(GetEntityCoords(PlayerPedId(), false), senderCoords.x, senderCoords.y, senderCoords.z) < 5000 then

        local onScreen, _x, _y = World3dToScreen2d(senderCoords.x, senderCoords.y, senderCoords.z + 1.0)
        local camCoords = GetGameplayCamCoords()
        local distance = GetDistanceBetweenCoords(camCoords.x, camCoords.y, camCoords.z, senderCoords.x, senderCoords.y, senderCoords.z, 1)
        local scale = (1 / distance) * 4
        local fov = (1 / GetGameplayCamFov()) * 75
        local scale = scale * fov

        if onScreen then

          SetTextScale(tonumber(scale*0.0), tonumber(0.35 * (scale or 1)))
          SetTextFont(font or 0)
          SetTextProportional(true)
          SetTextColour(255, 255, 255, 255)

          SetTextOutline() 

          SetTextEntry("STRING")
          SetTextCentre(true)
          AddTextComponentString(text)
          DrawText(_x,_y)
          
        end
      end
    end
  end)
end

module.SendLifeInvaderMessage = function(playerId, message, name)
  utils.ui.showAdvancedNotification("LifeInvader Message", "~w~@" .. name, message, 'CHAR_LIFEINVADER', 4, false, 'CHAR_LIFEINVADER', 6)
end