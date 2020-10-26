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

-- (maybe need any change in the future)
onRequest('esx:admin:isAuthorized', function(source, cb, playerId)
  if playerId and playerId == Config.rconSecureCode then
    return cb(true)
  end

  if not playerId then playerId = source end
  return cb(IsPlayerAceAllowed(playerId, 'command')) -- esx:roles if have role admin "ExecuteCommand(('add_principal identifier.USER group.admin')" or use other method, idk.

  -- TODO: Need timeout or warning if not admin, and prevent excessive calls (in both, client and server side.)
end)

onClient('esx:admin:sendToPlayer', function(target, ...)
  if IsPlayerAceAllowed(source, 'command') then
    emitClient('esx:admin:inPlayerCommand', target, ...)
  else
    emitClient('chat:addMessage', source, {args = {'^1SYSTEM', _U('act_imp')}})
  end
end)
