ESX = exports['es_extended']:getSharedObject()

if not IsDuplicityVersion() then -- Only register this event for the client
	AddEventHandler('esx:setPlayerData', function(key, val)
		if GetInvokingResource() == 'es_extended' then
			ESX.PlayerData[key] = val
			if OnPlayerData ~= nil then OnPlayerData(key, val) end
		end
	end)
elseif MySQL and not ESX.GetConfig().UseMySQLAsync then
	Citizen.CreateThread(function()
		function MySQL.ready(callback)
			Citizen.CreateThread(function ()
				while GetResourceState('ghmattimysql') ~= 'started' do
					Citizen.Wait(0)
				end
				MySQL.Async.execute		= function(query, values, cb) exports.ghmattimysql:execute(query, values, cb) end
				MySQL.Async.fetchAll	= function(query, values, cb) exports.ghmattimysql:execute(query, values, cb) end
				MySQL.Async.fetchScalar	= function(query, values, cb) exports.ghmattimysql:scalar(query, values, cb) end
				callback()
			end)
		end
	end)
end
