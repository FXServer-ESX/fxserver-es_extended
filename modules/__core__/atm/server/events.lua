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

onRequest('esx:atm:deposit', function(source, cb, targetAccount, amount)

  local player = Player.fromId(source)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()

  local walletBalance = accounts:getWallet()

  if walletBalance >= amount then
    accounts:removeMoney('wallet',amount)
    accounts:addMoney(targetAccount, amount)
    cb(true, accounts[targetAccount])
  else
    cb(false)
  end

end)

onRequest('esx:atm:withdraw', function(source, cb, sourceAccount, amount)
  local player = Player.fromId(source)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()

  local sourceAccountBalance = accounts[sourceAccount]

  if sourceAccountBalance >= amount then
    accounts:removeMoney(sourceAccount, amount)
    accounts:addMoney('wallet',amount)
    cb(true, accounts[sourceAccount])
  else
    cb(false)
  end
end)

onRequest('esx:atm:transfer', function(source, cb, sourceAccount, targetAccount, targetId, amount)
  local player = Player.fromId(source)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()

  local sourceAccountBalance = accounts[sourceAccount]

  if sourceAccountBalance >= amount then

    local targetPlayer = Player.fromId(targetId)
    local targetIdentity = targetPlayer:getIdentity()
    local targetAccounts = targetIdentity:getAccounts()

    accounts:removeMoney(sourceAccount, amount)
    targetAccounts:addMoney(targetAccount, amount)
    cb(true, accounts[sourceAccount])
  else
    cb(false)
  end
end)
