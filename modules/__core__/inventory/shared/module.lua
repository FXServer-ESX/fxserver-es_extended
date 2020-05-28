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
M('class')
M('table')

Inventory = Extends(EventEmitter)

local itemFlags = {}
local itemDefs  = {}

for k,v in pairs(Config.ItemFlags) do

  if type(k) == 'number' then
    itemFlags[v] = {}
  else
    itemFlags[k] = v
  end

end

for k,v in pairs(Config.Items) do

  if type(k) == 'number' then
    itemDefs[#itemDefs + 1] = v
  else
    itemDefs[#itemDefs + 1] = k
  end

end

for flag, subFlags in pairs(itemFlags) do

  local resolved  = {flag}
  local processed = {}
  local queue     = {}

  for i=1, #subFlags, 1 do
    queue[#queue + 1] = subFlags[i]
  end

  while #queue > 0 do

    local entry   = queue[#queue]
    queue[#queue] = nil

    if table.indexOf(processed, entry) == -1 then

      local entrySubFlags       = itemFlags[entry]
      processed[#processed + 1] = entry
      resolved[#resolved + 1]   = entry

      for i=1, #entrySubFlags, 1 do

        local entrySubFlag = entrySubFlags[i]

        if table.indexOf(processed, entrySubFlag) == -1 then
          queue[#queue + 1] = entrySubFlag
        end

      end

    end

  end

  itemFlags[flag] = resolved

end

Inventory.ItemFlags = setmetatable(itemFlags, {__newindex = function(t, k, v)
  print(' [warning] you are trying to write into Inventory.ItemFlags which is read-only')
end}) -- Lock write access

Inventory.ItemDefs  = setmetatable(itemDefs,  {__newindex = function(t, k, v)
  print(' [warning] you are trying to write into Inventory.ItemDefs which is read-only')
end}) -- Lock write access

function Inventory.hasFlag(itemName, flag)

  if type(flag) ~= 'table' then
    flag = {flag}
  end

  for i=1, #Inventory.ItemFlags, 1 do
    if not Inventory.ItemFlags[itemName][flag] then
      return false
    end
  end

  return true

end

function Inventory.getFlags(itemName)
  return Inventory.ItemFlags[itemName]
end
