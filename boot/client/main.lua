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
-- Will disable the idle camera
ESX.SetInterval(15000, function()
  InvalidateIdleCam()
end)
--- Will remove cops from an area
ESX.SetInterval(5, function()
  local playerPed = PlayerPedId()
  local playerLocalisation = GetEntityCoords(playerPed)
  ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)
end)
--- Toggles dispath for all categories
Citizen.CreateThread(function()
  for i = 1, 15 do
	EnableDispatchService(i, false)
  end
end)
--- Disable certain gameplay elements depending on config settings
ESX.SetInterval(1, function()
  if Config.DisableDefaultHud then
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(8)
    HideHudComponentThisFrame(9)
    HideHudComponentThisFrame(13)
    HideHudComponentThisFrame(19)
  end

  if Config.DisableVehicleRewards then
    DisablePlayerVehicleRewards(PlayerId())
  end

  if Config.DisableNPCDrops then
    RemoveAllPickupsOfType(0xDF711959) -- carbine rifle
    RemoveAllPickupsOfType(0xF9AFB48F) -- pistol
    RemoveAllPickupsOfType(0xA9355DCD) -- pumpshotgun
  end

  if Config.DisableHealthRegeneration then
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
  end

  if Config.DisableWeaponWheel then
    BlockWeaponWheelThisFrame();
	DisableControlAction(0, 37,true);
  end

  if Config.DisableAimAssist then
    if IsPedArmed(PlayerPedId(), 4) then
      SetPlayerLockonRangeOverride(PlayerId(), 2.0)
    end
  end
end)

-- Disable wanted level
if Config.DisableWantedLevel then
  SetMaxWantedLevel(0)
end

--RichPresence
if Config.EnableRichPresence then
  local playerId = PlayerId()
  SetDiscordAppId(tonumber(GetConvar("RichAppId", "757218164345012224")))  -- Change for your APP id there's https://discord.com/developers/applications
  SetDiscordRichPresenceAsset(GetConvar("RichAssetId", "esx_test"))  -- Edit esx_text with your own image. Must be one of your Discord Application
  SetDiscordRichPresenceAssetText("Playing on a ESX2 Server!") -- Edit this with a message or something else you want to show
  SetDiscordRichPresenceAssetSmall(GetConvar("RichAssetId", "esx_test")) -- Edit esx_text with your own image. Must one of your Discord Application
  SetRichPresence("This server is running ESX2!") -- Edit this with a message or something else you want to show
  SetDiscordRichPresenceAssetSmallText(GetPlayerName(playerId) .. " with id " .. GetPlayerServerId(playerId)) -- Edit this with a message or something else you want to show
  SetDiscordRichPresenceAction(0, "Join our Discord server!", "https://discord.com/invite/BBPbB29E")
  SetDiscordRichPresenceAction(1, "Want to help us ?", "https://github.com/esx-framework/esx-reborn")
end
