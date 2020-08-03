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

M('class')
M('events')
M('string')
local utils = M('utils')

module.RegisteredCommands = {}

Command = Extends(EventEmitter, 'Command')

function Command:constructor(name, group, description)

  -- ensure name and group arn't nil
  if not(name) then
    error("A name is required for a Command.")
  end

  local doesCommandNameExists = table.find(module.RegisteredCommands, function(command) return command.name == name end)
  if doesCommandNameExists then
    utils.printWarning(("A command with name: %s already registered, register it would remove the old one"):format(name))
  end

  self.super:ctor()

  self.registered = false
  self.name = name
  self.group = group
  self.description = description
  self.arguments = {}
  self.handler = nil
  self.rconAllowed = false
end

function Command:addArgument(name, argumentType, description, isOptional)
  -- ensure name isn't nil
  if not(name) then
    error("A name is required for Command:addArgument [1].")
  end

  -- set default values if none provided
  if not(argumentType) then
    argumentType = "string"
  end

  if not(description) then
    description = ""
  end

  if not(isOptional) then
    isOptional = false
  end

  -- ensure argumentType is a recognized value, one of string, number, player
  local authorizedArgumentType = {"string", "number", "player"}

  local isTypeAuthorized = table.find(authorizedArgumentType, function (value) return value == argumentType end)

  if (not(isTypeAuthorized)) then
    error(("The type %s is not recognized."):format(argumentType))
  end

  -- ensure type of description and isOptional are correct
  if type(description) ~= "string" then
    error(("description must be a string not %s."):format(type(description)))
  end

  if type(isOptional) ~= "boolean" then
    error(("description must be a boolean not %s."):format(type(isOptional)))
  end

  -- add argument to the list of command arguments
  table.insert(self.arguments, {name = name, type = argumentType, description = description, isOptional = isOptional})
end

function Command:setHandler(commandHandler)
  -- ensure the handler is a function
  if type(commandHandler) ~= "function" then
    error(("commandHandler must be a function not %s."):format(type(commandHandler)))
  end

  self.handler = commandHandler
end

function Command:getSuggestion()
  local commandParametersHelp = {}

  for i,v in ipairs(self.arguments) do
    table.insert(commandParametersHelp, {name = v.name, help = ("%s | type: %s"):format(v.description, v.type)})
  end

  return commandParametersHelp
end

function Command:setRconAllowed(value)
  if (type(value) ~= 'boolean') then
    error("Expect value to be boolean.")
  end

  self.rconAllowed = value
end

function Command:register()
  if not(self.handler) then
    error(("Cannot register command %s, you need to set a command handler with command:setHandler."):format(self.name))
  end

  -- add the command to the command list
  table.insert(module.RegisteredCommands, self)

  -- a generic handler which parse arguments and retrieve base player
  local genericHandler = function(source, args, rawCommand)
    local sourcePlayer = Player.fromId(source)

    if not(sourcePlayer) and not(self.rconAllowed) then
      error(("Cannot retrieve sourcePlayer in Command handler %s, source : %s. Rcon isn't allowed for this command."):format(self.name, source))
    end

    -- for each arguments let's try to map them with given arguments
    local parsedArgs = {}
    for i,v in ipairs(self.arguments) do
      local commandArgument = v
      local givenArgument = args[i]

      -- TODO compare to see if it's a required argument or no
      if (not(givenArgument == nil)) then

        -- if the command argument is a number, let's ensure the user type a number
        if commandArgument.type == "number" then

          if not(string.onlyContainsDigit(givenArgument)) then

            -- it's from RCON
            if (source == 0) then
              print(('[^1Error^7] Argument %s needs to be a %s, %s given.'):format(commandArgument.name, commandArgument.type, givenArgument))
              return
            end
            
            emitClient('chat:addMessage', source, {
              color = { 255, 0, 0 },
              multiline = true,
              args = {("%s Command"):format(self.name), ('[^1Error^7] Argument %s needs to be a %s, %s given.'):format(commandArgument.name, commandArgument.type, givenArgument)}
            })
            return
          end
          parsedArgs[commandArgument.name] = tonumber(givenArgument)

        -- if the command argument is a player, let's ensure player exists with provided source
        elseif commandArgument.type == "player" then

          local requestedPlayer = Player.fromId(givenArgument)

          if not(requestedPlayer) then

            -- it's from RCON
            if (source == 0) then
              print(('[^1Error^7] Argument %s needs an existing player, player %s not found.'):format(commandArgument.name, givenArgument))
              return
            end

            emitClient('chat:addMessage', source, {
              color = { 255, 0, 0 },
              multiline = true,
              args = {("%s Command"):format(self.name), ('[^1Error^7] Argument %s needs an existing player, player %s not found.'):format(commandArgument.name, givenArgument)}
            })
            return
          end
          parsedArgs[commandArgument.name] = requestedPlayer
        
        -- if the command argument is a string, just pass 
        else
          parsedArgs[commandArgument.name] = givenArgument
        end
      end
    end

    self.handler(sourcePlayer, parsedArgs, args)
  end

  RegisterCommand(self.name, genericHandler, self.group ~= nil)

  emitClient('chat:addSuggestion', -1, ('/%s'):format(self.name), self.description, self:getSuggestion())

  if (self.group ~= nil) then
    -- allow this command to be executed by the provided group
    ExecuteCommand(('remove_aces_for_object command.%s'):format(self.name))
    ExecuteCommand(('add_ace group.%s command.%s allow'):format(self.group, self.name))
  end

  self.registered = true
end
