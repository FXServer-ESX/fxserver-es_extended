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

M('table')

-- Namespaces
module.string  = module.string  or {}
module.table   = module.table   or {}
module.weapon  = module.weapon  or {}
module.game    = module.game    or {}
module.vehicle = module.vehicle or {}
module.random  = module.random  or {}
module.time    = module.time    or {}
module.game    = module.game    or {}

-- Locals
local printableChars = {}

for i = 48,  57 do printableChars[#printableChars + 1] = string.char(i) end
for i = 65,  90 do printableChars[#printableChars + 1] = string.char(i) end
for i = 97, 122 do printableChars[#printableChars + 1] = string.char(i) end

local uppercaseLetters    = {}
local uppercaseLettersStr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

for c in uppercaseLettersStr:gmatch(".") do
  table.insert(uppercaseLetters, c)
end

-- String
module.string.random = function(length, recurse)

  if not recurse then
    math.randomseed(GetGameTimer())
  end

	if length > 0 then
		return module.string.random(length - 1, true) .. printableChars[math.random(1, #printableChars)]
	else
		return ''
  end

end

module.string.parsetpl = function(tpl, data)

  local str = ''

  for i=1, #tpl, 1 do

    local tplPart = tostring(tpl[i])

    if tplPart:sub(1, 1) == '@' then
      str = str .. table.get(data, tplPart:sub(2))
    else
      str = str .. tplPart
    end

  end

  return str

end

-- Table
module.table.dump = function(t, indent)

  if indent == nil then
    indent = 1
  end

  local doIndent = function(s, c)

    if c == nil then
      c = indent
    end

    for i = 1, c, 1 do
      s = s .. '  '
    end

    return s

  end

  if type(t) == 'table' then

    local s = ''

    s = doIndent(s)
    s = '{\n'

    local count = 0

    if table.isArray(t) then

      for i=1, #t, 1 do

        local v = t[i]

        if count > 0 then
          s = s .. ',\n'
        end

        s = doIndent(s)
        s = s .. module.table.dump(v, indent + 1)

        count = count + 1

      end

    else

      for k,v in pairs(t) do

        if type(k) ~= 'number' then
          k = '\'' .. k ..'\''
        end

        if count > 0 then
          s = s .. ',\n'
        end

        s = doIndent(s)
        s = s .. '[' .. k .. '] = ' .. module.table.dump(v, indent + 1)

        count = count + 1

      end

    end

    s = doIndent(s)
    s = s .. '\n'
    s = doIndent(s, indent - 1)
    s = s .. '}'

    return s

  else

    if type(t) == 'string' then
      return '\'' .. t .. '\''
    end

    return tostring(t)

  end

end

-- Weapon
module.weapon.get = function(weaponName)

  weaponName = string.upper(weaponName)

	for k,v in ipairs(Config.Weapons) do
		if v.name == weaponName then
			return k, v
		end
  end

end

module.weapon.getFromHash = function(weaponHash)

  for k,v in ipairs(Config.Weapons) do
		if v.hash == weaponHash then
			return v
		end
  end

end

module.weapon.getAll = function()
	return Config.Weapons
end

if IsDuplicityVersion() then

  module.weapon.getLabel = function(weaponName)
    print('[warning] weapon labels only available client-side, ' .. weaponName .. ' will be returned instead')
    return weaponName
  end

else

  module.weapon.getLabel = function(weaponName)

    weaponName = string.upper(weaponName)

    for k,v in ipairs(Config.Weapons) do
      if v.name == weaponName then
        return v.label
      end
    end

  end

end

module.weapon.getComponent = function(weaponName, weaponComponent)

  weaponName = string.upper(weaponName)
	local weapons = Config.Weapons

	for k,v in ipairs(Config.Weapons) do
		if v.name == weaponName then
			for k2,v2 in ipairs(v.components) do
				if v2.name == weaponComponent then
					return v2
				end
			end
		end
  end

end


module.vehicle.generateRandomPlate = function()

  -- Force random on each iteration
  math.randomseed(GetGameTimer())

  local firstPart  = string.format("%02d", math.random(0, 99))
  local stringPart = '';

  for i = 1, 3 do
    stringPart = stringPart .. uppercaseLetters[math.random(1, #uppercaseLetters)]
  end

  local lastPart = string.format("%03d", math.random(0, 999))

  return firstPart .. stringPart .. lastPart

end

-- Random
module.random.isLucky = function(percentChance, cb, callCbOnUnlucky)

  local hasCallback     = cb ~= nil
  local callCbOnUnlucky = callCbOnUnlucky ~= nil and callCbOnUnlucky or false

  if percentChance <= 0 or percentChance >= 100 then

    local result = percentChance >= 100 and true or false

    if hasCallback and (callCbOnUnlucky or result) then
      cb(result)
    else
      return result
    end

  end

  -- Force random on each iteration
  math.randomseed(GetGameTimer())

  local randomNumber = 100 * math.random()
  local result       = randomNumber <= percentChance

  if hasCallback and (callCbOnUnlucky or result) then
    cb(result)
  else
    return result
  end

end

module.random.isUnlucky = module.random.isLucky

module.random.inRange = function(min, max)

  local min = min ~= nil and min or 0
  local max = max ~= nil and max or 100

  -- Force random on each iteration
  math.randomseed(GetGameTimer())

  return math.random(min, max)

end

module.time.fromTimestamp = function(timestamp)
  
  local w = math.floor(timestamp / 86400 / 7)
  local d = math.floor(timestamp / 86400 % 7)
  local h = math.floor(timestamp / 3600  % 24)
  local m = math.floor(timestamp / 60    % 60)
  local s = math.floor(timestamp % 60)

  return w, d, h, m, s

end

module.game.isFreemodeModel = function(nameOrHash)
  local name = type(nameOrHash) == 'string' and nameOrHash or PED_MODELS_BY_HASH[nameOrHash]
  return (name == 'mp_m_freemode_01') or (name == 'mp_f_freemode_01')
end

module.game.isHumanModel = function(nameOrHash)

  local name = type(nameOrHash) == 'string' and nameOrHash or PED_MODELS_BY_HASH[nameOrHash]
  name       = name or ''

  return name:sub(1, 2) ~= 'a_'

end

module.game.isAnimalModel = function(nameOrHash)

  local name = type(nameOrHash) == 'string' and nameOrHash or PED_MODELS_BY_HASH[nameOrHash]
  name       = name or ''

  return name:sub(1, 2) == 'a_'

end

module.printWarning = function(str)
  print(('[^3WARNING^7] %s'):format(str))
end

module.try = function(f, catch_f)
  local status, exception = pcall(f)
  if not status then
    catch_f(exception)
  end
end
  