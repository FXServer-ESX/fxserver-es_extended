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

-- Init
local constants = {}

local JSONFiles = {
  {'PED_BONE_INDEXES', 'data/ped_bones.json',      true},
  {'PED_COMPONENTS',   'data/ped_components.json', true},
  {'PED_MODEL_NAMES',  'data/ped_models.json',     false},
}

local loadJSONFile = function(enumName, enumPath)
  -- print('load json =>', enumPath, 'as ^3' .. enumName .. '^7')
  constants[enumName] = json.decode(LoadResourceFile(__RESOURCE__, enumPath))
end

for i=1, #JSONFiles, 1 do

  local enumName, enumPath, expand = table.unpack(JSONFiles[i])

  loadJSONFile(enumName, enumPath)

  if expand then

    print('expand ^3' .. enumName .. '^7 enum into global scope')

    for k, v in pairs(constants[enumName]) do
      _G[k] = v
    end

  end

end

module.GetEnumKey = function(enum, value)

  for k,v in pairs(enum) do
    if v == value then
      return k
    end
  end

end

_G.GetEnumKey = module.GetEnumKey

module.GetEnumValue = function(enum, key)
  return enum[key]
end

_G.GetEnumValue = module.GetEnumValue

-- Generic
constants.DEG2RAD = math.pi / 180.0
constants.RAD2DEG = 180.0 / math.pi

-- Ped models
constants.PED_MODELS_BY_NAME = {}
constants.PED_MODELS_BY_HASH = {}
constants.PED_MODELS_HASHES  = {}
constants.PED_MODELS_HUMANS  = {}
constants.PED_MODELS_ANIMALS = {}

print('expand ^3PED_MODEL_NAMES^7 enum into global scope')

for i=1, #constants.PED_MODEL_NAMES, 1 do

  local name      = constants.PED_MODEL_NAMES[i]
  local nameUpper = name:upper()
  local hash      = GetHashKey(name)

  constants.PED_MODELS_HASHES[#constants.PED_MODELS_HASHES + 1] = hash

  constants.PED_MODELS_BY_NAME[name] = hash
  constants.PED_MODELS_BY_HASH[hash] = name

  if name:sub(1, 2) == 'a_' then
    constants.PED_MODELS_ANIMALS[#constants.PED_MODELS_ANIMALS + 1] = hash
  else
    constants.PED_MODELS_HUMANS[#constants.PED_MODELS_HUMANS + 1] = hash
  end

  _G[nameUpper] = hash

end

-- Make all constants global until it break something somehow
for k,v in pairs(constants) do
  -- print('put ^3' .. k .. '^7 into global scope')
  _G[k] = v
end

