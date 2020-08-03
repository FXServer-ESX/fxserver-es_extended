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

MySQL.ready(function()

  Citizen.CreateThread(function()

    while not ESX.Loaded do
      Citizen.Wait(0)
    end

    emit('esx:db:internal:ready')

  end)

end)

-- Locals
local ADD_COLUMN_IN_NOT_EXISTS_PROCEDURE = [[
-- Copyright (c) 2009 www.cryer.co.uk
-- Script is free to use provided this copyright header is included.

DROP PROCEDURE IF EXISTS ADD_COLUMN_IF_NOT_EXISTS;

CREATE PROCEDURE ADD_COLUMN_IF_NOT_EXISTS(
  IN dbName    tinytext,
  IN tableName tinytext,
  IN fieldName tinytext,
  IN fieldDef  text
)

BEGIN
  IF NOT EXISTS (
    SELECT * FROM information_schema.COLUMNS
    WHERE `column_name`  = fieldName
    AND   `table_name`   = tableName
    AND   `table_schema` = dbName
  )
  THEN
    SET @ddl=CONCAT('ALTER TABLE ', dbName, '.', tableName, ' ADD COLUMN ', fieldName, ' ', fieldDef);
    PREPARE stmt from @ddl;
    EXECUTE stmt;
  END IF;
END;
]]

on('esx:db:internal:ready', function()

  MySQL.Sync.execute(ADD_COLUMN_IN_NOT_EXISTS_PROCEDURE)

  -- Init minimum required schemas here
  module.InitTable('migrations', 'id', {
    {name = 'id',     type = 'INT',     length = nil, default = nil, extra = 'NOT NULL AUTO_INCREMENT'},
    {name = 'module', type = 'VARCHAR', length = 64,  default = nil, extra = nil},
    {name = 'last',   type = 'INT',     length = 11,  default = nil, extra = nil},
  })

  -- Leave a chance to extend schemas here
  emit('esx:db:init', module.InitTable, module.ExtendTable)

  -- Print schemas, sorted by name
  local sorted = {}

  for k,v in pairs(module.Tables) do
    sorted[#sorted + 1] = v
  end

  print('ensuring generated schemas')

  table.sort(sorted, function(a, b) return a.name < b.name end)

  for i=1, #sorted, 1 do

    local tbl           = sorted[i]
    local fieldNames    = tbl:fieldNames()
    local fieldNamesStr = ''

    for i=1, #fieldNames, 1 do

      if i > 1 then
        fieldNamesStr = fieldNamesStr .. ', '
      end

      fieldNamesStr = fieldNamesStr .. fieldNames[i]

    end

    print('table ^5' .. tbl.name .. '^7 (' .. fieldNamesStr .. ')')

  end

  -- Ensure schemas in database
  for k,v in pairs(module.Tables) do
    v:ensure()
  end

  -- database ready for migrations
  emit('esx:db:init:done')

end)
