M('events')
M('ui.menu')
local utils = M('utils')
local Interact = M('interact')
module.Config  = run('data/config.lua', {vector3 = vector3})['Config']
-----------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------
module.Init = function()
    Citizen.CreateThread(function()
        for k,v in pairs(module.Config.GasStations) do
            local blip = AddBlipForCoord(v)

            SetBlipSprite(blip, 361)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, 4)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
        
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Gas Station")
            EndTextCommandSetBlipName(blip)
        end
        for k,v in pairs(module.Config.CarWash) do
            local blip = AddBlipForCoord(v)

            SetBlipSprite(blip, 100)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, 4)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
        
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("CarWash")
            EndTextCommandSetBlipName(blip)
        end
      end)
end
module.fuelSystem = function(isNearPump, ped) -- Didn't added the Jerrican Yet.
    currentPump = isNearPump
    if not isFueling and ((isNearPump and GetEntityHealth(isNearPump) > 0)) then
        if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped then
            local pumpCoords = GetEntityCoords(isNearPump)

            Interact.ShowHelpNotification("Gas Station: Please turn off your engine and leave your vehicle!")
        else
            Interact.StopHelpNotification()
            vehicle = GetPlayersLastVehicle()
            local vehicleCoords = GetEntityCoords(vehicle)
            if DoesEntityExist(vehicle) and GetDistanceBetweenCoords(GetEntityCoords(ped), vehicleCoords) < 2.5 then
                if not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then
                    local stringCoords = GetEntityCoords(isNearPump)
                    local canFuel = true
                    if GetVehicleFuelLevel(vehicle) < 99 and canFuel then
                        Interact.ShowHelpNotification("Gas Station: Press ~INPUT_CONTEXT~ to choose your fuel!")
                        if IsControlJustReleased(0, 38) then
                            isFueling = true
                            Interact.StopHelpNotification()
                            TaskTurnPedToFaceEntity(ped, isNearPump, 1000)
                            module.ChooseFuel(vehicle)
                        end
                    else
                        Interact.ShowHelpNotification("Gas Station: Your car is fully fuelled. Byeee!")
                    end
                end
            end
        end
    else
        Interact.StopHelpNotification()
        Citizen.Wait(250)
    end
end
module.ChooseFuel = function(vehicle)
    local menu = Menu('fuel.main', {
        float = 'top|left',
        title = 'Get your fuel!',
        items = {
        {label = 'Fuel with Gasoline', name = 'Gasoline',  type = 'button'},
        {label = 'Fuel with Diesel', name = 'Diesel',  type = 'button'},
        {label = 'Close', name = 'Close',  type = 'button'},
      }})
      menu:on('item.click', function(item)
        menu:destroy()
        module[item.name](menu,vehicle)
        fuel = item.name
      end)
end
module.Diesel = function(menu)
    print("Diesel")
end
module.Gasoline = function(menu,vehicle)
    local menu = Menu('fuel.main', {
        float = 'top|left',
        title = 'Get your fuel!',
        items = {
        {label = 'Maximum estimated price: '.. math.round((100-GetVehicleFuelLevel(vehicle))*module.Config.GasolinePrice,2) .. '$', name = 'Price',  type = 'slider'},
        {label = 'Press to refuel.', name = 'ReFuel',  type = 'button'},
        {label = 'Close', name = 'Close',  type = 'button'},
      }})
      menu:on('item.change', module.onItemChanged)
      menu:on('item.click', function(item)
        if item.name == 'ReFuel' then
            menu:destroy()
        end
        module[item.name](menu)
    end)
end
module.onItemChanged = function(item, prop, val, index)
    if (item.name == 'Price') and (prop == 'value') then
        price = math.round((100-GetVehicleFuelLevel(vehicle))*module.Config.GasolinePrice*(val/100),2)
        LiterstoADD= (100-GetVehicleFuelLevel(vehicle))*(val/100)
        item.label = 'Estimated price: ' .. price .. '$'
    end
end
module.ReFuel = function(menu)
    currentFuel = GetVehicleFuelLevel(vehicle)
    local fuelToAdd = math.random(10, 20) / 10.0
    local actualfuel = currentFuel
    TaskTurnPedToFaceEntity(ped, vehicle, 1000)
    while isFueling do
        if not currentPump then
            --Script for use jerrycan
        else
            if actualfuel > (currentFuel + LiterstoADD) then
                actualfuel = (currentFuel + LiterstoADD)   
                print("HEELO")
                isFueling = false
                local menu = Menu('fuel.refuel', {
                    float = 'top|left',
                    title = 'Billing:',
                    items = {
                    {label = 'Actual Price: '..math.round(LiterstoADD*module.Config[fuel.."Price"],2) .. '$', name = 'Price',  type = 'button'},
                    {label = 'Fuel: '.. math.round(GetVehicleFuelLevel(vehicle),2) .. " %", name = 'Fuel',  type = 'button'},
                    {label = 'Close and pay', name = 'Close',  type = 'button'},
                  }})
                  menu:on('item.click', function(item)
                    request('fuel:payme', function(result)
                        if result then
                            SetVehicleFuelLevel(vehicle, actualfuel)
                        else
                            Interact.ShowHelpNotification("Gas Station: You does not have enough money to pay.")
                        end
                    end)
                    menu:destroy()
                end)
            else
                actualfuel = actualfuel + fuelToAdd
                SetVehicleFuelLevel(vehicle, actualfuel)
            end
         end
        Citizen.Wait(500) 
    end
end
module.Close = function(menu)
    menu:destroy()
end
module.ManageTheFuel = function()
    local allowed = true
    local blacklisted = {"13", "14", "15", "16", "21"}
    local vehicle = GetPlayersLastVehicle()
    print(GetVehicleFuelLevel(vehicle))
    for k,v in pairs(blacklisted) do
        if GetVehicleClass(vehicle) == v then
            print("That's it")
             allowed = false
        end
    end
    if IsVehicleEngineOn(vehicle) and allowed then
        SetVehicleFuelLevel(vehicle, GetVehicleFuelLevel(vehicle) - module.Config.FuelUsage[math.round(GetVehicleCurrentRpm(vehicle), 1)] / 30)
    end
end