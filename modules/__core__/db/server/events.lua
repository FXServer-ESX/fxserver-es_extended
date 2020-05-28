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

MySQL.ready(
  function()
    Citizen.CreateThread(
      function()
        while not ESX.Loaded do
          Citizen.Wait(0)
        end

        emit("esx:db:internal:ready")
      end
    )
  end
)

-- Locals
local ADD_COLUMN_IN_NOT_EXISTS_PROCEDURE =
  [[
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

on(
  "esx:db:internal:ready",
  function()
    MySQL.Sync.execute(ADD_COLUMN_IN_NOT_EXISTS_PROCEDURE)

    -- Init minimum required schemas here
    self.InitTable(
      "migrations",
      "id",
      {
        {name = "id", type = "INT", length = 11, default = nil, extra = "NOT NULL AUTO_INCREMENT"},
        {name = "module", type = "VARCHAR", length = 64, default = nil, extra = nil},
        {name = "last", type = "INT", length = 11, default = nil, extra = nil}
      }
    )

    self.InitTable(
      "users",
      "identifier",
      {
        {name = "identifier", type = "VARCHAR", length = 40, default = nil, extra = "NOT NULL"},
        {name = "name", type = "LONGTEXT", length = nil, default = "NULL", extra = nil},
        {name = "accounts", type = "LONGTEXT", length = nil, default = "NULL", extra = nil},
        {name = "group", type = "VARCHAR", length = 64, default = "user", extra = nil},
        {name = "inventory", type = "LONGTEXT", length = nil, default = "NULL", extra = nil},
        {name = "job", type = "VARCHAR", length = 32, default = "unemployed", extra = nil},
        {name = "job_grade", type = "INT", length = nil, default = 0, extra = nil},
        {name = "loadout", type = "LONGTEXT", length = nil, default = "NULL", extra = nil},
        {
          name = "position",
          type = "VARCHAR",
          length = 255,
          default = '{"x":-269.4,"y":-955.3,"z":31.2,"heading":205.8}',
          extra = nil
        },
        {name = "is_dead", type = "INT", length = nil, default = 0, extra = nil}
      }
    )

    self.InitTable(
      "jobs",
      "name",
      {
        {name = "name", type = "VARCHAR", length = 64, default = nil, extra = "NOT NULL"},
        {name = "label", type = "VARCHAR", length = 64, default = "NULL", extra = nil}
      },
      {
        {name = "unemployed", label = "Unemployed"}
      }
    )

    self.InitTable(
      "job_grades",
      "id",
      {
        {name = "id", type = "INT", length = 11, default = nil, extra = "NOT NULL AUTO_INCREMENT"},
        {name = "job_name", type = "VARCHAR", length = 32, default = nil, extra = nil},
        {name = "grade", type = "INT", length = nil, default = nil, extra = "NOT NULL"},
        {name = "name", type = "VARCHAR", length = 64, default = nil, extra = "NOT NULL"},
        {name = "label", type = "VARCHAR", length = 64, default = nil, extra = "NOT NULL"},
        {name = "salary", type = "INT", length = nil, default = nil, extra = "NOT NULL"},
        {name = "skin_male", type = "LONGTEXT", length = nil, default = nil, extra = "NOT NULL"},
        {name = "skin_female", type = "LONGTEXT", length = nil, default = nil, extra = "NOT NULL"}
      },
      {
        {
          job_name = "unemployed",
          grade = 0,
          name = "unemployed",
          label = "Unemployed",
          salary = 200,
          skin_male = "{}",
          skin_female = "{}"
        }
      }
    )

    self.InitTable(
      "items",
      "name",
      {
        {name = "name", type = "VARCHAR", length = 64, default = nil, extra = "NOT NULL"},
        {name = "label", type = "VARCHAR", length = 64, default = nil, extra = "NOT NULL"},
        {name = "weight", type = "INT", length = nil, default = nil, extra = "NOT NULL"},
        {name = "rare", type = "INT", length = nil, default = nil, extra = "NOT NULL"},
        {name = "can_remove", type = "INT", length = nil, default = nil, extra = "NOT NULL"}
      }
    )

    -- Leave a chance to extend schemas here
    emit("esx:db:init", self.InitTable, self.ExtendTable)

    -- Print schemas, sorted by name
    local sorted = {}

    for k, v in pairs(self.Tables) do
      sorted[#sorted + 1] = v
    end

    print("ensuring generated schemas")

    table.sort(
      sorted,
      function(a, b)
        return a.name < b.name
      end
    )

    for i = 1, #sorted, 1 do
      local tbl = sorted[i]
      local fieldNames = tbl:fieldNames()
      local fieldNamesStr = ""

      for i = 1, #fieldNames, 1 do
        if i > 1 then
          fieldNamesStr = fieldNamesStr .. ", "
        end

        fieldNamesStr = fieldNamesStr .. fieldNames[i]
      end

      print("table ^5" .. tbl.name .. "^7 (" .. fieldNamesStr .. ")")
    end

    -- Ensure schemas in database
    for k, v in pairs(self.Tables) do
      v:ensure()
    end

    -- database ready for migrations
    emit("esx:db:ready")
  end
)
