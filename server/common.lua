ESX = {}
ESX.Players = {}
ESX.UsableItemsCallbacks = {}
ESX.Items = {}
ESX.ServerCallbacks = {}
ESX.TimeoutCount = -1
ESX.CancelledTimeouts = {}
ESX.Pickups = {}
ESX.PickupId = 0
ESX.Jobs = {}
ESX.RegisteredCommands = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

function getSharedObject()
	return ESX
end

function Ready(cb)
	Citizen.CreateThread(function()
		if Config.UseMySQLAsync then
			while GetResourceState('mysql-async') ~= 'started' do
				Citizen.Wait(0)
			end
			while not exports['mysql-async']:is_ready() do
				Citizen.Wait(0)
			end
		else
			if not MySQL then MySQL = { Async = {} } end
			while GetResourceState('ghmattimysql') ~= 'started' do
				Citizen.Wait(0)
			end
		end
		cb()
	end)
end

function RefreshJobs()
	MySQL.Async.fetchAll('SELECT * FROM jobs', {}, function(jobs)
		for k,v in ipairs(jobs) do
			ESX.Jobs[v.name] = v
			ESX.Jobs[v.name].grades = {}
		end
	
		MySQL.Async.fetchAll('SELECT * FROM job_grades', {}, function(jobGrades)
			for k,v in ipairs(jobGrades) do
				if ESX.Jobs[v.job_name] then
					ESX.Jobs[v.job_name].grades[tostring(v.grade)] = v
				else
					print(('[^3WARNING^7] Ignoring job grades for ^5"%s"^7^0 due to missing job'):format(v.job_name))
				end
			end
		end)
	end)

	for k2,v2 in pairs(ESX.Jobs) do
		if ESX.Table.SizeOf(v2.grades) == 0 then
			ESX.Jobs[v2.name] = nil
			print(('[^3WARNING^7] Ignoring job ^5"%s"^7^0due to no job grades found'):format(v2.name))
		end
	end
end

Ready(function()

	if not Config.UseMySQLAsync then -- Patch the functions
		MySQL.Async.execute		= function(query, values, cb) exports.ghmattimysql:execute(query, values, cb) end
		MySQL.Async.fetchAll	= function(query, values, cb) exports.ghmattimysql:execute(query, values, cb) end
		MySQL.Async.fetchScalar	= function(query, values, cb) exports.ghmattimysql:scalar(query, values, cb) end
	end
	
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for k,v in ipairs(result) do
			ESX.Items[v.name] = {
				label = v.label,
				weight = v.weight,
				rare = v.rare,
				canRemove = v.can_remove
			}
		end
	end)

	RefreshJobs()
	ESX.StartDBSync()
	ESX.StartPayCheck()

	print('[^2INFO^7] ESX ^5Legacy^0 initialized')
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESX.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
