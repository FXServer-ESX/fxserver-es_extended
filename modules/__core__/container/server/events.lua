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


on('esx_datastore:ready',      self.OnDependencyReady)
on('esx_addonaccount:ready',   self.OnDependencyReady)
on('esx_addoninventory:ready', self.OnDependencyReady)

onRequest('esx:container:get', function(source, cb, name, restrict)

  restrict = restrict or {
    'account',
    'item',
    'weapon'
  }

  local container = self.Get(name)
  local _items    = container.getAll()

  local items = table.filter(_items, function(e) return table.indexOf(restrict, e.type) ~= -1 end)

  cb(items)

end)

onRequest('esx:container:get:user', function(source, cb, restrict)

  restrict = restrict or {
    'account',
    'item',
    'weapon'
  }

  local player = xPlayer.fromId(source)
  local items  = {}

  if table.indexOf(restrict, 'account') ~= -1 then
    items[#items + 1] = {type = 'account', name = 'money', count = player:getMoney()}
  end

  if table.indexOf(restrict, 'item') ~= -1 then

    local inventory = player:getInventory()

    for i=1, #inventory, 1 do
      local inventoryItem = inventory[i]
      items[#items + 1] = {type = 'item', name = inventoryItem.name, count = inventoryItem.count, label = inventoryItem.label}
    end

  end

  if table.indexOf(restrict, 'weapon') ~= -1 then

    local loadout = player:getLoadout()

    for i=1, #loadout, 1 do
      local weapon = loadout[i]
      items[#items + 1] = {type = 'weapon', name = weapon.name, count = 1}
    end

  end

  cb(items)

end)

-- TODO more checks on weight and such
onRequest('esx:container:pull', function(source, cb, name, itemType, itemName, itemCount)

  local player    = xPlayer.fromId(source)
  local container = self.Get(name)

  local item = container.get(itemType, itemName)

  if item.count >= itemCount then

    container.remove(itemType, itemName, itemCount)

    if itemType == 'account' then
      player:addMoney(itemCount)
    elseif itemType == 'item' then
      player:addInventoryItem(itemName, itemCount)
    elseif itemType == 'weapon' then
      player:addWeapon(itemName)
    end

    cb(true)

  else
    cb(false)
  end

end)

-- TODO more checks on weight and such
onRequest('esx:container:put', function(source, cb, name, itemType, itemName, itemCount)

  local xPlayer   = xPlayer.fromId(source)
  local container = self.Get(name)

  local count = 0

  if itemType == 'account' then
    count = player:getMoney()
  elseif itemType == 'item' then
    local inventoryItem = player:getInventoryItem(itemName)
    count = inventoryItem.count
  elseif itemType == 'weapon' then

    local loadout = player:getLoadout()

    local weapon  = ESX.Table.FindIndex(loadout, function(e)
      return e.name == itemName
    end)

    count = weapon and 1 or 0
  end

  if count >= itemCount then

    if itemType == 'account' then
      player:removeMoney(itemCount)
    elseif itemType == 'item' then
      player:removeInventoryItem(itemName, itemCount)
    elseif itemType == 'weapon' then
      player:removeWeapon(itemName)
    end

    container.add(itemType, itemName, itemCount)

    cb(true)

  else
    cb(false)
  end

end)
