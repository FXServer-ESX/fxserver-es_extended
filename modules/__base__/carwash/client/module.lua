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
M('serializable')
M('ui.menu')

local Interact = M('interact')
local utils    = M("utils")

module.Config  = run('data/config.lua', {vector3 = vector3})['Config']

module.CurrentAction                  = nil
module.inMarker                       = false

-----------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------

module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('carwash', Config.Locale, translations)

  Citizen.CreateThread(function()
    for k,v in pairs(module.Config.CarWashZones) do
      local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

      SetBlipSprite (blip, 100)
      SetBlipDisplay(blip, 4)
      SetBlipScale  (blip, 0.75)
      SetBlipColour (blip, 3)
      SetBlipAsShortRange(blip, true)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Car Wash")
      EndTextCommandSetBlipName(blip)

      local key = 'carwash:' .. tostring(k)

      Interact.Register({
        name         = key,
        type         = 'marker',
        distance     = module.Config.DrawDistance,
        radius       = 2.0,
        pos          = v.Pos,
        size         = v.Size,
        mtype        = v.Type,
        color        = v.Color,
        rotate       = true,
        bobUpAndDown = false,
        faceCamera   = true,
        groundMarker = true
      })
  

      on('esx:interact:enter:' .. key, function(data)
        if data.name == key then

          local ped = PlayerPedId()

          if IsPedSittingInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then

              Interact.ShowHelpNotification(_U('carwash:press_to_wash'))

              module.CurrentAction = function()
                module.WashCar()
              end

              if not module.inMarker then
                module.inMarker = true
              end
            end

          else
            Interact.ShowHelpNotification(_U('carwash:must_be_in_vehicle'))
          end

        end
      end)

      on('esx:interact:exit:' .. key, function(data) 
        module.Exit()
      end)

    end
  end)

end

-----------------------------------------------------------------------------------
-- MENU
-----------------------------------------------------------------------------------

module.Exit = function()
  module.CurrentAction = nil
  module.inMarker      = false
  
  Interact.StopHelpNotification()
end

-----------------------------------------------------------------------------------
-- BASE FUNCTIONS
-----------------------------------------------------------------------------------

module.WashCar = function()

  module.Exit()

  local ped = PlayerPedId()

  if IsPedSittingInAnyVehicle(ped) then

    local vehicle = GetVehiclePedIsIn(ped, false)

    if GetPedInVehicleSeat(vehicle, -1) == ped then

      request('carwash:washCar', function(result)
        if result then
          WashDecalsFromVehicle(vehicle, 1.0)
          SetVehicleDirtLevel(vehicle, 0.0)
          utils.ui.showNotification(_U('carwash:car_washed'))
        else
          utils.ui.showNotification(_U('carwash:not_enough_money'))
        end
      end)

    end

  end


end



