RegisterNetEvent('LegacyFuel:ReturnFuelFromServerTable')
AddEventHandler('LegacyFuel:ReturnFuelFromServerTable', function(vehInfo)
	local fuel   = module.round(vehInfo.fuel, 1)
	for i = 1, #Vehicles do
		if Vehicles[i].plate == vehInfo.plate then
			table.remove(Vehicles, i)

			break
		end
	end

	table.insert(Vehicles, {plate = vehInfo.plate, fuel = fuel})
end)


RegisterNetEvent('LegacyFuel:RecieveCashOnHand')
AddEventHandler('LegacyFuel:RecieveCashOnHand', function(cb)
	cash = cb
	-- TO DO money remove / get
end)