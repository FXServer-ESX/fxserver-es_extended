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

M('command')

module.init = function()
  module.registerTPTMCommand()
  module.registerSpawnVehicleCommand()
  module.registerDeleteVehicleCommand()
  module.registerGiveWeaponCommand()
  module.registerRemoveWeaponsCommand()
  module.registerSetJobCommand()
end

module.registerTPTMCommand = function()
  local tpToMarkerCommand = Command("tptm", "admin", "TP to your marker")

  tpToMarkerCommand:setHandler(function(player)
    emitClient("esx:admin:tptmRequested", player.source)
  end)
  tpToMarkerCommand:register()
end

module.registerSpawnVehicleCommand = function()
  local SpawnVehicleCommand = Command("car", "admin", "Spawn a vehicle")
  SpawnVehicleCommand:addArgument("modelname", "string", "Vehicle modelname")

  SpawnVehicleCommand:setHandler(function(player, args)
    emitClient("esx:spawnVehicle", player.source, args.modelname)
  end)
  SpawnVehicleCommand:register()
end

module.registerDeleteVehicleCommand = function()
  local DeleteVehicleCommand = Command("dv", "admin", "Delete a vehicle")

  DeleteVehicleCommand:setHandler(function(player)
    emitClient("esx:deleteVehicle", player.source, 5)
  end)
  DeleteVehicleCommand:register()
end

module.registerGiveWeaponCommand = function()
  local GiveWeaponCommand = Command("giveweapon", "admin", "Give a weapon to player")
  GiveWeaponCommand:addArgument("targetPlayer", "number", "Target player's id")
  GiveWeaponCommand:addArgument("weaponName", "string", "Weapon name")
  GiveWeaponCommand:addArgument("weaponAmmo", "number", "Weapon ammo")

  GiveWeaponCommand:setHandler(function(args)
    emitClient('esx:addWeapon', args.targetPlayer.source, args.weaponName, args.weaponAmmo)
  end)
  GiveWeaponCommand:register()
end

module.registerRemoveWeaponsCommand = function()
  local RemoveWeaponsCommand = Command("clearloadout", "admin", "Clear a player's loadout")
  RemoveWeaponsCommand:addArgument('targetPlayer', "number", "Target player's id")

  RemoveWeaponsCommand:setHandler(function(args)
    emitClient("esx:removeAllPedWeapons", args.targetPlayer.source)
    -- TODO, CLEAR LOADOUT
  end)
  RemoveWeaponsCommand:register()
end

module.registerSetJobCommand = function()
  local SetJobCommand = Command("setjob", "admin", "Set player's job")
  SetJobCommand:addArgument('targetPlayer', "number", "Target player's id")
  SetJobCommand:addArgument('job', "string", "Job name")
  SetJobCommand:addArgument('rank', "number", "Job rank")

  SetJobCommand:setHandler(function(args)
    -- TODO, SET JOB
  end)
  SetJobCommand:register()
end