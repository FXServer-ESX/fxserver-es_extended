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

Serializable = Extends(EventEmitter, 'Serializable')

function Serializable:constructor(data)

  self.super:ctor()

  self.__ACCESSORS = {}

  for k,v in pairs(data) do
    self:field(k, v)
  end

end

function Serializable:field(name, value)

  self[name] = value

  if not self:hasField(name) then

    self.__ACCESSORS[name] = {

      get = DefineGetter(self, name),

      set = DefineSetter(self, name, function(self, value)
        self[name] = value
        self:emit('change', name, value)
      end)

    }

  end

end

function Serializable:hasField(name)
  return self.__ACCESSORS[name] ~= nil
end

function Serializable:serialize(encode)

  local data = {}

  for name, accessor in pairs(self.__ACCESSORS) do

    local processedGetter = accessor.get(self)

    -- avoid circular references errors
    if (type(processedGetter) == "table" and type(processedGetter.serialize) == "function") then
      processedGetter = processedGetter:serialize()
    end

    data[name] = processedGetter
  end

  return encode == nil and data or encode(data)
  
end
