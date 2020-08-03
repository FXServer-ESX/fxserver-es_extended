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

-- Immediate definitions

local __print = print

_print = function(...)

  local args = {...}
  local str  = '[^4esx^7'

  for i=1, #args, 1 do
    if i == 1 then
      str = str .. '' .. tostring(args[i])
    else
      str = str .. ' ' .. tostring(args[i])
    end
  end

  __print(str)

end

print = function(...)

  local args = {...}
  local str  = ']'

  for i=1, #args, 1 do
    str = str .. ' ' .. tostring(args[i])
  end

  _print(str)

end

local tableIndexOf = function(t, val)

  for i=1, #t, 1 do
    if t[i] == val then
      return i
    end
  end

  return -1

end

-- ESX base
ESX                = {}
ESX.Loaded         = false
ESX.Ready          = false
ESX.Modules        = {}
ESX.TaskCount      = 1
ESX.CancelledTasks = {}

ESX.GetConfig = function()
  return Config
end

ESX.LogError = function(err, loc)
  loc = loc or '<unknown location>'
  print(debug.traceback('^1[error] in ^5' .. loc .. '^7\n\n^5message: ^1' .. err .. '^7\n'))
end

ESX.EvalFile = function(resource, file, env)

  env           = env or {}
  env._G        = env
  local code    = LoadResourceFile(resource, file)
  local fn      = load(code, '@' .. resource .. ':' .. file, 't', env)
  local success = true

  local status, result = xpcall(fn, function(err)
    success = false
    ESX.LogError(err, trace, '@' .. resource .. ':' .. file)
  end)

  return env, success

end

ESX.GetTaskId = function()

  local id      = (ESX.TaskCount + 1 < 65635) and (ESX.TaskCount + 1) or 1
  ESX.TaskCount = id

  return id

end

ESX.ClearTask = function(id)
  ESX.CancelledTasks[id] = true
end

ESX.AckClearedTask = function(id)
  ESX.CancelledTasks[id] = nil
end

ESX.IsTaskCancelled = function(id)
  return ESX.CancelledTasks[id]
end

ESX.SetTimeout = function(msec, cb)

  local id = ESX.GetTaskId()

  SetTimeout(msec, function()

    if ESX.CancelledTasks[id] then
      ESX.AckClearedTask(id)
    else
      cb()
    end

  end)

  return id

end

ESX.ClearTimeout = ESX.ClearTask

ESX.SetInterval = function(msec, cb)

  local id = ESX.GetTaskId()

  local run

  run = function()

    ESX.SetTimeout(msec, function()

      if ESX.IsTaskCancelled(id) then
        ESX.AckClearedTask(id)
      else
        cb()
        run()
      end

    end)

  end

  run()

  return id

end

ESX.ClearInterval = ESX.ClearTask

ESX.SetTick = function(fn)

  local id = ESX.GetTaskId()

  Citizen.CreateThread(function()

    while not ESX.IsTaskCancelled(id) do
      fn()
      Citizen.Wait(0)
    end

    ESX.AckClearedTask(id)

  end)

  return id

end

ESX.ClearTick = ESX.ClearTask

-- ESX main module
ESX.Modules['boot'] = {}
local module        = ESX.Modules['boot']

local resName = GetCurrentResourceName()
local modType = IsDuplicityVersion() and 'server' or 'client'

module.GroupNames        = json.decode(LoadResourceFile(resName, 'config/modules.groups.json'))
module.Groups            = {}
module.Entries           = {}
module.EntriesOrders     = {}

for i=1, #module.GroupNames, 1 do

  local groupName        = module.GroupNames[i]
  local modules          = json.decode(LoadResourceFile(resName, 'modules/__' .. groupName .. '__/modules.json'))
  module.Groups[groupName] = modules

  for j=1, #modules, 1 do
    local modName           = modules[j]
    module.Entries[modName] = groupName
  end

end

module.GetModuleEntryPoints = function(name, group)

  local prefix          = '__' .. group .. '__/'
  local shared, current = false, false

  if LoadResourceFile(resName, 'modules/' .. prefix .. name .. '/shared/module.lua') ~= nil then
    shared = true
  end

  if LoadResourceFile(resName, 'modules/' .. prefix .. name .. '/' .. modType .. '/module.lua') ~= nil then
    current = true
  end

  return shared, current

end

module.IsModuleInGroup = function(name, group)
  return module.Entries[name] ~= nil
end

module.GetModuleGroup = function(name)
  return module.Entries[name]
end

module.ModuleHasEntryPoint = function(name, group)
  local shared, current = module.GetModuleEntryPoints(name, group)
  return shared or current
end

module.CreateModuleEnv = function(name, group)

  local env = {}

  for k,v in pairs(env) do
    env[k] = v
  end

  env.__NAME__     = name
  env.__GROUP__    = group
  env.__RESOURCE__ = resName
  env.__DIR__      = 'modules/__' .. group .. '__/' .. name
  env.run          = function(file, _env) return ESX.EvalFile(env.__RESOURCE__, env.__DIR__ .. '/' .. file, _env or env) end
  env.module       = {}
  env.M            = module.LoadModule

  env.print = function(...)

    local args   = {...}
    local str    = '^7/^5' .. group .. '^7/^3' .. name .. '^7]'

    for i=1, #args, 1 do
      str = str .. ' ' .. tostring(args[i])
    end

    _print(str)

  end

  local menv         = setmetatable(env, {__index = _G, __newindex = _G})
  env._ENV           = menv
  env.module.__ENV__ = menv

  return env

end

module.LoadModule = function(name)

  if ESX.Modules[name] == nil then

    local group = module.GetModuleGroup(name)

    if group == nil then
      ESX.LogError('module [' .. name .. '] is not declared in modules.json', '@' .. resName .. ':modules/__core__/__main__/module.lua')
    end

    local prefix = '__' .. group .. '__/'

    module.EntriesOrders[group] = module.EntriesOrders[group] or {}

    TriggerEvent('esx:module:load:before', name, group)

    local menv            = module.CreateModuleEnv(name, group)
    local shared, current = module.GetModuleEntryPoints(name, group)

    local env, success, _success = nil, true, false

    if shared then

      env, _success = ESX.EvalFile(resName, 'modules/' .. prefix .. name .. '/shared/module.lua', menv)

      if _success then
        env, _success = ESX.EvalFile(resName, 'modules/' .. prefix .. name .. '/shared/events.lua', menv)
      else
        success = false
      end

      if _success then
        menv, _success = ESX.EvalFile(resName, 'modules/' .. prefix .. name .. '/shared/main.lua', menv)
      else
        success = false
      end

    end

    if current then

      env, _success = ESX.EvalFile(resName, 'modules/' .. prefix .. name .. '/' .. modType .. '/module.lua', menv)

      if _success then
        env, _success = ESX.EvalFile(resName, 'modules/' .. prefix .. name .. '/' .. modType .. '/events.lua', menv)
      else
        success = false
      end

      if _success then
        env, _success = ESX.EvalFile(resName, 'modules/' .. prefix .. name .. '/' .. modType .. '/main.lua', menv)
      else
        success = false
      end

    end

    if success then

      ESX.Modules[name] = menv['module']

      module.EntriesOrders[group][#module.EntriesOrders[group] + 1] = name

      TriggerEvent('esx:module:load:done', name, group)

    else

      ESX.LogError('module [' .. name .. '] does not exist', '@' .. resName .. ':modules/__core__/__main__/module.lua')
      TriggerEvent('esx:module:load:error', name, group)

      return nil, true

    end

  end

  return ESX.Modules[name], false

end

module.Boot = function()

  for i=1, #module.GroupNames, 1 do

    local groupName = module.GroupNames[i]
    local group     = module.Groups[groupName]

    for j=1, #group, 1 do

      local name = group[j]

      if module.ModuleHasEntryPoint(name, groupName) then
        M(name, groupName)
      end

    end

  end

  on('esx:ready', function()
    print('^2ready')
  end)

  ESX.Loaded = true

  emit('esx:load')

end

M = module.LoadModule
