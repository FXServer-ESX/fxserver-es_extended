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
M('class')
M('table')

self.Stores = {}

DataStore = Extends(EventEmitter)

function DataStore:constructor(name, owner, data)

  if module.Stores[name] ~= nil then
    print('[warning] there is already an active instance of datastore => ' .. name .. ' returning that instance')
    return module.Stores[name]
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

  self.data    = data or {}
  self.ensured = false

  self:on('ensure', function()

    self.ensured = true
    self.ready   = true

    self:emit('ready')

  end)

  self:ensure()

  module.Stores[name] = self

  print('new datastore => ' .. self.name)

end

function DataStore:ensure(cb)

  MySQL.Async.fetchAll('SELECT * FROM datastores WHERE name = @name',{['@name'] = self.name}, function(rows)

    if rows[1] then

      local row = rows[1]

      self.owner  = row.owner
      self.shared = not not row.owner
      self.data   = json.decode(row.data)

      self:emit('ensure')

      if cb then
        cb()
      end

    else

      local shared = 0

      if self.shared then
        shared = 1
      end

      local encoded = json.encode(self.data)

      if encoded == '[]' then
        encoded = '{}'
      end

      MySQL.Async.execute('INSERT INTO `datastores` (name, owner, data) VALUES (@name, @owner, @data)', {
        ['@name']   = self.name,
        ['@owner']  = owner,
        ['@data']   = encoded
      }, function(rowsChanged)

        self:emit('ensure')

        if cb then
          cb()
        end

      end)

    end

  end)

end

function DataStore:save(cb)

  Citizen.CreateThread(function()

    while not self.ready do
      Citizen.Wait(0)
    end

    local encoded = json.encode(self.data)

    if encoded == '[]' then
      encoded = '{}'
    end

    MySQL.Async.execute('UPDATE `datastores` SET data = @data WHERE name = @name', {
      ['@name'] = self.name,
      ['@data'] = encoded
    }, function()

      self:emit('save')

      if cb then
        cb()
      end

    end)

  end)

end

function DataStore:get(path)

  if path == nil or path == '' then
    return self.data
  else
    return table.get(self.data, path)
  end

end

function DataStore:set(path, val)

  if path == nil then
    error('DataStore:set(path, val) => path should not be nil but can be an empty string to replace whole datastore')
  end

  if path == '' then
    self.data = val
  else
    table.set(self.data, path, val)
  end

end

--[[
on('esx:db:ready', function()

  local ds = DataStore:create('test')

  ds:on('save', function()
    print(ds.name .. ' saved => ' .. json.encode(ds:get()))
  end)

  ds:on('ready', function()

    ds:set('foo', 'bar')

    ds:save(function()
      print('callbacks also')
    end)

  end)

end)
]]--
