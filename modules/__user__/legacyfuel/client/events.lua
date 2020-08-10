local Input = M('input') 
local Menu = M('ui.menu') 
local utils = M('utils') 


onServer("LegacyFuel:ReturnFuelFromServerTable", function(vehInfo)
	local fuel   = module.round(vehInfo.fuel, 1)
	for i = 1, #Vehicles do
		if Vehicles[i].plate == vehInfo.plate then
			table.remove(Vehicles, i)

			break
		end
	end

	table.insert(Vehicles, {plate = vehInfo.plate, fuel = fuel})
end)

onServer("LegacyFuel:RecieveCashOnHand", function(cb)
	cash = cb
end)
