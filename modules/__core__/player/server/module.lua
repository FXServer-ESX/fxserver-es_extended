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

M('class')         -- Require 'class' builtin module
local DB = M('db') -- Require 'db' builtin module

---- Class representing a player
--- @class xPlayer
xPlayer = Extends(nil)

-- Static properties / methods

  xPlayer.all           = {}
  xPlayer.dbSyncStarted = false
  xPlayer.accessors     = {}

  xPlayer.createAccessor = function(name)

    local firstCharUpper = name:gsub("^%l", string.upper)
    local getter         = 'get' .. firstCharUpper
    local setter         = 'set' .. firstCharUpper

    xPlayer[getter] = function(self)
      return self[name]
    end

    xPlayer[setter] = function(self, val)
      self[name] = val
    end

    xPlayer.accessors[name] = {name = name, db = false}

  end

  xPlayer.createDBAccessor = function(name, field, encode, decode)

    encode = encode or function(x) return x end
    decode = decode or function(x) return x end

    local firstCharUpper = name:gsub("^%l", string.upper)
    local getter         = 'get' .. firstCharUpper
    local setter         = 'set' .. firstCharUpper

    xPlayer.createAccessor(name, default)

    xPlayer.accessors[name] = {name = name, db = true, field = field}

    on('esx:db:init', function(initTable, extendTable)
      extendTable('users', {field})
    end)

    on('esx:player:load:' .. field.name, function(identifier, playerId, row, userData, addTask)

      addTask(function(cb)
        cb({[name] = decode(row[field.name])})
      end)

    end)

    on('esx:player:serialize', function(player, add)
      add({[name] = player[getter](player)})
    end)

    on('esx:player:serialize:db', function(player, add)
      add({[field.name] = encode(player[getter](player))})
    end)

  end

  xPlayer.hasAccessor = function(name)
    return xPlayer.accessors[name] ~= nil
  end

  xPlayer.hasDBAccessor = function(name)
    return (xPlayer.accessors[name] ~= nil) and (xPlayer.accessors[name].db == true)
  end

  --- @function xPlayer.fromId
  --- Get xPlayer from id
  --- @param id number Player id
  --- @return xPlayer
  xPlayer.fromId = function(id)
    return xPlayer.all[tostring(id)]
  end

  --- @function xPlayer.getAll
  --- Get all players
  --- @return table
  xPlayer.getAll = function()
    return xPlayer.all
  end

  --- @function xPlayer.forEach
  --- Iterate over every players with a callback
  --- @return nil
  xPlayer.forEach = function(cb)

    for k,v in pairs(xPlayer.all) do
      cb(v)
    end

  end

  --- @function xPlayer.set
  --- Add xPlayer to xPlayer.all table
  --- @param id number Player id
  --- @param player xPlayer xPlayer instance
  --- @return nil
  xPlayer.set = function(id, player)
    xPlayer.all[tostring(id)] = player
  end

  --- @function xPlayer.fromIdentifier
  --- Get xPlayer from identifier
  --- @param identifier string Player identifier
  --- @return xPlayer
  xPlayer.fromIdentifier = function(identifier)

    for k,v in pairs(xPlayer.all) do
      if v.identifier == identifier then
        return v
      end
    end

    return nil

  end

  --- @function xPlayer.load
  --- Load xPlayer
  --- @param identifier string Player identifier
  --- @param playerId number Player id
  --- @param cb function Callback
  --- @return nil
  xPlayer.load = function(identifier, playerId, cb)

    Citizen.CreateThread(function()

      while not ESX.Ready do
        Citizen.Wait(0)
      end

      print('loading ' .. GetPlayerName(playerId) .. ' (' .. playerId .. '|' .. identifier .. ')')

      MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', { ['@identifier'] = identifier }, function(result)

        local row   = result[1]
        local tasks = {}

        local userData = {
          playerId   = playerId,
          identifier = identifier,
          weight     = 0,
          name       = GetPlayerName(playerId),
          inventory  = {},
          loadout    = {},
        }

        local fieldNames = DB.GetFieldNames('users')

        for i=1, #fieldNames, 1 do

          local fieldName = fieldNames[i]

          emit('esx:player:load:' .. fieldName, identifier, playerId, row, userData, function(task)
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

          local player = xPlayer:create(userData)

          xPlayer.set(playerId, player)

          emit('esx:playerLoaded', playerId, xPlayer)

          player:emit('esx:playerLoaded', player:serialize())
          --player:emit('esx:createMissingPickups', ESX.Pickups)
          --player:emit('esx:registerSuggestions',  ESX.RegisteredCommands)

          print('loaded ' .. GetPlayerName(playerId) .. ' (' .. playerId .. '|' .. identifier .. ')')

          if cb ~= nil then
            cb(cb)
          end

        end)

      end)

    end)

  end

  xPlayer.saveAll = function(cb)

    asyncTasks = {}

    xPlayer.forEach(function(player)
      table.insert(asyncTasks, function(cb2)
        player:save(cb2)
      end)
    end)

    Async.parallelLimit(asyncTasks, 8, function(results)

      print(('saved %s player(s)'):format(#asyncTasks))

      if cb then
        cb()
      end

    end)

  end

  xPlayer.startDBSync = function()

    if xPlayer.dbSyncStarted then
      return
    end

    print('starting db sync')

    local save

    save = function()

      xPlayer.saveAll(function()
        SetTimeout(10 * 60 * 1000, save)
      end)

    end

    SetTimeout(10 * 60 * 1000, save)

  end

  xPlayer.onJoin = function(playerId)

    local identifier

    for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
      if string.match(v, 'license:') then
        identifier = string.sub(v, 9)
        break
      end
    end

    if identifier then

      if xPlayer.fromIdentifier(identifier) then
        DropPlayer(playerId, ('there was an error loading your character!\nError code: identifier-active-ingame\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same Rockstar account.\n\nYour Rockstar identifier: %s'):format(identifier))
      else

        print('client connected =>', GetPlayerName(playerId) .. ' (' .. playerId .. '|' .. identifier .. ')')

        MySQL.Async.fetchScalar('SELECT 1 FROM users WHERE identifier = @identifier', {
          ['@identifier'] = identifier
        }, function(result)

          if result then

            xPlayer.load(identifier, playerId)

          else

            local accounts = {}

            for account,money in pairs(Config.StartingAccountMoney) do
              accounts[account] = money
            end

            MySQL.Async.execute('INSERT INTO users (accounts, identifier) VALUES (@accounts, @identifier)', {
              ['@accounts']   = json.encode(accounts),
              ['@identifier'] = identifier
            }, function(rowsChanged)

              xPlayer.load(identifier, playerId)

            end)

          end
        end)
      end
    else
      DropPlayer(playerId, 'there was an error loading your character!\nError code: identifier-missing-ingame\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.')
    end
  end

  -- Instance properties / methods
  function xPlayer:constructor(data)

    local mt = getmetatable(self)

    self.source    = data.playerId
    self.maxWeight = Config.MaxWeight

    for k,v in pairs(data) do

      if type(v) == 'function' then
        mt[k] = v
      else
        self[k] = v
      end

    end

    ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))

    emit('esx:player:create', self)  -- You can hook this event to extend xPlayer

  end

  function xPlayer:save(cb)

    local data      = self:serializeDB()
    local statement = 'UPDATE users SET'
    local fields    = {}

    local first = true

    for k, v in pairs(data) do

        if first then
          statement = statement .. ' `' .. k .. '` = ' .. '@' .. k
          first = false
        else
          statement = statement .. ', `' .. k .. '` = ' .. '@' .. k
        end

        fields['@' .. k] = v

    end

    statement = statement .. ' WHERE `identifier` = @identifier'

    MySQL.Async.execute(statement, fields, function(rowsChanged)

      print(('Saved player "%s^7"'):format(self:getName()))

      if cb then
        cb()
      end

    end)

  end

  --- @function xPlayer:emit
  --- Trigger event to player
  --- @param eventName string Event name
  --- @param ...rest any Event arguments
  --- @return nil
  function xPlayer:emit(eventName, ...)
    emitClient(eventName, self.source, ...)
  end

  --- @function xPlayer:setCoords
  --- Update player coords on both server and client
  --- @param coords vector3 Coords
  --- @return nil
  function xPlayer:setCoords(coords)
    self:updateCoords(coords)
    self:emit('esx:teleport', coords)
  end

  --- @function xPlayer:updateCoords
  --- Update player coords on server
  --- @param coords vector3 Coords
  --- @return nil
  function xPlayer:updateCoords(coords)
    self.coords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1), heading = ESX.Math.Round(coords.heading or 0.0, 1)}
  end

  --- @function xPlayer:getCoords
  --- Update player coords on server
  --- @param asVector boolean Get coords as vector or table ?
  --- @return any
  function xPlayer:getCoords(asVector)
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
  function xPlayer:kick(reason)
    DropPlayer(self.source, reason)
  end

  --- @function xPlayer:setMoney
  --- Set amount for player 'money' account
  --- @param money number Amount
  --- @return nil
  function xPlayer:setMoney(money)
    money = ESX.Math.Round(money)
    self:setAccountMoney('money', money)
  end

  --- @function xPlayer:getMoney
  --- Get amount for player 'money' account
  --- @return number
  function xPlayer:getMoney()
    return self:getAccount('money').money
  end

  --- @function xPlayer:addMoney
  --- Add amount for player 'money' account
  --- @param money number Amount
  --- @return nil
  function xPlayer:addMoney(money)
    money = ESX.Math.Round(money)
    self:addAccountMoney('money', money)
  end

  --- @function xPlayer:removeMoney
  --- Remove amount for player 'money' account
  --- @param money number Amount
  --- @return nil
  function xPlayer:removeMoney(money)
    money = ESX.Math.Round(money)
    self:removeAccountMoney('money', money)
  end

  --- @function xPlayer:getIdentifier
  --- Get player identifier
  --- @return string
  function xPlayer:getIdentifier()
    return self.identifier
  end

  --- @function xPlayer:setGroup
  --- Set player group
  --- @param newGroup string New group
  --- @return nil
  function xPlayer:setGroup(newGroup)
    ExecuteCommand(('remove_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
    self.group = newGroup
    ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
  end

  --- @function xPlayer:getGroup
  --- Get player group
  --- @return string
  function xPlayer:getGroup()
    return self.group
  end

  --- @function xPlayer:setField
  --- Set field on this xPlayer instance
  --- @param k string Field name
  --- @param v any Field value
  --- @return nil
  function xPlayer:setField(k, v)
    self[k] = v
  end

  --- @function xPlayer:getField
  --- Get field on this xPlayer instance
  --- @param k string Field name
  --- @return any
  function xPlayer:getField(k)
    return self[k]
  end

  --- @function xPlayer:getAccounts
  --- Get player accounts
  --- @param minimal boolean Compact output
  --- @return table
  function xPlayer:getAccounts(minimal)
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
  function xPlayer:getAccount(account)
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
  function xPlayer:getInventory(minimal)
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
  function xPlayer:getJob()
    return self.job
  end

  --- @function xPlayer:getLoadout
  --- Get player inventory
  --- @param minimal boolean Compact output
  --- @return table
  function xPlayer:getLoadout(minimal)
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
  function xPlayer:getName()
    return self.name
  end

  --- @function xPlayer:setName
  --- Set player name
  --- @param newName string New name
  --- @return nil
  function xPlayer:setName(newName)
    self.name = newName
  end

  --- @function xPlayer:setAccountMoney
  --- Set player account money
  --- @param accountName string Account name
  --- @param money number Amount
  --- @return nil
  function xPlayer:setAccountMoney(accountName, money)
    if money >= 0 then
      local account = self:getAccount(accountName)

      if account then
        local prevMoney = account.money
        local newMoney = ESX.Math.Round(money)
        account.money = newMoney

        self:emit('esx:setAccountMoney', account)
      end
    end
  end

  --- @function xPlayer:addAccountMoney
  --- Add player account money
  --- @param accountName string Account name
  --- @param money number Amount
  --- @return nil
  function xPlayer:addAccountMoney(accountName, money)
    if money > 0 then
      local account = self:getAccount(accountName)

      if account then
        local newMoney = account.money + ESX.Math.Round(money)
        account.money = newMoney

        self:emit('esx:setAccountMoney', account)
      end
    end
  end

  --- @function xPlayer:addAccountMoney
  --- Add player account money
  --- @param accountName string Account name
  --- @param money number Amount
  --- @return nil
  function xPlayer:removeAccountMoney(accountName, money)
    if money > 0 then
      local account = self:getAccount(accountName)

      if account then
        local newMoney = account.money - ESX.Math.Round(money)
        account.money = newMoney

        self:emit('esx:setAccountMoney', account)
      end
    end
  end

  --- @function xPlayer:getInventoryItem
  --- Get player inventory item
  --- @param name string Account name
  --- @return table
  function xPlayer:getInventoryItem(name)
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
  function xPlayer:addInventoryItem(name, count, notify)

    if notify == nil then
      notify = false
    end

    local item = self:getInventoryItem(name)

    if item then
      count = ESX.Math.Round(count)
      item.count = item.count + count
      self.weight = self.weight + (item.weight * count)

      emit('esx:onAddInventoryItem', self.source, item.name, item.count)
      self:emit('esx:addInventoryItem', item.name, item.count, notify)
    end
  end

  --- @function xPlayer:removeInventoryItem
  --- Remove player inventory item
  --- @param name string Account name
  --- @param count number Amount
  --- @param notify boolean Weither to notify or not
  --- @return nil
  function xPlayer:removeInventoryItem(name, count, notify)

    if notify == nil then
      notify = false
    end

    local item = self:getInventoryItem(name)

    if item then
      count = ESX.Math.Round(count)
      local newCount = item.count - count

      if newCount >= 0 then
        item.count = newCount
        self.weight = self.weight - (item.weight * count)

        emit('esx:onRemoveInventoryItem', self.source, item.name, item.count)
        self:emit('esx:removeInventoryItem', item.name, item.count, notify)
      end
    end
  end

  --- @function xPlayer:removeInventoryItem
  --- Remove player inventory item
  --- @param name string Account name
  --- @param count number Amount
  --- @return nil
  function xPlayer:setInventoryItem(name, count)
    local item = self:getInventoryItem(name)

    if item and count >= 0 then
      count = ESX.Math.Round(count)

      if count > item.count then
        self:addInventoryItem(item.name, count - item.count)
      else
        self:removeInventoryItem(item.name, item.count - count)
      end
    end
  end

  --- @function xPlayer:getWeight
  --- Get player weight
  --- @return number
  function xPlayer:getWeight()
    return self.weight
  end

  --- @function xPlayer:getMaxWeight
  --- Get max player weight
  --- @return number
  function xPlayer:getMaxWeight()
    return self.maxWeight
  end

  --- @function xPlayer:canCarryItem
  --- Check if player can carry count of given item
  --- @return boolean
  function xPlayer:canCarryItem(name, count)
    local currentWeight, itemWeight = self.weight, ESX.Items[name].weight
    local newWeight = currentWeight + (itemWeight * count)

    return newWeight <= self.maxWeight
  end

  --- @function xPlayer:maxCarryItem
  --- Get max count of specific item player can carry
  --- @return number
  function xPlayer:maxCarryItem(name)
    local count = 0
    local currentWeight, itemWeight = self:getWeight(), ESX.Items[name].weight
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
  function xPlayer:canSwapItem(firstItem, firstItemCount, testItem, testItemCount)
    local firstItemObject = self:getInventoryItem(firstItem)
    local testItemObject = self:getInventoryItem(testItem)

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
  function xPlayer:setMaxWeight(newWeight)
    self.maxWeight = newWeight
    self:emit('esx:setMaxWeight', self.maxWeight)
  end

  --- @function xPlayer:setJob
  --- Set player job
  --- @param job string New job
  --- @param grade number New job grade
  --- @return nil
  function xPlayer:setJob(job, grade)
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

      emit('esx:setJob', self.source, self.job, lastJob)
      self:emit('esx:setJob', self.job)
    else
      print(('[^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
    end
  end

  --- @function xPlayer:addWeapon
  --- Add weapon to player
  --- @param weaponName string Weapon name
  --- @param ammo number Ammo
  --- @return nil
  function xPlayer:addWeapon(weaponName, ammo)

    if ammo == nil then
      ammo = 1000
    end

    if not self:hasWeapon(weaponName) then

      table.insert(self.loadout, {
        name = weaponName,
        ammo = ammo,
        components = {},
        tintIndex = 0
      })

      self:emit('esx:addWeapon', weaponName, ammo)
      self:emit('esx:addInventoryItem', weaponLabel, false, true)
    end
  end

  --- @function xPlayer:addWeaponComponent
  --- Add weapon to player
  --- @param weaponName string Weapon name
  --- @param weaponComponent string Weapon component
  --- @return nil
  function xPlayer:addWeaponComponent(weaponName, weaponComponent)
    local loadoutNum, weapon = self:getWeapon(weaponName)

    if weapon then
      local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

      if component then
        if not self:hasWeaponComponent(weaponName, weaponComponent) then
          table.insert(self.loadout[loadoutNum].components, weaponComponent)
          self:emit('esx:addWeaponComponent', weaponName, weaponComponent)
          self:emit('esx:addInventoryItem', component.label, false, true)
        end
      end
    end
  end

  --- @function xPlayer:addWeaponAmmo
  --- Add ammo to player weapon
  --- @param weaponName string Weapon name
  --- @param ammoCount number Ammo count
  --- @return nil
  function xPlayer:addWeaponAmmo(weaponName, ammoCount)
    local loadoutNum, weapon = self:getWeapon(weaponName)

    if weapon then
      weapon.ammo = weapon.ammo + ammoCount
      self:emit('esx:setWeaponAmmo', weaponName, weapon.ammo)
    end
  end

  --- @function xPlayer:updateWeaponAmmo
  --- Update player weapon ammo
  --- @param weaponName string Weapon name
  --- @param ammoCount number Ammo count
  --- @return nil
  function xPlayer:updateWeaponAmmo(weaponName, ammoCount)
    local loadoutNum, weapon = self:getWeapon(weaponName)

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
  function xPlayer:setWeaponTint(weaponName, weaponTintIndex)
    local loadoutNum, weapon = self:getWeapon(weaponName)

    if weapon then
      local weaponNum, weaponObject = ESX.GetWeapon(weaponName)

      if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
        self.loadout[loadoutNum].tintIndex = weaponTintIndex
        self:emit('esx:setWeaponTint', weaponName, weaponTintIndex)
        self:emit('esx:addInventoryItem', weaponObject.tints[weaponTintIndex], false, true)
      end
    end
  end

  --- @function xPlayer:getWeaponTint
  --- Get player weapon tint index
  --- @param weaponName string Weapon name
  --- @return number
  function xPlayer:getWeaponTint(weaponName)
    local loadoutNum, weapon = self:getWeapon(weaponName)

    if weapon then
      return weapon.tintIndex
    end

    return 0
  end

  --- @function xPlayer:removeWeapon
  --- Remove player weapon
  --- @param weaponName string Weapon name
  --- @return nil
  function xPlayer:removeWeapon(weaponName)

    for k,v in ipairs(self.loadout) do
      if v.name == weaponName then

        for k2,v2 in ipairs(v.components) do
          self:removeWeaponComponent(weaponName, v2)
        end

        table.remove(self.loadout, k)

        self:emit('esx:removeWeapon', weaponName)

        break

      end
    end

  end

  --- @function xPlayer:removeWeaponComponent
  --- Remove player weapon component
  --- @param weaponName string Weapon name
  --- @param weaponComponent string Weapon component
  --- @return nil
  function xPlayer:removeWeaponComponent(weaponName, weaponComponent)
    local loadoutNum, weapon = self:getWeapon(weaponName)

    if weapon then
      local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

      if component then

        if self:hasWeaponComponent(weaponName, weaponComponent) then
          for k,v in ipairs(self.loadout[loadoutNum].components) do
            if v == weaponComponent then
              table.remove(self.loadout[loadoutNum].components, k)
              break
            end
          end

          self:emit('esx:removeWeaponComponent', weaponName, weaponComponent)

        end
      end
    end
  end

  --- @function xPlayer:removeWeaponAmmo
  --- Remove player weapon ammo
  --- @param weaponName string Weapon name
  --- @param ammoCount number Ammo count
  --- @return nil
  function xPlayer:removeWeaponAmmo(weaponName, ammoCount)
    local loadoutNum, weapon = self:getWeapon(weaponName)

    if weapon then
      weapon.ammo = weapon.ammo - ammoCount
      self:emit('esx:setWeaponAmmo', weaponName, weapon.ammo)
    end
  end

  --- @function xPlayer:hasWeaponComponent
  --- Check if player weapon has component
  --- @param weaponName string Weapon name
  --- @param weaponComponent string Weapon component
  --- @return boolean
  function xPlayer:hasWeaponComponent(weaponName, weaponComponent)
    local loadoutNum, weapon = self:getWeapon(weaponName)

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
  function xPlayer:hasWeapon(weaponName)
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
  function xPlayer:getWeapon(weaponName)
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
  function xPlayer:showNotification(msg, flash, saveToBrief, hudColorIndex)
    self:emit('esx:showNotification', msg, flash, saveToBrief, hudColorIndex)
  end

  --- @function xPlayer:showHelpNotification
  --- Show notification to player
  --- @param msg string Notification body
  --- @param thisFrame boolean Show for 1 frame only
  --- @param beep boolean Weither to beep or not
  --- @param duration Notification duration
  --- @return nil
  function xPlayer:showHelpNotification(msg, thisFrame, beep, duration)
    self:emit('esx:showHelpNotification', msg, thisFrame, beep, duration)
  end

  --- @function xPlayer:serialize
  --- Serialize player data
  --- Can be extended by listening for esx:player:serialize event
  ---
  --- on('esx:player:serialize', function(add)
  ---   add({somefield = somevalue})
  --- end)
  --- @return table
  function xPlayer:serialize()

    local data = {
      name       = self:getName(),
      accounts   = self:getAccounts(),
      coords     = self:getCoords(),
      identifier = self:getIdentifier(),
      inventory  = self:getInventory(),
      job        = self:getJob(),
      loadout    = self:getLoadout(),
      maxWeight  = self:getMaxWeight(),
      money      = self:getMoney()
    }

    emit('esx:player:serialize', self, function(extraData)

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
  --- on('esx:player:serialize:db', function(add)
  ---   add({somefield = somevalue})
  --- end)
  --- @return table
  function xPlayer:serializeDB()

    local job = self:getJob()

    local data = {
      identifier = self:getIdentifier(),
      name       = self:getName(),
      accounts   = json.encode(self:getAccounts(true)),
      group      = self:getGroup(),
      inventory  = json.encode(self:getInventory(true)),
      job        = job.name,
      job_grade  = job.grade,
      loadout    = json.encode(self:getLoadout(true)),
      position   = json.encode(self:getCoords())
    }

    emit('esx:player:serialize:db', self, function(extraData)

      for k,v in pairs(extraData) do
        data[k] = v
      end

    end)

    return data

  end
