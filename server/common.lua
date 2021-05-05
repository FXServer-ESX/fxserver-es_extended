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
			while GetResourceState('ghmattimysql') ~= 'started' do
				Citizen.Wait(0)
			end
		end
		cb()
	end)
end

Ready(function()
	if Config.UseMySQLAsync then
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
						print(('[^5es_extended^0] [^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
					end
				end
			end)
		end)
	else
		exports.ghmattimysql:execute('SELECT * FROM items', {}, function(result)
			for k,v in ipairs(result) do
				ESX.Items[v.name] = {
					label = v.label,
					weight = v.weight,
					rare = v.rare,
					canRemove = v.can_remove
				}
			end
		end)
	
		exports.ghmattimysql:execute('SELECT * FROM jobs', {}, function(jobs)
			for k,v in ipairs(jobs) do
				ESX.Jobs[v.name] = v
				ESX.Jobs[v.name].grades = {}
			end
	
			exports.ghmattimysql:execute('SELECT * FROM job_grades', {}, function(jobGrades)
				for k,v in ipairs(jobGrades) do
					if ESX.Jobs[v.job_name] then
						ESX.Jobs[v.job_name].grades[tostring(v.grade)] = v
					else
						print(('[^5es_extended^0] [^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
					end
				end
			end)
		end)
	end

	for k2,v2 in pairs(ESX.Jobs) do
		if ESX.Table.SizeOf(v2.grades) == 0 then
			ESX.Jobs[v2.name] = nil
			print(('[^5es_extended^0] [^3WARNING^7] Ignoring job ^5"%s"^0due to no job grades found'):format(v2.name))
		end
	end

	ESX.StartDBSync()
	ESX.StartPayCheck()

	print('[^5es_extended^0] [^2INFO^7] ESX ^5Legacy^0 initialized')
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[^5es_extended^0] [^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESX.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
