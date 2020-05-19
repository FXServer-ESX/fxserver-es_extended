function CreateExtendedPlayer(data)

  ---- Class representing a player
  --- @class xPlayer
  local self = {}

	self.source    = data.playerId
  self.maxWeight = Config.MaxWeight

  for k,v in pairs(data) do
    self[k] = v
  end

	ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))

  --- @function xPlayer:triggerEvent
  --- Trigger event to player
  --- @param eventName string Event name
  --- @param ...rest any Event arguments
  --- @return nil
	self.triggerEvent = function(eventName, ...)
		TriggerClientEvent(eventName, self.source, ...)
	end

  --- @function xPlayer:setCoords
  --- Update player coords on both server and client
  --- @param coords vector3 Coords
  --- @return nil
	self.setCoords = function(coords)
		self.updateCoords(coords)
		self.triggerEvent('esx:teleport', coords)
	end

  --- @function xPlayer:updateCoords
  --- Update player coords on server
  --- @param coords vector3 Coords
  --- @return nil
	self.updateCoords = function(coords)
		self.coords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1), heading = ESX.Math.Round(coords.heading or 0.0, 1)}
	end

  --- @function xPlayer:getCoords
  --- Update player coords on server
  --- @param asVector boolean Get coords as vector or table ?
  --- @return any
	self.getCoords = function(asVector)
		if asVector then
			return vector3(self.coords.x, self.coords.y, self.coords.z)
		else
			return self.coords
		end
	end

  --- @function xPlayer:kick
  --- Kick player
  --- @param reason string Reason to kick player for
  --- @return nil
	self.kick = function(reason)
		DropPlayer(self.source, reason)
	end

  --- @function xPlayer:setMoney
  --- Set amount for player 'money' account
  --- @param money number Amount
  --- @return nil
	self.setMoney = function(money)
		money = ESX.Math.Round(money)
		self.setAccountMoney('money', money)
	end

  --- @function xPlayer:getMoney
  --- Get amount for player 'money' account
  --- @return number
	self.getMoney = function()
		return self.getAccount('money').money
	end

  --- @function xPlayer:addMoney
  --- Add amount for player 'money' account
  --- @param money number Amount
  --- @return nil
	self.addMoney = function(money)
		money = ESX.Math.Round(money)
		self.addAccountMoney('money', money)
	end

  --- @function xPlayer:removeMoney
  --- Remove amount for player 'money' account
  --- @param money number Amount
  --- @return nil
	self.removeMoney = function(money)
		money = ESX.Math.Round(money)
		self.removeAccountMoney('money', money)
	end

  --- @function xPlayer:getIdentifier
  --- Get player identifier
  --- @return string
	self.getIdentifier = function()
		return self.identifier
	end

  --- @function xPlayer:setGroup
  --- Set player group
  --- @param newGroup string New group
  --- @return nil
	self.setGroup = function(newGroup)
		ExecuteCommand(('remove_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
		self.group = newGroup
		ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
	end

  --- @function xPlayer:getGroup
  --- Get player group
  --- @return string
	self.getGroup = function()
		return self.group
	end

  --- @function xPlayer:set
  --- Set field on this xPlayer instance
  --- @param k string Field name
  --- @param v any Field value
  --- @return nil
	self.set = function(k, v)
		self[k] = v
	end

  --- @function xPlayer:get
  --- Get field on this xPlayer instance
  --- @param k string Field name
  --- @return any
	self.get = function(k)
		return self[k]
	end

  --- @function xPlayer:getAccounts
  --- Get player accounts
  --- @param minimal boolean Compact output
  --- @return table
	self.getAccounts = function(minimal)
		if minimal then
			local minimalAccounts = {}

			for k,v in ipairs(self.accounts) do
				minimalAccounts[v.name] = v.money
			end

			return minimalAccounts
		else
			return self.accounts
		end
	end

  --- @function xPlayer:getAccount
  --- Get player account
  --- @param account string Account name
  --- @return table
	self.getAccount = function(account)
		for k,v in ipairs(self.accounts) do
			if v.name == account then
				return v
			end
		end
	end

  --- @function xPlayer:getInventory
  --- Get player inventory
  --- @param minimal boolean Compact output
  --- @return table
	self.getInventory = function(minimal)
		if minimal then
			local minimalInventory = {}

			for k,v in ipairs(self.inventory) do
				if v.count > 0 then
					minimalInventory[v.name] = v.count
				end
			end

			return minimalInventory
		else
			return self.inventory
		end
	end

  --- @function xPlayer:getJob
  --- Get player job
  --- @return table
	self.getJob = function()
		return self.job
	end

  --- @function xPlayer:getLoadout
  --- Get player inventory
  --- @param minimal boolean Compact output
  --- @return table
	self.getLoadout = function(minimal)
		if minimal then
			local minimalLoadout = {}

			for k,v in ipairs(self.loadout) do
				minimalLoadout[v.name] = {ammo = v.ammo}
				if v.tintIndex > 0 then minimalLoadout[v.name].tintIndex = v.tintIndex end

				if #v.components > 0 then
					local components = {}

					for k2,component in ipairs(v.components) do
						if component ~= 'clip_default' then
							table.insert(components, component)
						end
					end

					if #components > 0 then
						minimalLoadout[v.name].components = components
					end
				end
			end

			return minimalLoadout
		else
			return self.loadout
		end
	end

  --- @function xPlayer:getName
  --- Get player name
  --- @return string
	self.getName = function()
		return self.name
	end

  --- @function xPlayer:setName
  --- Set player name
  --- @param newName string New name
  --- @return nil
	self.setName = function(newName)
		self.name = newName
	end

  --- @function xPlayer:setAccountMoney
  --- Set player account money
  --- @param accountName string Account name
  --- @param money number Amount
  --- @return nil
	self.setAccountMoney = function(accountName, money)
		if money >= 0 then
			local account = self.getAccount(accountName)

			if account then
				local prevMoney = account.money
				local newMoney = ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

  --- @function xPlayer:addAccountMoney
  --- Add player account money
  --- @param accountName string Account name
  --- @param money number Amount
  --- @return nil
	self.addAccountMoney = function(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money + ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

  --- @function xPlayer:addAccountMoney
  --- Add player account money
  --- @param accountName string Account name
  --- @param money number Amount
  --- @return nil
	self.removeAccountMoney = function(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money - ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

  --- @function xPlayer:getInventoryItem
  --- Get player inventory item
  --- @param name string Account name
  --- @return table
	self.getInventoryItem = function(name)
		for k,v in ipairs(self.inventory) do
			if v.name == name then
				return v
			end
		end

		return
	end

  --- @function xPlayer:addInventoryItem
  --- Add player inventory item
  --- @param name string Account name
  --- @param count number Amount
  --- @param notify boolean Weither to notify or not
  --- @return nil
	self.addInventoryItem = function(name, count, notify)

    if notify == nil then
      notify = false
    end

    local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			item.count = item.count + count
			self.weight = self.weight + (item.weight * count)

			TriggerEvent('esx:onAddInventoryItem', self.source, item.name, item.count)
			self.triggerEvent('esx:addInventoryItem', item.name, item.count, notify)
		end
	end

  --- @function xPlayer:removeInventoryItem
  --- Remove player inventory item
  --- @param name string Account name
  --- @param count number Amount
  --- @param notify boolean Weither to notify or not
  --- @return nil
  self.removeInventoryItem = function(name, count, notify)

    if notify == nil then
      notify = false
    end

		local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			local newCount = item.count - count

			if newCount >= 0 then
				item.count = newCount
				self.weight = self.weight - (item.weight * count)

				TriggerEvent('esx:onRemoveInventoryItem', self.source, item.name, item.count)
				self.triggerEvent('esx:removeInventoryItem', item.name, item.count, notify)
			end
		end
	end

  --- @function xPlayer:removeInventoryItem
  --- Remove player inventory item
  --- @param name string Account name
  --- @param count number Amount
  --- @return nil
	self.setInventoryItem = function(name, count)
		local item = self.getInventoryItem(name)

		if item and count >= 0 then
			count = ESX.Math.Round(count)

			if count > item.count then
				self.addInventoryItem(item.name, count - item.count)
			else
				self.removeInventoryItem(item.name, item.count - count)
			end
		end
	end

  --- @function xPlayer:getWeight
  --- Get player weight
  --- @return number
	self.getWeight = function()
		return self.weight
	end

  --- @function xPlayer:getMaxWeight
  --- Get max player weight
  --- @return number
	self.getMaxWeight = function()
		return self.maxWeight
	end

  --- @function xPlayer:canCarryItem
  --- Check if player can carry count of given item
  --- @return boolean
	self.canCarryItem = function(name, count)
		local currentWeight, itemWeight = self.weight, ESX.Items[name].weight
		local newWeight = currentWeight + (itemWeight * count)

		return newWeight <= self.maxWeight
	end

  --- @function xPlayer:maxCarryItem
  --- Get max count of specific item player can carry
  --- @return number
  self.maxCarryItem = function(name)
		local count = 0
		local currentWeight, itemWeight = self.getWeight(), ESX.Items[name].weight
		local newWeight = self.maxWeight - currentWeight

		-- math.max(0, ... to prevent bad programmers
		return math.max(0, math.floor(newWeight / itemWeight))
	end

  --- @function xPlayer:canSwapItem
  --- Check if player can sawp item with other item
  --- @param firstItem string Item to be swapped with testItem
  --- @param firstItemCount number Count of item to swap with testItem
  --- @param testItem string Item intended to replace firstItem
  --- @param testItemCount number Count of item intended to replace firstItem
  --- @return boolean
	self.canSwapItem = function(firstItem, firstItemCount, testItem, testItemCount)
		local firstItemObject = self.getInventoryItem(firstItem)
		local testItemObject = self.getInventoryItem(testItem)

		if firstItemObject.count >= firstItemCount then
			local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
			local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

			return weightWithTestItem <= self.maxWeight
		end

		return false
	end

  --- @function xPlayer:setMaxWeight
  --- Set max player weight
  --- @param newWeight number New weight
  --- @return nil
	self.setMaxWeight = function(newWeight)
		self.maxWeight = newWeight
		self.triggerEvent('esx:setMaxWeight', self.maxWeight)
	end

  --- @function xPlayer:setJob
  --- Set player job
  --- @param job string New job
  --- @param grade number New job grade
  --- @return nil
	self.setJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.job.id    = jobObject.id
			self.job.name  = jobObject.name
			self.job.label = jobObject.label

			self.job.grade        = tonumber(grade)
			self.job.grade_name   = gradeObject.name
			self.job.grade_label  = gradeObject.label
			self.job.grade_salary = gradeObject.salary

			if gradeObject.skin_male then
				self.job.skin_male = json.decode(gradeObject.skin_male)
			else
				self.job.skin_male = {}
			end

			if gradeObject.skin_female then
				self.job.skin_female = json.decode(gradeObject.skin_female)
			else
				self.job.skin_female = {}
			end

			TriggerEvent('esx:setJob', self.source, self.job, lastJob)
			self.triggerEvent('esx:setJob', self.job)
		else
			print(('[es_extended] [^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
		end
	end

  --- @function xPlayer:addWeapon
  --- Add weapon to player
  --- @param weaponName string Weapon name
  --- @param ammo number Ammo
  --- @return nil
  self.addWeapon = function(weaponName, ammo)

    if ammo == nil then
      ammo = 1000
    end

		if not self.hasWeapon(weaponName) then

			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				components = {},
				tintIndex = 0
			})

			self.triggerEvent('esx:addWeapon', weaponName, ammo)
			self.triggerEvent('esx:addInventoryItem', weaponLabel, false, true)
		end
	end

  --- @function xPlayer:addWeaponComponent
  --- Add weapon to player
  --- @param weaponName string Weapon name
  --- @param weaponComponent string Weapon component
  --- @return nil
	self.addWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if not self.hasWeaponComponent(weaponName, weaponComponent) then
					table.insert(self.loadout[loadoutNum].components, weaponComponent)
					self.triggerEvent('esx:addWeaponComponent', weaponName, weaponComponent)
					self.triggerEvent('esx:addInventoryItem', component.label, false, true)
				end
			end
		end
	end

  --- @function xPlayer:addWeaponAmmo
  --- Add ammo to player weapon
  --- @param weaponName string Weapon name
  --- @param ammoCount number Ammo count
  --- @return nil
	self.addWeaponAmmo = function(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

  --- @function xPlayer:updateWeaponAmmo
  --- Update player weapon ammo
  --- @param weaponName string Weapon name
  --- @param ammoCount number Ammo count
  --- @return nil
	self.updateWeaponAmmo = function(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			if ammoCount < weapon.ammo then
				weapon.ammo = ammoCount
			end
		end
	end

  --- @function xPlayer:setWeaponTint
  --- Update player weapon ammo
  --- @param weaponName string Weapon name
  --- @param weaponTintIndex number Weapon tint index
  --- @return nil
	self.setWeaponTint = function(weaponName, weaponTintIndex)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local weaponNum, weaponObject = ESX.GetWeapon(weaponName)

			if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
				self.loadout[loadoutNum].tintIndex = weaponTintIndex
				self.triggerEvent('esx:setWeaponTint', weaponName, weaponTintIndex)
				self.triggerEvent('esx:addInventoryItem', weaponObject.tints[weaponTintIndex], false, true)
			end
		end
	end

  --- @function xPlayer:getWeaponTint
  --- Get player weapon tint index
  --- @param weaponName string Weapon name
  --- @return number
	self.getWeaponTint = function(weaponName)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			return weapon.tintIndex
		end

		return 0
	end

  --- @function xPlayer:removeWeapon
  --- Remove player weapon
  --- @param weaponName string Weapon name
  --- @return nil
	self.removeWeapon = function(weaponName)

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then

				for k2,v2 in ipairs(v.components) do
					self.removeWeaponComponent(weaponName, v2)
				end

        table.remove(self.loadout, k)

        self.triggerEvent('esx:removeWeapon', weaponName)

        break

			end
		end

	end

  --- @function xPlayer:removeWeaponComponent
  --- Remove player weapon component
  --- @param weaponName string Weapon name
  --- @param weaponComponent string Weapon component
  --- @return nil
	self.removeWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

      if component then

				if self.hasWeaponComponent(weaponName, weaponComponent) then
					for k,v in ipairs(self.loadout[loadoutNum].components) do
						if v == weaponComponent then
							table.remove(self.loadout[loadoutNum].components, k)
							break
						end
					end

					self.triggerEvent('esx:removeWeaponComponent', weaponName, weaponComponent)

				end
			end
		end
	end

  --- @function xPlayer:removeWeaponAmmo
  --- Remove player weapon ammo
  --- @param weaponName string Weapon name
  --- @param ammoCount number Ammo count
  --- @return nil
	self.removeWeaponAmmo = function(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

  --- @function xPlayer:hasWeaponComponent
  --- Check if player weapon has component
  --- @param weaponName string Weapon name
  --- @param weaponComponent string Weapon component
  --- @return boolean
	self.hasWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			for k,v in ipairs(weapon.components) do
				if v == weaponComponent then
					return true
				end
			end

			return false
		else
			return false
		end
	end

  --- @function xPlayer:hasWeapon
  --- Check if player has weapon
  --- @param weaponName string Weapon name
  --- @return boolean
	self.hasWeapon = function(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return true
			end
		end

		return false
	end

  --- @function xPlayer:getWeapon
  --- Get player weapon
  --- @param weaponName string Weapon name
  --- @return table
	self.getWeapon = function(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return k, v
			end
		end

		return
	end

  --- @function xPlayer:showNotification
  --- Show notification to player
  --- @param msg string Notification body
  --- @param flash boolean Weither to flash or not
  --- @param saveToBrief boolean Save to brief (pause menu)
  --- @param hudColorIndex Background color
  --- @return nil
	self.showNotification = function(msg, flash, saveToBrief, hudColorIndex)
		self.triggerEvent('esx:showNotification', msg, flash, saveToBrief, hudColorIndex)
	end

  --- @function xPlayer:showHelpNotification
  --- Show notification to player
  --- @param msg string Notification body
  --- @param thisFrame boolean Show for 1 frame only
  --- @param beep boolean Weither to beep or not
  --- @param duration Notification duration
  --- @return nil
	self.showHelpNotification = function(msg, thisFrame, beep, duration)
		self.triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
	end

  --- @function xPlayer:serialize
  --- Serialize player data
  --- Can be extended by listening for esx:player:serialize event
  ---
  --- AddEventHandler('esx:player:serialize', function(add)
  ---   add({somefield = somevalue})
  --- end)
  --- @return table
  self.serialize = function()

    local data = {
      accounts   = self.getAccounts(),
      coords     = self.getCoords(),
      identifier = self.getIdentifier(),
      inventory  = self.getInventory(),
      job        = self.getJob(),
      loadout    = self.getLoadout(),
      maxWeight  = self.getMaxWeight(),
      money      = self.getMoney()
    }

    TriggerEvent('esx:player:serialize', self, function(extraData)

      for k,v in pairs(extraData) do
        data[k] = v
      end

    end)

    return data

  end

  --- @function xPlayer:serializeDB
  --- Serialize player data for saving in database
  --- Can be extended by listening for esx:player:serialize:db event
  ---
  --- AddEventHandler('esx:player:serialize:db', function(add)
  ---   add({somefield = somevalue})
  --- end)
  --- @return table
  self.serializeDB = function()

    local job = self.getJob()

    local data = {
      identifier = self.getIdentifier(),
      accounts   = json.encode(self.getAccounts(true)),
      group      = self.getGroup(),
      inventory  = json.encode(self.getInventory(true)),
      job        = job.name,
      job_grade  = job.grade,
      loadout    = json.encode(self.getLoadout(true)),
      position   = json.encode(self.getCoords())
    }

    TriggerEvent('esx:player:serialize:db', self, function(extraData)

      for k,v in pairs(extraData) do
        data[k] = v
      end

    end)

    return data

  end

  TriggerEvent('esx:player:create', self)  -- You can hook this event to extend xPlayer

  return self

end

function LoadExtendedPlayer(identifier, playerId, cb)

  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', { ['@identifier'] = identifier }, function(result)

    local tasks = {}

    local userData = {
      playerId   = playerId,
      identifier = identifier,
      weight     = 0,
      name       = GetPlayerName(playerId),
      inventory  = {},
      loadout    = {},
    }

    for entryName, entryValue in pairs(result[1]) do

      TriggerEvent('esx:player:load:' .. entryName, identifier, playerId, result[1], userData, function(task)
        tasks[#tasks + 1] = task
      end)

    end

    Async.parallelLimit(tasks, 5, function(results)

      for i=1, #results, 1 do

        local result = results[i]

        for k,v in pairs(result) do
          userData[k] = v
        end

      end

      local xPlayer = CreateExtendedPlayer(userData)

      ESX.Players[playerId] = xPlayer

      TriggerEvent('esx:playerLoaded', playerId, xPlayer)

      xPlayer.triggerEvent('esx:playerLoaded', xPlayer.serialize())
      xPlayer.triggerEvent('esx:createMissingPickups', ESX.Pickups)
      xPlayer.triggerEvent('esx:registerSuggestions', ESX.RegisteredCommands)

      if cb ~= nil then
        cb()
      end

    end)

  end)

end

AddEventHandler('esx:player:load:accounts', function(identifier, playerId, row, userData, addTask)

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

AddEventHandler('esx:player:load:job', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data                   = {}
    local jobObject, gradeObject = {}, {}

    if ESX.DoesJobExist(row.job, row.job_grade) then
      jobObject, gradeObject = ESX.Jobs[row.job], ESX.Jobs[row.job].grades[tostring(row.job_grade)]
    else

      print(('[es_extended] [^3WARNING^7] Ignoring invalid job for %s [job: %s, grade: %s]'):format(identifier, job, grade))

      job, grade = 'unemployed', '0'
      jobObject, gradeObject = ESX.Jobs[row.job], ESX.Jobs[row.job].grades[tostring(rrow.job_grade)]

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

AddEventHandler('esx:player:load:inventory', function(identifier, playerId, row, userData, addTask)

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
        print(('[es_extended] [^3WARNING^7] Ignoring invalid item "%s" for "%s"'):format(name, identifier))
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

AddEventHandler('esx:player:load:group', function(identifier, playerId, row, userData, addTask)

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

AddEventHandler('esx:player:load:loadout', function(identifier, playerId, row, userData, addTask)

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

AddEventHandler('esx:player:load:position', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    if row.position and row.position ~= '' then
      data = json.decode(row.position)
    else
      print('[es_extended] [^3WARNING^7] Column "position" in "users" table is missing required default value. Using backup coords, fix your database.')
      data = {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}
    end

    cb({coords = data})

  end)

end)
