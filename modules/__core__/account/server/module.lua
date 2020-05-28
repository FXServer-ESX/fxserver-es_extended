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

self.Accounts = {}

Account = Extends(EventEmitter)

function Account:constructor(name, owner, money)

  if (money == nil) or (tonumber(money) ~= money) then
    money = 0
  end

  if module.Accounts[name] ~= nil then
    print('[warning] there is already an active instance of account => ' .. name .. ' returning that instance')
    return module.Accounts[name]
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

  self.money   = money
  self.ensured = false

  self:on('ensure', function()

    self.ensured = true
    self.ready   = true

    self:emit('ready')

  end)

  self:ensure()

  module.Accounts[name] = self

  print('new account => ' .. self.name)

end

function Account:ensure(cb)

  MySQL.Async.fetchAll('SELECT * FROM accounts WHERE name = @name',{['@name'] = self.name}, function(rows)

    if rows[1] then

      local row = rows[1]

      self.owner  = row.owner
      self.shared = not not row.owner
      self.money  = row.money

      self:emit('ensure')

      if cb then
        cb()
      end

    else

      local shared = 0

      if self.shared then
        shared = 1
      end

      MySQL.Async.execute('INSERT INTO `accounts` (name, owner, money) VALUES (@name, @owner, @money)', {
        ['@name']  = self.name,
        ['@owner'] = owner,
        ['@money'] = self.money
      }, function(rowsChanged)

        self:emit('ensure')

        if cb then
          cb()
        end

      end)

    end

  end)

end

function Account:save(cb)

  Citizen.CreateThread(function()

    while not self.ready do
      Citizen.Wait(0)
    end

    MySQL.Async.execute('UPDATE `accounts` SET money = @money WHERE name = @name', {
      ['@name']  = self.name,
      ['@money'] = self.money
    }, function()

      self:emit('save')

      if cb then
        cb()
      end

    end)

  end)

end

function Account:get()
  return self.money
end

function Account:set(money)

  local orig = self.money
  self.money = money

  if money < orig then
    self:emit('remove', orig - money)
  elseif money > orig then
    self:emit('add', money - orig)
  end

end

function Account:add(money)

  self.money = self.money + money

  if money < 0 then
    self:emit('remove', math.abs(money))
  elseif money > 0 then
    self:emit('add', money)
  end

end

function Account:remove(money)

  self.money = self.money - money

  if money < 0 then
    self:emit('add', math.abs(money))
  elseif money > 0 then
    self:emit('remove', money)
  end

end

--[[
on('esx:db:ready', function()

  local account = Account:create('test')

  account:on('save', function()
    print(account.name .. ' saved => ' .. account:get())
  end)

  account:on('add', function(amount)
    print('add', amount)
  end)

  account:on('remove', function(amount)
    print('remove', amount)
  end)

  account:on('ready', function()

    account:set(0)

    account:set(1000)
    account:set(250)
    account:set(2000)
    account:remove(5)
    account:remove(-100)
    account:add(5)
    account:add(-100)

    account:save(function()
      print('callbacks also')
    end)

  end)

end)
]]--
