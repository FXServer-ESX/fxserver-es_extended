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

-- Locals
local Input    = M('input')
local Interact = M('interact')
local Menu     = M('ui.menu')
local utils = M('utils')


-- Properties
module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()

  module.RegisterControls()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('accessories', Config.Locale, translations)

  for k, v in pairs(module.Config.Zones) do
    for i = 1, #v.Pos, 1 do

      local key = 'accessories:' .. k .. ':' .. i

      Interact.Register({
        name = key,
        type = 'marker',
        distance = module.Config.DrawDistance,
        radius = 2.0,
        pos = v.Pos[i],
        size = module.Config.Size.z,
        mtype = module.Config.Type,
        color = module.Config.Color,
        rotate = true,
        accessory = k
      })

      on('esx:interact:enter:' .. key, function(data)

      Interact.ShowHelpNotification(_U('accessories:press_access'))

      module.CurrentAction = function()
        module.OpenShopMenu(data.accessory)
      end

      end)

      on('esx:interact:exit:' .. key, function(data) 
        module.CurrentAction = nil 
        Interact.StopHelpNotification()
      end)

    end
  end

	for k,v in pairs(module.Config.ShopsBlips) do
		if v.Pos ~= nil then
			for i=1, #v.Pos, 1 do
				local blip = AddBlipForCoord(v.Pos[i])

				SetBlipSprite (blip, v.Blip.sprite)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 1.0)
				SetBlipColour (blip, v.Blip.color)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('accessories:shop', _U('accessories:' .. string.lower(k))))
				EndTextCommandSetBlipName(blip)
			end
		end
  end

end

module.OpenAccessoryMenu = function()
 -- TODO
end

module.SetUnsetAccessory = function(accessory)
  -- TODO
end

module.OpenShopMenu = function(accessory)
  -- TODO
end

module.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY)
end