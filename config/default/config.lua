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

Config = {}

Config.Locale = "en"

Config.Accounts = {
  bank = _U("account_bank"),
  black_money = _U("account_black_money"),
  money = _U("account_money")
}

Config.Items = {}

Config.StartingAccountMoney = {
  bank = 50000,
  black_money = 0,
  money = 0
}

Config.BackpackWeight = {
  [40] = 16,
  [41] = 20,
  [44] = 25,
  [45] = 23
}

Config.EnableSocietyPayouts = false -- pay from the society account that the player is employed at? Requirement= esx_society
Config.DisableWantedLevel = true
Config.EnableHud = true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.EnablePvP = true -- enable pvp?
Config.MaxWeight = 24 -- the max inventory weight without backpack

Config.PaycheckInterval = 7 * 60000 -- how often to recieve pay checks in milliseconds

Config.EnableDebug = false
Config.InventoryKey = "REPLAY_START_STOP_RECORDING_SECONDARY" -- Key F2 by default
Config.EnableLoadScreen = true

Config.Modules = {
  accessories = true,
  addonaccount = true,
  addoninventory = true,
  container = true,
  datastore = true,
  db = true,
  hud = true,
  input = true,
  interact = true,
  skin = true,
  society = true,
  voice = true,
  identity = true
}
