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
      pos = v.Pos,
      drug = v.Drug,
      price = v.Price
    })

    on('esx:interact:enter:' .. key, function(data)

      Interact.ShowHelpNotification(_U('drugs:dealer_prompt'))

      module.CurrentAction = function()
        module.openMenu(data.drug, data.price)
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

  for k, v in pairs(module.Config.DrugTraffic) do

    local key = 'drugtraffic:' .. k

    Interact.Register({
      name = key,
      type = 'marker',
      distance = 100.0,
      radius = 90.0,
      pos = v,
      size = 90.0,
      mtype = 1,
      color = {r = 102, g = 102, b = 204, a = 100}
    })

    on('esx:interact:enter:' .. key, function(data)
      print('entro')
      
      sellingPeds = ESX.SetInterval(0, function()
        for ped in EnumeratePeds() do -- Peds search
          if DoesEntityExist(ped) then
            if not IsPedDeadOrDying(ped, 1) and not IsPedAPlayer(ped) then
              local playerCoords = GetEntityCoords(GetPlayerPed(-1))
              local pedCoords = GetEntityCoords(ped)
              local distance = #(pedCoords - playerCoords)
              if distance <= 3.0 then
                print('dentro')
              end
              


              DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 102, 102, 204, 100, 0, 0, 2, 0, nil, nil, false)
      
            end
          end
        end
      end)
      
    end)

    on('esx:interact:exit:' .. key, function(data)
      print('salio')
      ESX.ClearInterval(sellingPeds)
    end)


  end

end

module.openMenu = function(drug, price)
  Interact.StopHelpNotification()

  menu = Menu('drugs', {
    float = 'top|left',
    title = 'Drug Store - ' .. drug,
    items = {{name = 'buylicense', label = 'Buy License', type = 'button'},
    {name = 'buydrug', label = 'Buy ' .. drug, type = 'button'},
    {name = 'close', label = 'Close', type = 'button'}}
  })

  menu:on('item.click', function(item, index)

    if item.name == 'buylicense' then
      menu:hide()
      module.menuLicense()
    end

    if item.name == 'buydrug' then
      menu:hide()
      module.menuBuyDrug(drug, price)
    end

    if item.name == 'close' then
      menu:destroy()

      if not isExit then
        Interact.ShowHelpNotification(_U('drugs:dealer_prompt'))
        
        module.CurrentAction = function()
          module.openMenu(drug, price)
        end

      end

    end

  end)

end

module.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
end

module.menuBuyDrug = function(drug, price)

  local menuBuyDrug = Menu('drugs.buy', {
    float = 'top|left',
    title = 'Buy ' .. drug,
    items = {
      {name = 'buydrugs', label = '1 ' .. drug .. ' - $' .. price, type = 'slider', max = 10, min = 1},
      {name = 'buy', label = 'Buy', type = 'button'},
      {name = 'back', label = 'Back', type = 'button'},
    }
  })

  menuBuyDrug:on('destroy', function()
    menu:show()
  end)


  menuBuyDrug:on('item.change', function(item, prop, val, index)

    if (item.name == 'buydrugs') and (prop == 'value') then
      pricePerDrug = val * price
      item.label = tostring(val) .. ' ' .. drug .. ' - $' .. pricePerDrug
    end

  end)

  menuBuyDrug:on('item.click', function(item, index)
    if item.name == 'buy' then

      local drugsold = table.find(menuBuyDrug.items, function(e) return e.name == 'selldrugs' end)

      if pricePerDrug ~= nil then
        print('Sold ' .. pricePerDrug)
      end

      menuBuyDrug:destroy()
      menu:focus()
    end

    if item.name == 'back' then
      menuBuyDrug:destroy()
      menu:focus()
    end

  end)

end

module.menuLicense = function()

  menuLicense = Menu('drugs.license', {
    float = 'top|left',
    title = 'Buy license',
    items = {
      {name = 'weedlicense', label =  'Buy Marijuana License for $' .. module.Config.LicensePrice},
      {name = 'buy', label = 'Buy', type = 'button'},
      {name = 'back', label = 'Back', type = 'button'},
    }
  })

  menuLicense:on('destroy', function()
    menu:show()
  end)

  menuLicense:on('item.click', function(item, index)
    if item.name == 'buy' then
      menuLicense:destroy()
      menu:focus()
    end

    if item.name == 'back' then
      menuLicense:destroy()
      menu:focus()
    end

  end)

end
