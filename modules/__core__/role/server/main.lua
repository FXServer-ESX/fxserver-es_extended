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

local addRoleCommand = Command("addrole", "admin", "Add a role to a player")
addRoleCommand:addArgument("role", "string", "The role to add")
addRoleCommand:addArgument("targetPlayer", "player", "The player to add the role to")
addRoleCommand:setRconAllowed(true)

addRoleCommand:setHandler(function(player, args)
  local role = args.role
  local targetPlayer = args.targetPlayer

  targetPlayer:addRole(role)
end)

local deleteRoleCommand = Command("delrole", "admin", "Delete a role from a player")
deleteRoleCommand:addArgument("role", "string", "The role to delete")
deleteRoleCommand:addArgument("targetPlayer", "player", "The player to delete the role from")
deleteRoleCommand:setRconAllowed(true)

deleteRoleCommand:setHandler(function(player, args)
  local role = args.role
  local targetPlayer = args.targetPlayer

  targetPlayer:removeRole(role)
end)

addRoleCommand:register()
deleteRoleCommand:register()
