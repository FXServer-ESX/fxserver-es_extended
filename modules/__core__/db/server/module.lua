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

self.Tables = {}

-- field
local DBField = Extends(nil)

function DBField:constructor(name, _type, length, default, extra)

  self.name    = name
  self.type    = _type
  self.length  = length
  self.default = default
  self.extra   = extra

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

      if self.default == 'NULL' then
        sql = sql .. 'NULL'
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

      if self.default == 'NULL' then
        sql = sql .. 'NULL'
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

      if self.default == 'NULL' then
        sql = sql .. 'NULL'
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

self.DBField = DBField

-- table
local DBTable = Extends(nil)

function DBTable:constructor(name, pk)

  self.engine   = 'InnoDB'

  self.defaults = {
    {'CHARSET', 'utf8mb4'}
  }

  self.fields = {}
  self.rows   = {}
  self.name   = name
  self.pk     = pk

end

function DBTable:field(name, _type, length, default, extra)
  self.fields[#self.fields + 1] = DBField:create(name, _type, length, default, extra)
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

          if fieldValue == 'NULL' then
            sql = sql .. 'NULL'
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

self.DBTable = DBTable

self.InitTable = function(name, pk, fields, rows)

  rows      = rows or {}
  local tbl = DBTable:create(name, pk)

  for i=1, #fields, 1 do
    local field = fields[i]
    tbl:field(field.name, field.type, field.length, field.default, field.extra)
  end

  for i=1, #rows, 1 do
    tbl:row(rows[i])
  end

  self.Tables[name] = tbl

end

self.ExtendTable = function(name, fields)

  local tbl           = self.Tables[name]
  local fieldNamesStr = ''

  for i=1, #fields, 1 do
    local field = fields[i]
    tbl:field(field.name, field.type, field.length, field.default, field.extra)
  end

end

self.GetFieldNames = function(tableName)
  return self.Tables[tableName]:fieldNames()
end
