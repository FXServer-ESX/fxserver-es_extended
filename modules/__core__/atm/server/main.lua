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

M("command")

local atmCommand = Command("atm", "user", _U('open_atm'))
atmCommand:setHandler(function(player, args)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()
	emitClient("esx:atm:openATM", player.source, identity:getFirstName(), identity:getLastName(), accounts:serialize())
end)

atmCommand:register()
