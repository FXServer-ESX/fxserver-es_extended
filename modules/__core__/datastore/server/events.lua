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

on('esx:db:init', function(initTable, extendTable)

  initTable('datastores', 'name', {
    {name = 'name',  type = 'VARCHAR',  length = 255, default = nil,    extra = 'NOT NULL'},
    {name = 'owner', type = 'VARCHAR',  length = 64,  default = 'NULL', extra = nil},
    {name = 'data',  type = 'LONGTEXT', length = nil, default = nil,    extra = nil},
  })

end)
