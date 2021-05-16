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

local utils = M('utils')

module.Ready, module.Frame, module.OpenStatusATM = false, nil, false

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Frame = Frame('atm', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/atm/data/html/index.html', true)

module.Frame:on('load', function()
    module.Ready = true
    emit('esx:atm:ready')
end)



module.OpenATM = function(firstName, lastName, accounts)


  module.OpenStatusATM = true

  local name = firstName .. ' ' .. lastName

  module.Frame:postMessage({ method = 'open', playerName = name, balance = accounts.fleeca })

  module.Frame:focus(true, true)

end


module.CloseATM = function ()

  module.OpenStatusATM = false

  module.Frame:postMessage({ method = 'close' })

  module.Frame:unfocus()

  ClearPedTasks(PlayerPedId())

end



module.Frame:on('message', function (msg)

  if msg.action == 'atm.close' then
    module.CloseATM()
  elseif msg.action == 'atm.deposit' then
    local targetAccount = tostring(msg.data.targetAccount)
    local amount = tonumber(msg.data.amount)
    print(targetAccount)
    module.Deposit(targetAccount, amount)
  elseif msg.action == 'atm.withdraw' then
    local sourceAccount = tostring(msg.data.sourceAccount)
    local amount = tonumber(msg.data.amount)
    module.Withdraw(sourceAccount, amount)
  elseif msg.action == 'atm.transfer' then
    local sourceAccount = tostring(msg.data.sourceAccount)
    local targetAccount = tostring(msg.data.targetAccount)
    local targetId = tonumber(msg.data.targetId)
    local amount = tonumber(msg.data.amount)
    module.Transfer(sourceAccount, targetAccount, targetId, amount)
  end

end)


module.Deposit = function(targetAccount, amount)

  request('esx:atm:deposit', function(result, newBalance)
    if result then
      module.Frame:postMessage({ method = 'setMessage', type = 'deposit', variant = 'success', newBalance = newBalance})
    else
      module.Frame:postMessage({ method = 'setMessage', type = 'deposit', variant = 'error' })
    end
  end, targetAccount, amount)

end


module.Withdraw = function(sourceAccount, amount)

  request('esx:atm:withdraw', function(result, newBalance)
    if result then
      module.Frame:postMessage({ method = 'setMessage', type = 'withdraw', variant = 'success', newBalance = newBalance})
    else
      module.Frame:postMessage({ method = 'setMessage', type = 'withdraw', variant = 'error' })
    end
  end, sourceAccount, amount)

end


module.Transfer = function(sourceAccount, targetAccount, targetId, amount)

  request('esx:atm:transfer', function(result, newBalance)
    if result then
      module.Frame:postMessage({ method = 'setMessage', type = 'transfer', variant = 'success', newBalance = newBalance})
    else
      module.Frame:postMessage({ method = 'setMessage', type = 'transfer', variant = 'error' })
    end
  end, sourceAccount, targetAccount, targetId, amount)

end


