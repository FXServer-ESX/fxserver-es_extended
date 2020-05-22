ESX.Modules['license'] = {}

local self = ESX.Modules['license']

self.Init = function()
  local translations = ESX.EvalFile(GetCurrentResourceName(), 'modules/voice/data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('license', Config.Locale, translations)
end

self.AddLicense = function(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		MySQL.Async.execute('INSERT INTO user_licenses (type, owner) VALUES (@type, @owner)', {
			['@type']  = type,
			['@owner'] = xPlayer.identifier
		}, function(rowsChanged)
			if cb then
				cb()
			end
		end)
	else
		if cb then
			cb()
		end
	end
end

self.RemoveLicense = function(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		MySQL.Async.execute('DELETE FROM user_licenses WHERE type = @type AND owner = @owner', {
			['@type'] = type,
			['@owner'] = xPlayer.identifier
		}, function(rowsChanged)
			if cb then
				cb()
			end
		end)
	else
		if cb then
			cb()
		end
	end
end

self.GetLicense = function(type, cb)
	MySQL.Async.fetchAll('SELECT label FROM licenses WHERE type = @type', {
		['@type'] = type
	}, function(result)
		local data = {
			type  = type,
			label = result[1].label
		}

		cb(data)
	end)
end

self.GetLicenses = function(target, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	MySQL.Async.fetchAll('SELECT type FROM user_licenses WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function(result)
		local licenses, asyncTasks = {}, {}

		for i=1, #result, 1 do
			local scope = function(type)
				table.insert(asyncTasks, function(cb)
					MySQL.Async.fetchAll('SELECT label FROM licenses WHERE type = @type', {
						['@type'] = type
					}, function(result2)
						table.insert(licenses, {
							type  = type,
							label = result2[1].label
						})

						cb()
					end)
				end)
			end

			scope(result[i].type)
		end

		Async.parallel(asyncTasks, function(results)
			cb(licenses)
		end)
	end)
end

self.CheckLicense = function(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM user_licenses WHERE type = @type AND owner = @owner', {
			['@type'] = type,
			['@owner'] = xPlayer.identifier
		}, function(result)
			if tonumber(result[1].count) > 0 then
				cb(true)
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end

self.GetLicensesList = function(cb)
	MySQL.Async.fetchAll('SELECT type, label FROM licenses', {
		['@type'] = type
	}, function(result)
		local licenses = {}

		for i=1, #result, 1 do
			table.insert(licenses, {
				type  = result[i].type,
				label = result[i].label
			})
		end

		cb(licenses)
	end)
end
