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

-- the Events file contains event handlers
local Input = M('input')

on('esx:nui:ready', module.onNuiReady)

-- Key Controls
Input.On('released', Input.Groups.MOVE, Input.Controls.SAVE_REPLAY_CLIP, function(lastPressed)

  if not ESX.IsDead then
    module.openMenu()
  end

end)