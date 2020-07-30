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

module.Id    = 0
module.Data  = {}

module.Cache = {
  player = {
    ped    = 0,
    coords = vector3(0.0, 0.0, 0.0)
  },
  current = {
    marker = {},
    npc    = {},
  },
  using   = {},
}

module.Register = function(data)

  local idx = -1

  for i=1, #module.Data, 1 do
    if module.Data[i].name == data.name then
      idx = i
      break
    end
  end

  if module.Id >= 65535 then
    data.__id = 1
  else
    data.__id = module.Id + 1
  end

  data.size = (type(data.size) == 'number') and {x = data.size, y = data.size, z = data.size} or data.size

  if data.faceCamera   == nil then data.faceCamera   = false end
  if data.bobUpAndDown == nil then data.bobUpAndDown = false end
  if data.rotate       == nil then data.rotate       = false end

  module.Id = data.__id

  if idx == -1 then
    module.Data[#module.Data + 1] = data
  else
    module.Data[idx] = data
  end

end

module.ShowHelpNotification = function(msg)
  module.msg    = msg
  module.active = true
end

module.StopHelpNotification = function()
  module.active = false
  module.msg    = nil
end
