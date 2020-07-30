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
local Input = M('input')
local Interact = M('interact')
local Menu = M('ui.menu')
local utils = M('utils')

-- Properties
module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()

  module.RegisterControls()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('clotheshop', Config.Locale, translations)

  for k, v in pairs(module.Config.Shops) do
    for i = 1, #v, 1 do

      local key = 'clotheshop:' .. k .. ':' .. i

      Interact.Register({
        name = key,
        type = 'marker',
        distance = module.Config.DrawDistance,
        radius = 2.0,
        pos = v[i],
        size = module.Config.Size.z,
        mtype = module.Config.Type,
        color = module.Config.Color,
        rotate = true,
        clotheshop = "Clotheshop"
      })

      on('esx:interact:enter:' .. key, function(data)

      utils.ui.ShowHelpNotification(_U('clotheshop:press_menu'))

      module.CurrentAction = function()
        module.OpenClotheShopMenu()
      end

      end)

      on('esx:interact:exit:' .. key, function(data) module.CurrentAction = nil end)

    end
  end

	for k,v in pairs(module.Config.Shops) do
		if v ~= nil then
			for i=1, #v, 1 do
				local blip = AddBlipForCoord(v[i])

				SetBlipSprite(blip, 73)
				SetBlipDisplay(blip, 4)
				SetBlipScale(blip, 1.0)
				SetBlipColour(blip, 80)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('clotheshop:clothes'))
				EndTextCommandSetBlipName(blip)
			end
		end
  end

end

module.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY)
end

-- TODO: Create Shop Menu