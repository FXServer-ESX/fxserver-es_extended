
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

onServer('esx_status:registerStatus', function(name, default, color, visible, tickCallback)
	local status = module.createStatus(name, default, color, visible, tickCallback)
	table.insert(Status, status)
end)

onServer('esx_status:unregisterStatus', function(name)
	for k,v in ipairs(Status) do
		if v.name == name then
			table.remove(Status, k)
			break
		end
	end
end)

on('esx_status:load', function(status)
	for i=1, #Status, 1 do
		for j=1, #status, 1 do
			if Status[i].name == status[j].name then
				Status[i].set(status[j].val)
			end
		end
	end

	Citizen.CreateThread(function()
		while true do
			for i=1, #Status, 1 do
				Status[i].onTick()
			end

			SendNUIMessage({
				update = true,
				status = module.getStatusData()
			})

			emit('esx_status:onTick', module.getStatusData(true))
			Citizen.Wait(Config.TickTime)
		end
	end)
end)

onServer('esx_status:set', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].set(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = module.getStatusData()
	})

	emitServer('esx_status:update', module.getStatusData(true))
end)

onServer('esx_status:add', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = module.getStatusData()
	})

	emitServer('esx_status:update', module.getStatusData(true))
end)

onServer('esx_status:remove', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = module.getStatusData()
	})

	emitServer('esx_status:update', module.getStatusData(true))
end)

onServer('esx_status:getStatus', function(name, cb)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end)

on('esx_status:setDisplay', function(val)
	SendNUIMessage({
		setDisplay = true,
		display    = val
	})
end)

onServer('esx:player:load', function()
	emit('esx_status:loaded')
end)
