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

local Input = M('input')
local Interact = M('interact')
local utils = M('utils')
M('ui.menu')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()

  module.RegisterControls()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('drugs', Config.Locale, translations)

  for k, v in pairs(module.Config.DrugDealers) do

    local key = 'drugs:' .. k

      Interact.Register({
        name = key,
        type = 'npc',
        model = -459818001,
        heading = v.Heading,
        distance = 10.0,
        radius = 2.0,
        pos = v.Pos
      })

    on('esx:interact:enter:' .. key, function(data)

      Interact.ShowHelpNotification(_U('drugs:dealer_prompt'))

      module.CurrentAction = function()
        module.openMenu()
      end

      isExit = false

    end)

    on('esx:interact:exit:' .. key, function(data)

      module.CurrentAction = nil
      Interact.StopHelpNotification()

      isExit = true

    end)



    if v.Pos ~= nil then
	    local blip = AddBlipForCoord(v.Pos)
    
	    SetBlipSprite(blip, 496)
	    SetBlipDisplay(blip, 4)
	    SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 52)
      SetBlipAsShortRange(blip, true)

	    BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(_U('drugs:blip_drugdealer'))
      EndTextCommandSetBlipName(blip)
    end
  end
end

module.openMenu = function()
  Interact.StopHelpNotification()

  menu = Menu('drugs', {
    float = 'top|left',
    title = 'Drug Dealer',
    items = {
      {name = 'buy', label = 'Buy License', type = 'button'},
      {name = 'selldrugs', label = 'Sell Drugs', type = 'button'},
      {name = 'close', label = 'Close', type = 'button'},
    }
  })

  menu:on('item.click', function(item, index)
    if item.name == 'selldrugs' then

      menu:hide()

      module.menuDrugs()
    end

    if item.name == 'close' then
      menu:destroy()

      if not isExit then
        Interact.ShowHelpNotification(_U('drugs:dealer_prompt'))
        
        module.CurrentAction = function()
          module.openMenu()
        end

      end

    end

  end)

end

module.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.SPRINT)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.JUMP)
end

module.menuDrugs = function()

  local menuDrugs = Menu('drugs.sell', {
    float = 'top|left',
    title = 'Sell Drugs',
    items = {
      {name = 'selldrugs', label = 'Sell 0 Marihuana - $0', type = 'slider', max = 10},
      {name = 'sell', label = 'Sell', type = 'button'},
      {name = 'back', label = 'Back', type = 'button'},
    }
  })

  menuDrugs:on('destroy', function()
    menu:show()
  end)


  menuDrugs:on('item.change', function(item, prop, val, index)

    if (item.name == 'selldrugs') and (prop == 'value') then
      price = val
      price = price * 20
      item.label = 'Sell ' .. tostring(val) .. ' Marijuana - $' .. price
    end

  end)

  menuDrugs:on('item.click', function(item, index)
    if item.name == 'sell' then
      local drugsold = table.find(menuDrugs.items, function(e) return e.name == 'selldrugs' end)
      if price ~= nil then
        print('se vendio ' .. price)
      end
      menuDrugs:destroy()
      menu:focus()
    end

    if item.name == 'back' then
      menuDrugs:destroy()
      menu:focus()
    end

  end)

end