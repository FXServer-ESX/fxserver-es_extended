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

-- Properties
M('class')
M('player')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

Player.define({
  {name = 'accessories', field = {name = 'accessories', type = 'MEDIUMTEXT', length = nil,  default = '{}', extra = nil}, encode = json.encode, decode = json.decode},
})

function Player:hasAcccessory(name)
  return self:getAcccesories()[name] ~= nil
end

function Player:getAcccessory(name)
  return self:getAcccessories()[name]
end

function Player:setAcccessory(name, item1, item2)

  local accessories = self:getAcccesories()
  local accessory   = accessories[name] or {}
  accessories[name] = {item1, item2}

  self:emit('accessory.set', accessories[name])

end
