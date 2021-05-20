M('events')
module.Init()
local isNearPump = false
local key = 38
ESX.SetInterval(250, function()
	module.ManageTheFuel()
    local coords = GetEntityCoords(PlayerPedId())
	local fuelPumps = {}
	local handle, object = FindFirstObject()
	local success

	repeat
		if module.Config.PumpModels[GetEntityModel(object)] then
			table.insert(fuelPumps, object)
		end

		success, object = FindNextObject(handle, object)
	until not success

	EndFindObject(handle)

	local pumpObject = 0
	local pumpDistance = 1000

	for _, fuelPumpObject in pairs(fuelPumps) do
		local dstcheck = GetDistanceBetweenCoords(coords, GetEntityCoords(fuelPumpObject))

		if dstcheck < pumpDistance then
			pumpDistance = dstcheck
			pumpObject = fuelPumpObject
		end
    end
    if pumpDistance < 2.5 then
        isNearPump = pumpObject
    else
        isNearPump = false
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
		module.fuelSystem(isNearPump, ped)
        Citizen.Wait(0)
    end
end)