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

self.Inventories = {}

function Inventory.isItemDefined(name)
  return table.indexOf(Inventory.ItemDefs, name) ~= -1
end

function Inventory:constructor(name, owner, items)

  if module.Inventories[name] ~= nil then
    print('[warning] there is already an active instance of inventory => ' .. name .. ' returning that instance')
    return module.Inventories[name]
  end

  self.super:constructor()

  self.ready = false
  self.name  = name

  if owner then
    self.owner  = owner
    self.shared = true
  else
    self.owner  = nil
    self.shared = false
  end

  self.items   = items or {}
  self.ensured = false

  self:on('ensure', function()

    self.ensured = true
    self.ready   = true

    self:emit('ready')

  end)

  self:ensure()

  module.Inventories[name] = self

  print('new inventory => ' .. self.name)

end

function Inventory:ensure(cb)

  MySQL.Async.fetchAll('SELECT * FROM inventories WHERE name = @name',{['@name'] = self.name}, function(rows)

    if rows[1] then

      local row = rows[1]

      self.owner  = row.owner
      self.shared = not not row.owner
      self.items  = json.decode(row.items)

      self:emit('ensure')

      if cb then
        cb()
      end

    else

      local shared = 0

      if self.shared then
        shared = 1
      end

      MySQL.Async.execute('INSERT INTO `inventories` (name, owner, items) VALUES (@name, @owner, @items)', {
        ['@name']  = self.name,
        ['@owner'] = owner,
        ['@items'] = json.encode(self.items)
      }, function(rowsChanged)

        self:emit('ensure')

        if cb then
          cb()
        end

      end)

    end

  end)

end

function Inventory:save(cb)

  Citizen.CreateThread(function()

    while not self.ready do
      Citizen.Wait(0)
    end

    MySQL.Async.execute('UPDATE `inventories` SET items = @items WHERE name = @name', {
      ['@name']  = self.name,
      ['@items'] = json.encode(self.items)
    }, function()

      self:emit('save')

      if cb then
        cb()
      end

    end)

  end)

end

function Inventory:get(name, full)

  if name then

    if not Inventory.isItemDefined(name) then
      error('item [' .. name .. '] is not defined in config')
    end

    return self.items[name]
  else
    return self.items
  end

end

function Inventory:set(name, count)

  if not Inventory.isItemDefined(name) then
    error('item [' .. name .. '] is not defined in config')
  end

  if data == nil then
    self.items = name
  elseif count == 0 then
    self.items[name] = nil
  else
    self.items[name] = count
  end

end

function Inventory:add(name, count)

  if not Inventory.isItemDefined(name) then
    error('item [' .. name .. '] is not defined in config')
  end

  if self.items[name] == nil then
    self.items[name] = 0
  end

  self.items[name] = self.items[name] + count

  if self.items[name] == 0 then
    self.items[name] = nil
  end

  if count < 0 then
    self:emit('remove', name, math.abs(count))
  elseif count > 0 then
    self:emit('add', name, count)
  end

end

function Inventory:remove(name, count)

  if not Inventory.isItemDefined(name) then
    error('item [' .. name .. '] is not defined in config')
  end

  if self.items[name] == nil then
    self.items[name] = 0
  end

  self.items[name] = self.items[name] - count

  if self.items[name] == 0 then
    self.items[name] = nil
  end

  if count < 0 then
    self:emit('add', name, math.abs(count))
  elseif count > 0 then
    self:emit('remove', name, count)
  end

end

on('esx:db:ready', function()

  local inventory = Inventory:create('test')

  inventory:on('save', function()
    print(inventory.name .. ' saved => ' .. inventory:get())
  end)

  inventory:on('add', function(amount)
    print('add', amount)
  end)

  inventory:on('remove', function(amount)
    print('remove', amount)
  end)

  inventory:on('ready', function()

    inventory:set('something', 15)
    inventory:set('something', 10)

    inventory:save(function()
      print('callbacks also')
    end)

  end)

end)

