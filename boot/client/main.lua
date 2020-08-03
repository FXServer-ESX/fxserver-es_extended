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

local module = ESX.Modules['boot']
local HUD    = module.LoadModule('game.hud', true)

-- Clear spawnLock
if exports.spawnmanager ~= nil then -- TODO remove check if https://github.com/citizenfx/cfx-server-data/pull/104 is merged
  exports.spawnmanager:forceRespawn()
end

-- Pause menu disables HUD display
if Config.EnableHud then

  ESX.SetInterval(300, function()

    if IsPauseMenuActive() and not ESX.IsPaused then
      ESX.IsPaused = true
      HUD.SetDisplay(0.0)
    elseif not IsPauseMenuActive() and ESX.IsPaused then
      ESX.IsPaused = false
      HUD.SetDisplay(1.0)
    end

  end)

end
