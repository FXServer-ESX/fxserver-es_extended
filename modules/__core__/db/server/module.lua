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

module.Tables = {}

--expressions
module.Expressions = {'NULL', 'UUID()'}

module.IsExpression = function(val)
  return table.indexOf(module.Expressions, val) ~= -1
end

--query
local DBQuery = function()

  local self    = {}
  self.handlers = {}
  self.procs    = {}
  self.flags    = { escape = false }

  local handleValue = function(value, name)

    if self.flags.escape and (name ~= nil) then
      return '@' .. tostring(name)
    end

    if type(value) == 'string' then

      if value == 'NULL' then
        return 'NULL'
      elseif value == 'UUID()' then
        return 'UUID()'
      else
        return '\'' .. value .. '\''
      end

    else
      return tostring(value)
    end

  end

  local handleField = function(name)
    return '`' .. name .. '`'
  end

  self.handlers.select = function(proc)

    local sub = ''

    if type(proc.what) == 'table' then

      sub = ''

      for i=1, #proc.what, 1 do

        local what = handleField(proc.what[i])

        if i > 1 then
          sub = sub .. ', '
        end

        sub = sub .. what

      end

      sub = sub

    else
      sub = proc.what
    end

    return 'SELECT ' .. sub

  end

  self.handlers.from = function(proc)
    return 'FROM ' .. handleField(proc.schema)
  end

  self.handlers.where = function(proc, data)

    local sub = ''

    if proc.mode == 'raw' then

      sub = sub .. proc.raw

    elseif proc.mode == 'kvp' then

      local first = true

      for k,v in pairs(proc.data) do

        local name

        if data ~= nil then
          name           = k
          data['@' .. k] = v
        end

        if first then
          first = false
        else
          sub = sub .. ' AND '
        end

        sub = sub .. handleField(k) .. ' = ' .. handleValue(v, name)

      end

    elseif proc.mode == 'equals' then

      sub = sub .. handleField(proc.field) .. ' = ' .. handleValue(proc.value, name)

    end

    return 'WHERE ' .. sub

  end

  self.handlers.insert = function(proc)

    local fields = '('
    local values = '('
    local first  = true


    for k,v in pairs(proc.data) do

      if first then
        first = false
      else
        fields = fields .. ', '
        values = values .. ', '
      end

      fields = fields .. handleField(k)
      values = values .. handleValue(v)

    end

    fields = fields .. ')'
    values = values .. ')'

    return 'INSERT INTO ' .. handleField(proc.schema) .. ' ' .. fields .. ' VALUES ' .. values

  end

  self.handlers.limit = function(count1, count2)

    if count2 == nil then
      return 'LIMIT ' .. count1
    else
      return 'LIMIT ' .. count1 .. ',' .. count2
    end

  end

  self.build = function()

    local data = self.flags.escape and {} or nil
    local sql  = ''

    for i=1, #self.procs, 1 do

      local proc = self.procs[i]

      if i > 1 then
        sql = sql .. ' '
      end

      sql = sql .. self.handlers[proc.type](proc, data)

    end

    sql = sql .. ';'

    return sql, data

  end

  self.escape = function(enabled)

    if enabled == nil then
      enabled = true
    end

    self.flags.escape = enabled

    return self

  end

  self.select = function(what)
    self.procs[#self.procs + 1] = {type = 'select', what = what}
    return self
  end

  self.from = function(schema)
    self.procs[#self.procs + 1] = {type = 'from', schema = schema}
    return self
  end

  self.where = function(what)

    if type(what) == 'string' then
      self.procs[#self.procs + 1] = {type = 'where', mode = 'raw', raw = raw}
      return self
    elseif type(what) == 'table' then
      self.procs[#self.procs + 1] = {type = 'where', mode = 'kvp', data = what}
      return self
    end

    local whereSelf = {}

    whereSelf.equals = function(field, value)
      self.procs[#self.procs + 1] = {type = 'where', mode = 'equals', field = field, value = value}
      return self
    end

    return whereSelf

  end

  self.insertInto = function(schema, data)
    self.procs[#self.procs + 1] = {type = 'insert', schema = schema, data = data}
    return self
  end

  self.limit = function(count)
    self.procs[#self.procs + 1] = {type = 'limit', count = count}
  end

  return self

end

module.DBQuery = DBQuery

--[[
local q1     = DBQuery().select({'field1', 'field2'}).from('thetable').where().equals('test', 'value').build())
local q2     = DBQuery().insertInto('thetable', {foo = 'bar', baz = 123}).build())
local q3     = DBQuery().select({'field1', 'field2'}).from('thetable').where({foo = 'bar'}).build()
local q4, d4 = DBQuery().select({'field1', 'field2'}).from('thetable').where({foo = 'bar', baz = 123}).escape().build()
]]--

-- field
local DBField = Extends(nil, 'DBField')

function DBField:constructor(name, _type, length, default, extra)

  self.name = name
  self.type = _type
  self.length = length
  self.default = default
  self.extra = extra

end

function DBField:sqlCompat()

  local sql = '`' .. self.name .. '` ';
  sql = sql .. self.type

  if self.length == nil then
    sql = sql .. ' '
  else
    sql = sql .. '(' .. self.length .. ') '
  end

  if self.default ~= nil then

    sql = sql .. 'DEFAULT '

    if type(self.default) == 'string' then

      if module.IsExpression(self.default) then
        sql = sql .. self.default
      else
        sql = sql .. '\'' .. self.default .. '\''
      end

    else
      sql = sql .. self.default
    end

  end

  if self.extra ~= nil then
    sql = sql .. ' ' .. self.extra
  end

  return sql

end

function DBField:sql()

  local sql = '`' .. self.name .. '` '
  sql = sql .. self.type

  if self.length == nil then
    sql = sql .. ' '
  else
    sql = sql .. '(' .. self.length .. ') '
  end

  if self.default ~= nil then

    sql = sql .. 'DEFAULT '

    if type(self.default) == 'string' then

      if module.IsExpression(self.default) then
        sql = sql .. self.default
      else
        sql = sql .. '\'' .. self.default .. '\''
      end

    else
      sql = sql .. self.default
    end

  end

  if self.extra ~= nil then
    sql = sql .. ' ' .. self.extra
  end

  return sql

end

function DBField:sqlAlterCompat(tableName)

  local sql = 'call ADD_COLUMN_IF_NOT_EXISTS(DATABASE(), \'' .. tableName .. '\', \'' .. self.name .. '\', \''
  sql = sql .. self.type

  if self.length == nil then
    sql = sql .. ' '
  else
    sql = sql .. '(' .. self.length .. ') '
  end

  if self.default ~= nil then

    sql = sql .. 'DEFAULT '

    if type(self.default) == 'string' then

      if module.IsExpression(self.default) then
        sql = sql .. self.default
      else
        sql = sql .. '\\\'' .. self.default .. '\\\''
      end

    else
      sql = sql .. self.default
    end

  end

  if self.extra ~= nil then
    sql = sql .. ' ' .. self.extra
  end

  sql = sql .. '\')'

  return sql

end

module.DBField = DBField

-- table
local DBTable = Extends(nil, 'DBTable')

function DBTable:constructor(name, pk)

  self.engine = 'InnoDB'

  self.defaults = {
    {'CHARSET', 'utf8mb4'}
  }

  self.fields = {}
  self.rows = {}
  self.name = name
  self.pk = pk

end

function DBTable:field(name, _type, length, default, extra)
  self.fields[#self.fields + 1] = DBField(name, _type, length, default, extra)
end

function DBTable:row(data)
  self.rows[#self.rows + 1] = data
end

function DBTable:fieldNames()

  local names = {}

  for i=1, #self.fields, 1 do
    names[#names + 1] = self.fields[i].name
  end

  return names

end

function DBTable:sql()

  local sql = 'CREATE TABLE IF NOT EXISTS `' .. self.name .. '` (\n'

  for i=1, #self.fields, 1 do

    local field = self.fields[i]

    if i > 1 then
      sql = sql .. ',\n'
    end

    sql = sql .. '  ' .. field:sql()

  end

  if self.pk then
    sql = sql .. ',\n  PRIMARY KEY(`' .. self.pk .. '`)'
  end

  sql = sql .. '\n) ENGINE=' .. self.engine

  if self.defaults then

    sql = sql .. ' DEFAULT '

    for i=1, #self.defaults, 1 do
      sql = sql .. self.defaults[i][1] .. '=' .. self.defaults[i][2]
    end

  end

  sql = sql .. ';\n\n'

  for i=1, #self.fields, 1 do
    local field = self.fields[i]
    sql = sql .. field:sqlAlterCompat(self.name) .. ';\n'
  end

  return sql

end

function DBTable:ensure()
  local exists = not not MySQL.Sync.fetchAll('SHOW TABLES LIKE \'' .. self.name .. '\'')[1]

  local sql = self:sql()

  MySQL.Sync.execute(sql)

  if not exists and (#self.rows > 0) then

    local sql = ''

    for i=1, #self.rows, 1 do

      local row        = self.rows[i]
      sql              = sql .. 'INSERT INTO `' .. self.name .. '` ('
      local fieldNames = {}

      for k,v in pairs(row) do
        fieldNames[#fieldNames + 1] = k
      end

      for j=1, #fieldNames, 1 do

        local fieldName = fieldNames[j]

        if j > 1 then
          sql = sql .. ', '
        end

        sql = sql .. '`' .. fieldName .. '`'

      end

      sql = sql .. ') VALUES ('

      for j=1, #fieldNames, 1 do

        local fieldValue = row[fieldNames[j]]

        if j > 1 then
          sql = sql .. ', '
        end

        if type(fieldValue) == 'string' then

          if module.IsExpression(fieldValue) then
            sql = sql .. fieldValue
          else
            sql = sql .. '\'' .. fieldValue .. '\''
          end

        else
          sql = sql .. fieldValue
        end

      end

      sql = sql .. '); '

    end

    MySQL.Sync.execute(sql)

  end

end

module.DBTable = DBTable

module.InitTable = function(name, pk, fields, rows)

  rows      = rows or {}
  local tbl = DBTable(name, pk)

  for i=1, #fields, 1 do
    local field = fields[i]
    tbl:field(field.name, field.type, field.length, field.default, field.extra)
  end

  for i=1, #rows, 1 do
    tbl:row(rows[i])
  end

  module.Tables[name] = tbl

  emit('esx:db:init:' .. name, function(data)
    self.ExtendTable(name, data)
  end)

end

module.ExtendTable = function(name, fields)

  local tbl           = module.Tables[name]
  local fieldNamesStr = ''

  for i=1, #fields, 1 do
    local field = fields[i]
    tbl:field(field.name, field.type, field.length, field.default, field.extra)
  end

end

module.GetFieldNames = function(tableName)
  return module.Tables[tableName]:fieldNames()
end
