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
  Menu.Open('default', GetCurrentResourceName(), 'set_unset_accessory', {
    title = _U('accessories:set_unset'),
    align = 'top-left',
    elements = {
      {label = _U('accessories:helmet'), value = 'Helmet'},
      {label = _U('accessories:ears'), value = 'Ears'},
      {label = _U('accessories:mask'), value = 'Mask'},
      {label = _U('accessories:glasses'), value = 'Glasses'}
    }
  }, function(data, menu)
    menu.close()
      module.SetUnsetAccessory(data.current.value)
    end, function(data, menu) menu.close() end)
end

module.SetUnsetAccessory = function(accessory)
  request('esx_accessories:get', function(hasAccessory, accessorySkin)
    local _accessory = string.lower(accessory)

    if hasAccessory then
    emit('skinchanger:getSkin', function(skin)
      local mAccessory = -1
      local mColor = 0

      if _accessory == "mask" then mAccessory = 0 end

      if skin[_accessory .. '_1'] == mAccessory then
        mAccessory = accessorySkin[_accessory .. '_1']
        mColor = accessorySkin[_accessory .. '_2']
      end

      local accessorySkin = {}
      accessorySkin[_accessory .. '_1'] = mAccessory
      accessorySkin[_accessory .. '_2'] = mColor
      emit('skinchanger:loadClothes', skin, accessorySkin)
    end)
    else
    utils.ui.showNotification(_U('accessories:no_' .. _accessory))
    end
  end, accessory)
end

module.OpenShopMenu = function(accessory)

  local _accessory = string.lower(accessory)
  local restrict = {}

  restrict = {_accessory .. '_1', _accessory .. '_2'}

  emit('esx_skin:openRestrictedMenu', function(data, menu)

    menu.close()

    Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
      title = _U('accessories:valid_purchase'),
      align = 'top-left',
      elements = {
      {label = _U('accessories:no'), value = 'no'}, {
        label = _U('accessories:yes', ESX.Math.GroupDigits(module.Config.Price)),
        value = 'yes'
      }
      }
    }, function(data, menu)
      menu.close()
      if data.current.value == 'yes' then
        request('esx_accessories:checkMoney',
                      function(hasEnoughMoney)
          if hasEnoughMoney then
            emitServer('esx_accessories:pay')
            emit('skinchanger:getSkin', function(skin)
              emitServer('esx_accessories:save', skin, accessory)
            end)
          else
            emit('esx_skin:getLastSkin', function(skin)
              emit('skinchanger:loadSkin', skin)
            end)
            utils.ui.showNotification(_U('accessories:not_enough_money'))
          end
        end)
      end

      if data.current.value == 'no' then
        local player = PlayerPedId()
        emit('esx_skin:getLastSkin', function(skin)
          emit('skinchanger:loadSkin', skin)
        end)
        if accessory == "Ears" then
          ClearPedProp(player, 2)
        elseif accessory == "Mask" then
          SetPedComponentVariation(player, 1, 0, 0, 2)
        elseif accessory == "Helmet" then
          ClearPedProp(player, 0)
        elseif accessory == "Glasses" then
          SetPedPropIndex(player, 1, -1, 0, 0)
        end
      end
      module.CurrentAction = 'shop_menu'
      module.CurrentActionMsg = _U('accessories:press_access')
      module.CurrentActionData = {}
    end, function(data, menu)
      menu.close()
      module.CurrentAction = 'shop_menu'
      module.CurrentActionMsg = _U('accessories:press_access')
      module.CurrentActionData = {}
    end)
  end, function(data, menu)

    menu.close()

      module.CurrentAction     = 'shop_menu'
      module.CurrentActionMsg  = _U('accessories:press_access')
      module.CurrentActionData = {}

    end, restrict)
end

module.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY)
end