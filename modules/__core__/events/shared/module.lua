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

M('class')

-- Gobal events
self.handlers         = {}
self.callbacks        = {}
self.requestCallbacks = {}
self.eventId          = 1
self.requestId        = 1

local getEventId = function()

  if (self.eventId + 1) == 1000000 then
    self.eventId = 1
  else
    self.eventId = self.eventId + 1
  end

  return self.eventId

end

local getRequestId = function()

  if (self.requestId + 1) == 1000000 then
    self.requestId = 1
  else
    self.requestId = self.requestId + 1
  end

  return self.requestId

end

on = function(name, cb)

  local id = getEventId()

  self.handlers[name]     = self.handlers[name] or {}
  self.handlers[name][id] = cb

  return id

end

once = function(name, cb)

  local id

  id = on(name, function(...)
    off(id)
    cb(...)
  end)

end

off = function(name, id)

  self.handlers[name]     = self.handlers[name] or {}
  self.handlers[name][id] = nil

end

emit = function(name, ...)

  self.handlers[name] = self.handlers[name] or {}

  for k,v in pairs(self.handlers[name]) do
    v(...)
  end

end

if IsDuplicityVersion() then

  onClient = function(name, cb)
    RegisterNetEvent(name)
    return AddEventHandler(name, cb)
  end

  offClient = function(name, id)
    RemoveEventHandler(id)
  end

  emitClient = function(name, client, ...)
    TriggerClientEvent(name, client, ...)
  end

  request = function(name, client, cb, ...)

    local id           = getRequestId()
    self.callbacks[id] = cb

    emitClient('esx:request', client, name, id, ...)

  end

else

  onServer = function(name, cb)
    RegisterNetEvent(name)
    return AddEventHandler(name, cb)
  end

  offServer = function(name, id)
    RemoveEventHandler(id)
  end

  emitServer = function(name, ...)
    TriggerServerEvent(name, ...)
  end

  request = function(name, cb, ...)

    local id           = getRequestId()
    self.callbacks[id] = cb

    emitServer('esx:request', name, id, ...)

  end

end

onRequest = function(name, cb)
  self.requestCallbacks[name] = cb
end

-- EventEmitter
EventEmitter = Extends(nil)

function EventEmitter:constructor()
  self.handlers = {}
end

function EventEmitter:on(name, cb)

  local id = getEventId()

  self.handlers[name]     = self.handlers[name] or {}
  self.handlers[name][id] = cb

  return id

end

function EventEmitter:off(name, id)

  self.handlers[name]     = self.handlers[name] or {}
  self.handlers[name][id] = nil

end

function EventEmitter:emit(name, ...)

  self.handlers[name] = self.handlers[name] or {}

  for k,v in pairs(self.handlers[name]) do
    v(...)
  end

end

function EventEmitter:once(name, cb)

  local id

  id = self:on(name, function(...)
    off(id)
    cb(...)
  end)

end
