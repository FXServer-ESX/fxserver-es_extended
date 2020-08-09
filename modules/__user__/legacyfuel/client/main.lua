
local Input    = M('input')
local Interact = M('interact')
local utils    = M("utils") 
M('ui.menu')
M('table')
M('player')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']
models = {
	[1] = -2007231801,
	[2] = 1339433404,
	[3] = 1694452750,
	[4] = 1933174915,
	[5] = -462817101,
	[6] = -469694731,
	[7] = -164877493
}

blacklistedVehicles = {
	[1] = 'BMX',
	[2] = 'CRUISER',
	[3] = 'FIXTER',
	[4] = 'SCORCHER',
	[5] = 'TRIBIKE',
	[6] = 'TRIBIKE2',
	[7] = 'TRIBIKE3'
}

Vehicles 				  = {}
local pumpLoc 				  = {}
local nearPump 				  = false
local IsFueling 			  = false
local IsFuelingWithJerryCan   = false
local InBlacklistedVehicle	  = false
local NearVehicleWithJerryCan = false
local price 				  = 0
local cash 					  = 9999999999990


ESX.SetInterval(1, function()
	if not InBlacklistedVehicle then
		if Timer then
			--module.DisplayHud()
		end

		if nearPump and IsCloseToLastVehicle then
			local vehicle  = GetPlayersLastVehicle()
			local fuel 	   = module.round(GetVehicleFuelLevel(vehicle), 1)
			
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				module.DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], "Benzini doldurmak için araçtan çıkın.")
			elseif IsFueling then
				local position = GetEntityCoords(vehicle)

				module.DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], "Press ~g~G ~w~to cancel the fueling of your vehicle. $~r~" .. price .. " ~w~+  tax")
				module.DrawText3Ds(position.x, position.y, position.z + 0.5, fuel .. "%")
				
				DisableControlAction(0, 0, true) -- Changing view (V)
				DisableControlAction(0, 22, true) -- Jumping (SPACE)
				DisableControlAction(0, 23, true) -- Entering vehicle (F)
				DisableControlAction(0, 24, true) -- Punching/Attacking
				DisableControlAction(0, 29, true) -- Pointing (B)
				DisableControlAction(0, 30, true) -- Moving sideways (A/D)
				DisableControlAction(0, 31, true) -- Moving back & forth (W/S)
				DisableControlAction(0, 37, true) -- Weapon wheel
				DisableControlAction(0, 44, true) -- Taking Cover (Q)
				DisableControlAction(0, 56, true) -- F9
				DisableControlAction(0, 82, true) -- Mask menu (,)
				DisableControlAction(0, 140, true) -- Hitting your vehicle (R)
				DisableControlAction(0, 166, true) -- F5
				DisableControlAction(0, 167, true) -- F6
				DisableControlAction(0, 168, true) -- F7
				DisableControlAction(0, 170, true) -- F3
				DisableControlAction(0, 288, true) -- F1
				DisableControlAction(0, 289, true) -- F2
				DisableControlAction(1, 323, true) -- Handsup (X)

				if IsControlJustReleased(0, 47) then
					module.loadAnimDict("reaction@male_stand@small_intro@forward")
					TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

					TriggerServerEvent('LegacyFuel:PayFuel', price)
					Citizen.Wait(2500)
					ClearPedTasksImmediately(GetPlayerPed(-1))
					FreezeEntityPosition(GetPlayerPed(-1), false)
					FreezeEntityPosition(vehicle, false)

					price = 0
					IsFueling = false
				end
			elseif fuel > 95.0 then
				module.DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], "Vehicle is too filled with gas to be fueled")
			elseif cash <= 0 then
				module.DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], "You currently don't have enough money on you to buy fuel with")
			else
				module.DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], "Press ~g~G ~w~to fuel your vehicle. $~r~0.5/~w~gallon + tax")
				
				if IsControlJustReleased(0, 47) then
					local vehicle = GetPlayersLastVehicle()
					local plate   = GetVehicleNumberPlateText(vehicle)

					ClearPedTasksImmediately(GetPlayerPed(-1))

					if GetSelectedPedWeapon(GetPlayerPed(-1)) ~= -1569615261 then
						SetCurrentPedWeapon(GetPlayerPed(-1), -1569615261, true)
						Citizen.Wait(1000)
					end

					IsFueling = true

					module.FuelVehicle()
				end
			end
		elseif NearVehicleWithJerryCan and not nearPump and module.Config.EnableJerryCans then
			local vehicle  = GetPlayersLastVehicle()
			local coords   = GetEntityCoords(vehicle)
			local fuel 	   = module.round(GetVehicleFuelLevel(vehicle), 1)
			local jerrycan = GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847)
			
			if IsFuelingWithJerryCan then
				module.DrawText3Ds(coords.x, coords.y, coords.z + 0.5, "Press ~g~G ~w~to cancel fueling the vehicle. Currently at: " .. fuel .. "% - Jerry Can: " .. jerrycan)

				DisableControlAction(0, 0, true) -- Changing view (V)
				DisableControlAction(0, 22, true) -- Jumping (SPACE)
				DisableControlAction(0, 23, true) -- Entering vehicle (F)
				DisableControlAction(0, 24, true) -- Punching/Attacking
				DisableControlAction(0, 29, true) -- Pointing (B)
				DisableControlAction(0, 30, true) -- Moving sideways (A/D)
				DisableControlAction(0, 31, true) -- Moving back & forth (W/S)
				DisableControlAction(0, 37, true) -- Weapon wheel
				DisableControlAction(0, 44, true) -- Taking Cover (Q)
				DisableControlAction(0, 56, true) -- F9
				DisableControlAction(0, 82, true) -- Mask menu (,)
				DisableControlAction(0, 140, true) -- Hitting your vehicle (R)
				DisableControlAction(0, 166, true) -- F5
				DisableControlAction(0, 167, true) -- F6
				DisableControlAction(0, 168, true) -- F7
				DisableControlAction(0, 170, true) -- F3
				DisableControlAction(0, 288, true) -- F1
				DisableControlAction(0, 289, true) -- F2
				DisableControlAction(1, 323, true) -- Handsup (X)

				if IsControlJustReleased(0, 47) then
					module.loadAnimDict("reaction@male_stand@small_intro@forward")
					TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

					Citizen.Wait(2500)
					ClearPedTasksImmediately(GetPlayerPed(-1))
					FreezeEntityPosition(GetPlayerPed(-1), false)
					FreezeEntityPosition(vehicle, false)

					IsFuelingWithJerryCan = false
				end
			else
				module.DrawText3Ds(coords.x, coords.y, coords.z + 0.5, "Press ~g~G ~w~to fuel the vehicle with your gas can")

				if IsControlJustReleased(0, 47) then
					local vehicle = GetPlayersLastVehicle()
					local plate   = GetVehicleNumberPlateText(vehicle)

					ClearPedTasksImmediately(GetPlayerPed(-1))

					IsFuelingWithJerryCan = true

					module.FuelVehicle()
				end
			end
		end
	else
		Citizen.Wait(500)
	end
end)

ESX.SetInterval(500, function()
	if IsFueling then
		local vehicle  = GetPlayersLastVehicle()
		local plate    = GetVehicleNumberPlateText(vehicle)
		local fuel 	   = GetVehicleFuelLevel(vehicle)
		local integer  = math.random(6, 10)
		local fuelthis = integer / 10
		local newfuel  = fuel + fuelthis

		price = price + fuelthis * 0.5 * 1.1

		if cash >= price then
			TriggerServerEvent('LegacyFuel:CheckServerFuelTable', plate)
			Citizen.Wait(150)

			if newfuel < 100 then
				SetVehicleFuelLevel(vehicle, newfuel)

				for i = 1, #Vehicles do
					if Vehicles[i].plate == plate then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, module.round(GetVehicleFuelLevel(vehicle), 1))

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = newfuel})

						break
					end
				end
			else
				SetVehicleFuelLevel(vehicle, 100.0)
				module.loadAnimDict("reaction@male_stand@small_intro@forward")
				TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

				TriggerServerEvent('LegacyFuel:PayFuel', price)
				Citizen.Wait(2500)
				ClearPedTasksImmediately(GetPlayerPed(-1))
				FreezeEntityPosition(GetPlayerPed(-1), false)
				FreezeEntityPosition(vehicle, false)

				price = 0
				IsFueling = false

				for i = 1, #Vehicles do
					if Vehicles[i].plate == plate then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, module.round(GetVehicleFuelLevel(vehicle), 1))

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = newfuel})

						break
					end
				end
			end
		else
			SetVehicleFuelLevel(vehicle, newfuel)
			module.loadAnimDict("reaction@male_stand@small_intro@forward")
			TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

			TriggerServerEvent('LegacyFuel:PayFuel', price)
			Citizen.Wait(2500)
			ClearPedTasksImmediately(GetPlayerPed(-1))
			FreezeEntityPosition(GetPlayerPed(-1), false)
			FreezeEntityPosition(vehicle, false)

			price = 0
			IsFueling = false

			for i = 1, #Vehicles do
				if Vehicles[i].plate == plate then
					TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, module.round(GetVehicleFuelLevel(vehicle), 1))

					table.remove(Vehicles, i)
					table.insert(Vehicles, {plate = plate, fuel = newfuel})

					break
				end
			end
		end
	elseif IsFuelingWithJerryCan then
		local vehicle   = GetPlayersLastVehicle()
		local plate     = GetVehicleNumberPlateText(vehicle)
		local fuel 	    = GetVehicleFuelLevel(vehicle)
		local integer   = math.random(6, 10)
		local fuelthis  = integer / 10
		local newfuel   = fuel + fuelthis
		local jerryfuel = fuelthis * 100
		local jerrycurr = GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847)
		local jerrynew  = jerrycurr - jerryfuel

		if jerrycurr >= jerryfuel then
			TriggerServerEvent('LegacyFuel:CheckServerFuelTable', plate)
			Citizen.Wait(150)
			SetPedAmmo(GetPlayerPed(-1), 883325847, module.round(jerrynew, 0))

			if newfuel < 100 then
				SetVehicleFuelLevel(vehicle, newfuel)

				for i = 1, #Vehicles do
					if Vehicles[i].plate == plate then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, module.round(GetVehicleFuelLevel(vehicle), 1))

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = newfuel})

						break
					end
				end
			else
				SetVehicleFuelLevel(vehicle, 100.0)
				module.loadAnimDict("reaction@male_stand@small_intro@forward")
				TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

				Citizen.Wait(2500)
				ClearPedTasksImmediately(GetPlayerPed(-1))
				FreezeEntityPosition(GetPlayerPed(-1), false)
				FreezeEntityPosition(vehicle, false)

				IsFuelingWithJerryCan = false

				for i = 1, #Vehicles do
					if Vehicles[i].plate == plate then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, module.round(GetVehicleFuelLevel(vehicle), 1))

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = newfuel})

						break
					end
				end
			end
		else
			module.loadAnimDict("reaction@male_stand@small_intro@forward")
			TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

			Citizen.Wait(2500)
			ClearPedTasksImmediately(GetPlayerPed(-1))
			FreezeEntityPosition(GetPlayerPed(-1), false)
			FreezeEntityPosition(vehicle, false)

			IsFuelingWithJerryCan = false

			for i = 1, #Vehicles do
				if Vehicles[i].plate == plate then
					TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, module.round(GetVehicleFuelLevel(vehicle), 1))

					table.remove(Vehicles, i)
					table.insert(Vehicles, {plate = plate, fuel = newfuel})

					break
				end
			end
		end
	end
end)

ESX.SetInterval(250, function()
	if IsPedInAnyVehicle(GetPlayerPed(-1)) then
		Citizen.Wait(2500)

		Timer = true
	else
		Timer = false
	end
 end)
 
ESX.SetInterval(1500, function()
	nearPump 			 	= false
	IsCloseToLastVehicle 	= false
	found 				 	= false
	NearVehicleWithJerryCan = false

	local myCoords = GetEntityCoords(GetPlayerPed(-1))
	
	for i = 1, #models do
		local closestPump = GetClosestObjectOfType(myCoords.x, myCoords.y, myCoords.z, 1.5, models[i], false, false)
		
		if closestPump ~= nil and closestPump ~= 0 then
			local coords    = GetEntityCoords(closestPump)
			local vehicle   = GetPlayersLastVehicle()

			nearPump = true
			pumpLoc  = {['x'] = coords.x, ['y'] = coords.y, ['z'] = coords.z + 1.2}

			if vehicle ~= nil then
				local vehcoords = GetEntityCoords(vehicle)
				local mycoords  = GetEntityCoords(GetPlayerPed(-1))
				local distance  = GetDistanceBetweenCoords(vehcoords.x, vehcoords.y, vehcoords.z, mycoords.x, mycoords.y, mycoords.z)

				if distance < 3 then
					IsCloseToLastVehicle = true
				end
			end
			break
		end
	end

	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		local vehicle = GetPlayersLastVehicle()
		local plate   = GetVehicleNumberPlateText(vehicle)
		local fuel 	  = GetVehicleFuelLevel(vehicle)
		local found   = false

		TriggerServerEvent('LegacyFuel:CheckServerFuelTable', plate)

		Citizen.Wait(500)

		for i = 1, #Vehicles do
			if Vehicles[i].plate == plate then
				found = true
				fuel  = module.round(Vehicles[i].fuel, 1)

				break
			end
		end

		if not found then
			integer = math.random(200, 800)
			fuel 	= integer / 10

			table.insert(Vehicles, {plate = plate, fuel = fuel})

			TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, fuel)
		end

		SetVehicleFuelLevel(vehicle, fuel)
	end

	local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(-1))))

	for i = 1, #blacklistedVehicles do
		if blacklistedVehicles[i] == currentVeh then
			InBlacklistedVehicle = true
			found 				 = true
			
			break
		end
	end

	if not found then
		InBlacklistedVehicle = false
	end

	if nearPump then
		TriggerServerEvent('LegacyFuel:CheckCashOnHand')
	end

	local CurrentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1))
					
	if CurrentWeapon == 883325847 then
		local MyCoords 		= GetEntityCoords(GetPlayerPed(-1))
		local Vehicle  		= GetClosestVehicle(MyCoords.x, MyCoords.y, MyCoords.z, 3.0, false, 23) == GetPlayersLastVehicle() and GetPlayersLastVehicle() or 0

		if Vehicle ~= 0 then
			NearVehicleWithJerryCan = true
		end
	end
end)

ESX.SetInterval(5000, function()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
		local engine  = Citizen.InvokeNative(0xAE31E7DF9B5B132E, vehicle)

		if vehicle and engine then
			local plate    	   = GetVehicleNumberPlateText(vehicle)
			local speed   = GetEntitySpeed(vehicle)
			local rpm 	   	   = GetVehicleCurrentRpm(vehicle)
			local fuel     	   = GetVehicleFuelLevel(vehicle)
			local rpmfuelusage = 0
			if rpm > 0.9 then
				rpmfuelusage = fuel - rpm / 0.8
				Citizen.Wait(2000)
			elseif rpm > 0.8 then
				rpmfuelusage = fuel - rpm / 1.1
				Citizen.Wait(3000)
			elseif rpm > 0.7 then
				rpmfuelusage = fuel - rpm / 2.2
				Citizen.Wait(4000)
			elseif rpm > 0.6 then
				rpmfuelusage = fuel - rpm / 4.1
				Citizen.Wait(6000)
			elseif rpm > 0.5 then
				rpmfuelusage = fuel - rpm / 5.7
				Citizen.Wait(8000)
			elseif rpm > 0.4 then
				rpmfuelusage = fuel - rpm / 6.4
				Citizen.Wait(10000)
			elseif rpm > 0.3 then
				rpmfuelusage = fuel - rpm / 6.9
				Citizen.Wait(12000)
			elseif rpm > 0.2 then
				rpmfuelusage = fuel - rpm / 7.3
				Citizen.Wait(16000)
			else
				rpmfuelusage = fuel - rpm / 7.4
				Citizen.Wait(20000)
			end
			print(rpm .. " / " .. rpmfuelusage .. " / " .. speed)

			for i = 1, #Vehicles do
				if Vehicles[i].plate == plate then
					SetVehicleFuelLevel(vehicle, rpmfuelusage)

					local updatedfuel = module.round(GetVehicleFuelLevel(vehicle), 1)

					if updatedfuel ~= 0 then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, updatedfuel)

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = rpmfuelusage})
					end

					break
				end
			end

			if rpmfuelusage < module.Config.VehicleFailure then
				SetVehicleUndriveable(vehicle, true)
			elseif rpmfuelusage == 0 then
				SetVehicleEngineOn(vehicle, false, false, false)
			else
				SetVehicleUndriveable(vehicle, false)
			end
		end
	
end)


ESX.SetInterval(5000, function()

end)

module.init()
