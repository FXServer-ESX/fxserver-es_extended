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

M('events')

on('esx:db:ready', function()

  local sorted = {}

  for k,v in pairs(xPlayer.accessors) do
    sorted[#sorted + 1] = v
  end

  table.sort(sorted, function(a, b) return a.name < b.name end)

  for i=1, #sorted, 1 do
    local accessor = sorted[i]

    if accessor.db then
      print('new db accessor => ' .. accessor.name .. ' | ' .. accessor.field.name)
    else
      print('new simple accessor => ' .. accessor.name)
    end

  end

end)

-- xPlayer instance construction
on('esx:player:load:accounts', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data          = {}
    local foundAccounts = {}

    if row.accounts and row.accounts ~= '' then

      local accounts = json.decode(row.accounts)

      for account, money in pairs(accounts) do
        foundAccounts[account] = money
      end

    end

    for account, label in pairs(Config.Accounts) do

      table.insert(data, {
        name = account,
        money = foundAccounts[account] or Config.StartingAccountMoney[account] or 0,
        label = label
      })

    end

    cb({accounts = data})

  end)

end)

on('esx:player:load:job', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data                   = {}
    local jobObject, gradeObject = {}, {}

    if ESX.DoesJobExist(row.job, row.job_grade) then
      jobObject, gradeObject = ESX.Jobs[row.job], ESX.Jobs[row.job].grades[tostring(row.job_grade)]
    else

      print(('[^3WARNING^7] Ignoring invalid job for %s [job: %s, grade: %s]'):format(identifier, row.job, row.job_grade))

      job, grade = 'unemployed', '0'
      jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[tostring(grade)]

    end

    data.id    = jobObject.id
    data.name  = jobObject.name
    data.label = jobObject.label

    data.grade        = row.job_grade
    data.grade_name   = gradeObject.name
    data.grade_label  = gradeObject.label
    data.grade_salary = gradeObject.salary

    data.skin_male   = {}
    data.skin_female = {}

    if gradeObject.skin_male   then data.skin_male   = json.decode(gradeObject.skin_male)   end
    if gradeObject.skin_female then data.skin_female = json.decode(gradeObject.skin_female) end

    cb({job = data})

  end)

end)

on('esx:player:load:inventory', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {
      weight    = userData.weight,
      inventory = {}
    }

    local foundItems = {}

    local rowInventory = row.inventory or '[]'

    local inventory = json.decode(rowInventory)

    for name,count in pairs(inventory) do

      local item = ESX.Items[name]

      if item then
        foundItems[name] = count
      else
        print(('[^3WARNING^7] Ignoring invalid item "%s" for "%s"'):format(name, identifier))
      end
    end

    for name,item in pairs(ESX.Items) do

      local count = foundItems[name] or 0

      if count > 0 then
        data.weight = data.weight + (item.weight * count)
      end

      table.insert(data.inventory, {
        name      = name,
        count     = count,
        label     = item.label,
        weight    = item.weight,
        usable    = ESX.UsableItemsCallbacks[name] ~= nil,
        rare      = item.rare,
        canRemove = item.canRemove
      })

    end

    table.sort(data.inventory, function(a, b)
      return a.label < b.label
    end)

    cb(data)

  end)

end)

on('esx:player:load:group', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    if row.group then
      data = row.group
    else
      data.group = 'user'
    end

    cb({group = data})

  end)

end)

on('esx:player:load:loadout', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    local rowLoadout = row.loadout or '[]'

    local loadout = json.decode(rowLoadout)

    for name,weapon in pairs(loadout) do

      local label = ESX.GetWeaponLabel(name)

      if label then

        if not weapon.components then weapon.components = {} end
        if not weapon.tintIndex  then weapon.tintIndex  = 0  end

        table.insert(data, {
          name       = name,
          ammo       = weapon.ammo,
          label      = label,
          components = weapon.components,
          tintIndex  = weapon.tintIndex
        })

      end
    end

    cb({loadout = data})

  end)

end)

on('esx:player:load:position', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    if row.position and row.position ~= '' then
      data = json.decode(row.position)
    else
      print('[^3WARNING^7] Column "position" in "users" table is missing required default value. Using backup coords, fix your database.')
      data = {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}
    end

    cb({coords = data})

  end)

end)

-- Global events
on('esx:migrations:done', xPlayer.startDBSync)

onClient('esx:onPlayerJoined', function()

  local source = source

  if not xPlayer.fromId(source) then
		xPlayer.onJoin(source)
  end

end)

AddEventHandler('playerDropped', function(reason)

  local playerId = source
	local player   = xPlayer.fromId(source)

  if player then

		emit('esx:playerDropped', playerId, reason)

		player:save(function()
			xPlayer.set(playerId, nil)
    end)

  end

end)
