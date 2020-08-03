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

fx_version      'adamant'
game            'gta5'
description     'ESX'
version         '2.0.1'
ui_page         'hud/index.html'
ui_page_preload 'yes'

dependencies {
  'yarn',
  'spawnmanager',
  'baseevents',
  'mysql-async',
  'async',
}

files {

  'data/**/*',
  'hud/**/*',

  'config/**/*.json',
  'modules/*/modules.json',
  'modules/*/*/data/**/*',
  'modules/*/*/shared/*.lua',
  'modules/*/*/client/*.lua',

}

server_scripts {

  'fxmanifest.workaround.js',
  '@async/async.lua',
  '@mysql-async/lib/MySQL.lua',

  'locale.lua',
  'locales/*.lua',

  'config/default/config.lua',
  'config/default/config.*.lua',
  'config/default/modules/core/*.lua',
  'config/default/modules/*.lua',

  'config/modules/core/*.lua',
  'config/modules/*.lua',

  'boot/shared/module.lua',
  'boot/server/module.lua',
  'boot/shared/events.lua',
  'boot/server/events.lua',
  'boot/shared/main.lua',
  'boot/server/main.lua',

}

client_scripts {

  'locale.lua',
  'locales/*.lua',

  'vendor/matrix.lua',

  'config/default/config.lua',
  'config/default/config.*.lua',

  'config/default/modules/core/*.lua',
  'config/default/modules/*.lua',

  'config/modules/core/*.lua',
  'config/modules/*.lua',

  'boot/shared/module.lua',
  'boot/client/module.lua',
  'boot/shared/events.lua',
  'boot/client/events.lua',
  'boot/shared/main.lua',
  'boot/client/main.lua',

}
