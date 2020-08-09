local gas_stations = {
	{ ['x'] = 49.4187,   ['y'] = 2778.793,  ['z'] = 58.043},
 	{ ['x'] = 263.894,   ['y'] = 2606.463,  ['z'] = 44.983},
 	{ ['x'] = 1039.958,  ['y'] = 2671.134,  ['z'] = 39.550},
 	{ ['x'] = 1207.260,  ['y'] = 2660.175,  ['z'] = 37.899},
 	{ ['x'] = 2539.685,  ['y'] = 2594.192,  ['z'] = 37.944},
 	{ ['x'] = 2679.858,  ['y'] = 3263.946,  ['z'] = 55.240},
 	{ ['x'] = 2005.055,  ['y'] = 3773.887,  ['z'] = 32.403},
 	{ ['x'] = 1687.156,  ['y'] = 4929.392,  ['z'] = 42.078},
 	{ ['x'] = 1701.314,  ['y'] = 6416.028,  ['z'] = 32.763},
 	{ ['x'] = 179.857,   ['y'] = 6602.839,  ['z'] = 31.868},
 	{ ['x'] = -94.4619,  ['y'] = 6419.594,  ['z'] = 31.489},
 	{ ['x'] = -2554.996, ['y'] = 2334.40,  ['z'] = 33.078},
 	{ ['x'] = -1800.375, ['y'] = 803.661,  ['z'] = 138.651},
 	{ ['x'] = -1437.622, ['y'] = -276.747,  ['z'] = 46.207},
 	{ ['x'] = -2096.243, ['y'] = -320.286,  ['z'] = 13.168},
 	{ ['x'] = -724.619, ['y'] = -935.1631,  ['z'] = 19.213},
 	{ ['x'] = -526.019, ['y'] = -1211.003,  ['z'] = 18.184},
 	{ ['x'] = -70.2148, ['y'] = -1761.792,  ['z'] = 29.534},
 	{ ['x'] = 265.648,  ['y'] = -1261.309,  ['z'] = 29.292},
 	{ ['x'] = 819.653,  ['y'] = -1028.846,  ['z'] = 26.403},
 	{ ['x'] = 1208.951, ['y'] =  -1402.567, ['z'] = 35.224},
 	{ ['x'] = 1181.381, ['y'] =  -330.847,  ['z'] = 69.316},
 	{ ['x'] = 620.843,  ['y'] =  269.100,  ['z'] = 103.089},
 	{ ['x'] = 2581.321, ['y'] = 362.039, ['z'] = 108.468}
}

module.Config = run('data/config.lua', {vector3 = vector3})['Config']
local translations = run('data/locales/' .. module.Config.Locale .. '.lua')['Translations']
LoadLocale('fuelmodule', module.Config.Locale, translations)


module.init = function()
	if module.Config.EnableBlips then
		for k, v in ipairs(gas_stations) do
			local blip = AddBlipForCoord(v.x, v.y, v.z)

			SetBlipSprite(blip, 361)
			SetBlipScale(blip, 0.9)
			SetBlipColour(blip, 6)
			SetBlipDisplay(blip, 4)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Gas Station")
			EndTextCommandSetBlipName(blip)
		end
	end
end

module.round = function(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

module.GetSeatPedIsIn = function(ped)
	local vehicle = GetVehiclePedIsIn(ped, false)

	for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
		if GetPedInVehicleSeat(vehicle, i) == ped then
			return i
		end
	end

	return -2
end

module.DisplayHud = function()
	local playerPed = GetPlayerPed(-1)
	if module.Config.ShouldDisplayHud and IsPedInAnyVehicle(playerPed, false) and module.GetSeatPedIsIn(playerPed) == -1 then
		local vehicle = GetPlayersLastVehicle()
		local fuel    = math.ceil(module.round(GetVehicleFuelLevel(vehicle), 1))
		local speed   = GetEntitySpeed(vehicle)
		local kmh     = module.round(speed * 3.6, 0)
		local mph     = module.round(speed * 2.236936, 0)

		if fuel == 0 then
			fuel = "0"
		end
		if kmh == 0 then
			kmh = "0"
		end
		if mph == 0 then
			mph = "0"
		end

		x = 0.01135
		y = 0.002

		module.DrawAdvancedText(0.2195 - x, 0.77 - y, 0.005, 0.0028, 0.6, fuel, 255, 255, 255, 255, 6, 1)

		module.DrawAdvancedText(0.130 - x, 0.77 - y, 0.005, 0.0028, 0.6, mph, 255, 255, 255, 255, 6, 1)
		module.DrawAdvancedText(0.174 - x, 0.77 - y, 0.005, 0.0028, 0.6, kmh, 255, 255, 255, 255, 6, 1)

		module.DrawAdvancedText(0.148 - x, 0.7765 - y, 0.005, 0.0028, 0.4, "mp/h              km/h              Fuel", 255, 255, 255, 255, 6, 1)
	end
end

module.DrawText3Ds = function(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

module.DrawAdvancedText = function(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
	N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
	DrawText(x - 0.1+w, y - 0.02+h)
end

module.loadAnimDict = function(dict)
	while(not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(1)
	end
end

module.FuelVehicle = function()
	local ped 	  = GetPlayerPed(-1)
	local coords  = GetEntityCoords(ped)
	local vehicle = GetPlayersLastVehicle()

	FreezeEntityPosition(ped, true)
	FreezeEntityPosition(vehicle, false)
	SetVehicleEngineOn(vehicle, false, false, false)
	module.loadAnimDict("timetable@gardener@filling_can")
	TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 1.0, 2, -1, 49, 0, 0, 0, 0)
end
