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

local db = M('db')

M('serializable')
M('table')

local pass = function(x) return x end

Persist = function(schema, pk, ...)

  local mixins        = {...}
  local debugName     = debugName or 'PersistBase_' .. schema
  local extDebugName  = 'Persist_' .. schema
  local fields        = {}
  local dbfields      = {}
  local pType         = Extends(Serializable, debugName)

  function pType:constructor(data)

    self.super:ctor(data)

    self.__SCHEMA = schema
    self.__PK     = pk

    for k,v in pairs(fields) do

      local dataValue = data[k]

      if dataValue == nil then

        if not db.IsExpression(v.data.default) then
          -- authorize nil to be inserted as NULL even when using encoder
          -- (bypass the encoder when nil is provided)
          if v.decode ~= nil and v.data.default ~= nil then
            dataValue = v.decode(v.data.default)
          end
        end

      end

      self:field(k, dataValue)

    end

  end

  if #mixins > 0 then
    pType = Mixin(debugName, pType, ...)
  end

  local set = function(name, field, encode, decode)

    encode                  = encode or pass
    decode                  = decode or pass
    dbfields[#dbfields + 1] = field
    fields[name]            = {data = field, encode = encode, decode = decode}

  end

  pType.define = function(data)
    for i=1, #data, 1 do
      local entry = data[i]
      set(entry.name, entry.field, entry.encode, entry.decode)
    end
  end

  pType.findOne = function(query, cb)

    local queryFields = {}
    local keys        = {}

    for k,v in pairs(fields) do
      keys[#keys + 1] = v.data.name
    end

    for k,v in pairs(query) do
      queryFields[fields[k].data.name] = v
    end

    local sql, data = db.DBQuery().select(keys).from(schema).where(queryFields).escape().build()

    MySQL.Async.fetchAll(sql, data, function(rows)

      if rows[1] == nil then
        cb(nil)
      else

        local row  = rows[1]
        local data = {}

        for k,v in pairs(fields) do
          data[k] = v.decode(row[v.data.name])
        end

        cb(pType(data))

      end

    end)

  end

  pType.find = function(query, cb)

    local queryFields = {}
    local keys        = {}
    local queryFlag   = false

    for k,v in pairs(fields) do
      keys[#keys + 1] = v.data.name
    end

    for k,v in pairs(query) do
      queryFields[fields[k].data.name] = v
      queryFlag = true
    end

    local baseQuery = db.DBQuery().select(keys).from(schema)

    if queryFlag then
      baseQuery = baseQuery.where(queryFields)
    end

    local sql, data = baseQuery.escape().build()

    MySQL.Async.fetchAll(sql, data, function(rows)
      if not(rows) then
        error("A MySQL error occured, this probably isn't on the ESX end.")
      end

      if (rows[1] == nil) then
        return cb(nil)
      end

      cb(table.map(rows, function(e)

        local row  = e
        local data = {}

        for k,v in pairs(fields) do
          data[k] = v.decode(row[v.data.name])
        end

        return pType(data)

      end))

    end)

  end

  pType.create = function(data, cb)
    local instance = pType(data)

    instance:save(function(id)
      cb(instance)
    end)
  end

  pType.ensure = function(query, data, cb)

    pType.findOne(query, function(instance)

      if instance == nil then

        pType.create(data, cb)

      else

        for k,v in pairs(data) do
          instance[k] = v
        end

        cb(instance)

      end

    end)

  end

  function pType:save(cb)

    local serialized = self:serialize()
    local keys       = ''
    local values     = ''
    local update     = ''

    local data   = {
      ['@pk'] = pk,
      ['@id'] = self:getPK(),
    }

    local count = 0

    if tostring(schema) == "identities" then
      for k,v in pairs(fields) do
        if tostring(k) == "position" or tostring(k) == "roles" or tostring(k) == "status" or tostring(k) == "accounts" then
          fields[k] = nil
        end
      end
    end

    for k,v in pairs(fields) do

      if serialized[k] ~= nil then

        local escaped    = '@' .. k
        local backticked = '`' .. v.data.name .. '`'

        if count > 0 then
          keys   = keys   .. ', '
          values = values .. ', '
          update = update .. ', '
        end

        keys          = keys   .. backticked
        values        = values .. escaped
        update        = update .. backticked .. '=' .. escaped
        data[escaped] = fields[k].encode(serialized[k])

        count = count + 1

      end

    end

    local sql = 'INSERT INTO `' .. schema .. '` (' .. keys .. ') VALUES (' .. values .. ') ON DUPLICATE KEY UPDATE ' .. update .. '; SELECT LAST_INSERT_ID();'

    MySQL.Async.fetchAll(sql, data, function(rows)

      local id = rows[2][1]['LAST_INSERT_ID()']

      if (id ~= nil) and (self:getPK() == nil) then
        self:setPK(id)
      end

      if cb ~= nil then
        cb(id)
      end

    end)

  end

  function pType:setPK(val)
    self[self.__PK] = val
  end

  function pType:getPK()
    return self[self.__PK]
  end

  on('esx:db:init', function(initTable, extendTable)
    initTable(schema, pk, dbfields)
  end)

  return Extends(pType, extDebugName), pType

end

