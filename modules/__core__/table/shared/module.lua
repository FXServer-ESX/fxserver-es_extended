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

M('string')

table.sizeOf = function(t)

  local count = 0

  for k,v in pairs(t) do
    count = count + 1
  end

  return count

end

table.isArray = function(t)

  local keys = {}

  for k,v in pairs(t) do

    local num = tonumber(k)

    if num ~= k then
      return false
    end

    table.insert(keys, num)

  end

  table.sort(keys, function(a, b) return a < b end)

  for i=1, #keys, 1 do
    if keys[i] ~= i then
      return false
    end
  end

  return true

end

table.indexOf = function(t, val)

  for i=1, #t, 1 do
    if t[i] == val then
      return i
    end
  end

  return -1

end

table.lastIndexOf = function(t, val)

  for i=#t, 1, -1 do
    if t[i] == val then
      return i
    end
  end

  return -1
end

table.find = function(t, cb)

  for i=1, #t, 1 do
    if cb(t[i]) then
      return t[i]
    end
  end

  return nil

end

table.findIndex = function(t, cb)

  for i=1, #t, 1 do
    if cb(t[i]) then
      return i
    end
  end

  return -1
end

table.filter = function(t, cb)

  local newTable = {}

  for i=1, #t, 1 do
    if cb(t[i]) then
      table.insert(newTable, t[i])
    end
  end

  return newTable

end

table.map = function(t, cb)

  local newTable = {}

  for i=1, #t, 1 do
    newTable[i] = cb(t[i], i)
  end

  return newTable

end

table.reverse = function(t)

  local newTable = {}

  for i=#t, 1, -1 do
    table.insert(newTable, t[i])
  end

  return newTable

end

table.clone = function(t)

  if type(t) ~= 'table' then return t end

  local meta   = getmetatable(t)
  local target = {}

  for k,v in pairs(t) do
    if type(v) == 'table' then
      target[k] = table.clone(v)
    else
      target[k] = v
    end
  end

  setmetatable(target, meta)

  return target

end

table.concat = function(t1, t2)

  if type(t2) == 'string' then
    local separator = t2
    return table.join(t1, separator)
  end

  local t3 = table.clone(t1)

  for i=1, #t2, 1 do
    table.insert(t3, t2[i])
  end

  return t3

end

table.join = function(t, sep)

  local sep = sep or ','
  sep       = tostring(sep)
  local str = ''

  for i=1, #t, 1 do

    if i > 1 then
      str = str .. sep
    end

    str = str .. tostring(t[i])

  end

  return str

end

table.merge = function(t1, t2)

  for k,v in pairs(t2) do
    if type(v) == 'table' then
      table.merge(t1[k] or {}, t2[k] or {})
    else
      t1[k] = t2[k]
    end
  end

  return t1

end

table.by = function(t, k)

  local t2 = {}

  for i=1, #t, 1 do
    local entry = t[i]
    t2[k] = entry[i]
  end

  return t2

end

table.get = function(t, path)

  local split = string.split(path, '.')
  local obj   = t

  for i=1, #split, 1 do

    local key    = split[i]
    local keyNum = tonumber(key)

    if keyNum ~= nil then
      key = keyNum
    end

    obj = obj[key]

  end

  return obj

end

table.set = function(t, path, v)

  local split = string.split(path, '.')
  local obj   = t

  for i=1, #split, 1 do

    local key    = split[i]
    local keyNum = tonumber(key)

    if keyNum ~= nil then
      key = keyNum
    end

    if i == #split then
      obj[key] = v
    else
      obj = obj[key]
    end

  end

end
