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

local nop = function()
  return function() end
end

ESX.SetInterval(10, function()

  if #module.FocusOrder > 0 then

    local x, y = GetNuiCursorPosition()

    if (x ~= module.CursorPos.x) or (y ~= module.CursorPos.y) then
      
      module.FocusOrder[#module.FocusOrder]:emit('message', {__esxinternal = true, action = 'mouse:move', args = {x, y}}, nop)

      module.CursorPos.x = x
      module.CursorPos.y = y

    end

  end

end)