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

-- The main file contains imports and logic of the module
M('ui.menu') -- This module provides global Menu factory method
M('events') -- This module provides easy ways to receive/send event
local input = M('input')

module.init()

input.On('released', input.Groups.MOVE, input.Controls.SAVE_REPLAY_CLIP, module.onMenuOpenRequested)