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

M('events')

self.RegisterdCommands = {}

self.Register = function(name, group, cb, allowConsole, suggestion)

  if type(name) == 'table' then

    for k, v in ipairs(name) do
      self.Register(v, group, cb, allowConsole, suggestion)
    end

    return

  end

  if self.RegisterdCommands[name] then

    print(('[^3WARNING^7] A command "%s" is already registered, overriding command'):format(name))

    if self.RegisterdCommands[name].suggestion then
      emitClient('chat:removeSuggestion', -1, ('/%s'):format(name))
    end

  end

  if suggestion then
    if not suggestion.arguments then suggestion.arguments = {} end
    if not suggestion.help      then suggestion.help      = '' end

    emitClient('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
  end

  self.RegisterdCommands[name] = {
      group        = group,
      cb           = cb,
      allowConsole = allowConsole,
      suggestion   = suggestion
  }

  RegisterCommand(name, function(playerId, args, rawCommand)

    local command = self.RegisterdCommands[name]

    if not command.allowConsole and playerId == 0 then
      print(('[^3WARNING^7] %s'):format( _U('commanderror_console')))
    else

      local xPlayer, error = xPlayer.fromId(playerId), nil

      if command.suggestion then

        if command.suggestion.validate then
          if #args ~= #command.suggestion.arguments then
            error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
          end
        end

        if not error and command.suggestion.arguments then

          local newArgs = {}

          for k, v in ipairs(command.suggestion.arguments) do

            if v.type then

              if v.type == 'number' then

                local newArg = tonumber(args[k])

                if newArg then
                  newArgs[v.name] = newArg
                else
                  error = _U('commanderror_argumentmismatch_number', k)
                end

              elseif v.type == 'player' or v.type == 'playerId' then

                local targetPlayer = tonumber(args[k])

                if args[k] == 'me' then
                  targetPlayer = playerId
                end

                if targetPlayer then

                  local xTargetPlayer = xPlayer.fromId(targetPlayer)

                    if xTargetPlayer then

                      if v.type == 'player' then
                        newArgs[v.name] = xTargetPlayer
                      else
                        newArgs[v.name] = targetPlayer
                      end

                    else
                      error =_U('commanderror_invalidplayerid')
                    end
                else
                  error = _U('commanderror_argumentmismatch_number', k)
                end

              elseif v.type == 'string' then

                newArgs[v.name] = args[k]

              elseif v.type == 'item' then

                if ESX.Items[args[k]] then
                  newArgs[v.name] = args[k]
                else
                  error = _U('commanderror_invaliditem')
                end

              elseif v.type == 'weapon' then

                if ESX.GetWeapon(args[k]) then
                  newArgs[v.name] = string.upper(args[k])
                else
                  error = _U('commanderror_invalidweapon')
                end

              elseif v.type == 'any' then

                newArgs[v.name] = args[k]

              end
            end

            if error then break end

          end

          args = newArgs

        end
      end

      if error then

        if playerId == 0 then
          print(('[^3WARNING^7] %s^7'):format(error))
        else
          xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
        end

      else

          cb(xPlayer or false, args, function(msg)
            if playerId == 0 then
              print(('[^3WARNING^7] %s^7'):format(msg))
            else
              xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
            end
          end)

      end

    end

  end, true)

  if type(group) == 'table' then
      for k, v in ipairs(group) do
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
      end
  else
    ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
  end
end
