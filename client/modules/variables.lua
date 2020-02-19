ESX.variables = {}

function ESX.set(key, value)
	if key == nil then
		return
	end

	ESX.variables[key] = value
end

function ESX.get(key)
	if key == nil then
		return nil
	end

	return ESX.variables[key]
end

RegisterNetEvent('esx:set')
AddEventHandler('esx:set', function(key, value)
	ESX.set(key, value)
end)

RegisterNetEvent('esx:get')
AddEventHandler('esx:get', function(key, cb)
	cb(ESX.get(key))
end)
