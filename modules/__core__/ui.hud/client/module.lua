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

module.Ready      = false
module.Frames     = {}
module.FocusOrder = {}
module.CursorPos  = {x = 0, y = 0}

local ensureReady = function(fn)

  if module.Ready then
    fn()
  else

    local tick

    tick = ESX.SetTick(function()

      if module.Ready then
        ESX.ClearTick(tick)
        fn()
      end

    end)

  end

end

local createFrame = function(name, url, visible)

  if visible == nil then
    visible = true
  end

  ensureReady(function()
    SendNUIMessage({action = 'create_frame', name = name, url = url, visible = visible})
  end)

end

local showFrame = function(name)

  ensureReady(function()
    SendNUIMessage({action = 'show_frame', name = name})
  end)

end

local hideFrame = function(name)

  ensureReady(function()
    SendNUIMessage({action = 'hide_frame', name = name})
  end)

end

local destroyFrame = function(name)

  ensureReady(function()
    SendNUIMessage({action = 'destroy_frame', name = name})
  end)

end

local sendFrameMessage = function(name, msg)

  ensureReady(function()
    SendNUIMessage({target = name, data = msg})
  end)

end

local focusFrame = function(name, cursor)

  ensureReady(function()
    SendNUIMessage({action = 'focus_frame', name = name})
    SetNuiFocus(true, cursor)
  end)

end

Frame = Extends(EventEmitter, 'Frame')

Frame.unfocusAll = function()
  module.FocusOrder = {}
  SetNuiFocus(false)
end

function Frame:constructor(name, url, visible)

  self.super:ctor();

  self.name      = name
  self.url       = url
  self.loaded    = false
  self.destroyed = false
  self.visible   = visible
  self.hasFocus  = false
  self.hasCursor = false
  self.mouse     = {down = {}, pos = {x = -1, y = -1}}

  self:on('load', function()
    self.loaded = true
  end)

  createFrame(self.name, self.url, self.visible)

  module.Frames[self.name] = self
  
  self:on('message', function(msg)
    if msg.__esxinternal then
      self:emit('internal', msg.action, table.unpack(msg.args or {}))
    end
  end)

  self:on('internal', function(action, ...)
    emit(action, ...)
    self:emit(action, ...)
  end)

  self:on('mouse:down', function(button)
    self.mouse.down[button] = true
  end)

  self:on('mouse:up', function(button)
    self.mouse.down[button] = false
  end)

  self:on('mouse:move', function(x, y)
    
    local last = table.clone(self.mouse)
    local data = table.clone(last)

    data.pos.x, data.pos.y = x, y

    if (last.x ~= -1) and (last.y ~= -1) then

      local offsetX = x - last.pos.x
      local offsetY = y - last.pos.y

      data.direction = {left = offsetX < 0, right = offsetX > 0, up = offsetY < 0, down = offsetY > 0}

      emit('mouse:move:offset', offsetX, offsetY, data)
      self:emit('mouse:move:offset', offsetX, offsetY, data)

    end

    self.mouse = data

  end)

end

function Frame:destroy(name)
  self:unfocus()
  self.destroyed = true
  destroyFrame(self.name)
  self:emit('destroy')
end

function Frame:postMessage(msg)
  sendFrameMessage(self.name, msg)
end

function Frame:focus(cursor)

  self.hasFocus  = true
  self.hasCursor = cursor

  local newFocusOrder = {}

  for i=1, #module.FocusOrder, 1 do

    local frame = module.FocusOrder[i]

    if frame ~= self then
      newFocusOrder[#newFocusOrder + 1] = frame
    end

  end

  newFocusOrder[#newFocusOrder + 1] = self

  module.FocusOrder = newFocusOrder

  focusFrame(self.name, self.hasCursor)

  self:emit('focus')

end

function Frame:unfocus()

  local newFocusOrder = {}

  for i=1, #module.FocusOrder, 1 do

    local frame = module.FocusOrder[i]

    if frame ~= self then
      newFocusOrder[#newFocusOrder + 1] = frame
    end

  end

  if #newFocusOrder > 0 then
    local previousFrame = newFocusOrder[#newFocusOrder]
    SetNuiFocus(true, previousFrame.hasCursor)
  else
    SetNuiFocus(false, false)
  end

  module.FocusOrder = newFocusOrder

  self:emit('unfocus')

end

function Frame:show()
  self.visible = true
  showFrame(self.name)
end

function Frame:hide()
  self.visible = false
  hideFrame(self.name)
end
