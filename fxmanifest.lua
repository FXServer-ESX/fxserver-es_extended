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

fx_version      'cerulean'
game            'gta5'
description     'ESX'
version         '2.0.1'
ui_page         'hud/index.html'
ui_page_preload 'yes'
loadscreen 'loadscreen/data/index.html'
loadscreen_manual_shutdown 'yes'

lua54 'yes'

dependencies {
  'yarn',
  'spawnmanager',
  'baseevents',
  'ghmattimysql',
}

files {

  'data/**/*',
  'hud/**/*',
  'loadscreen/**/*',
  'config/**/*.json',
  'modules/**/modules.json',
  'modules/**/data/**/*',
  'modules/**/shared/*.lua',
  'modules/**/client/*.lua',

}

server_scripts {

  'locale.lua',
  'locales/*.lua',

  'config/default/config.lua',
  'config/default/config.*.lua',

  'boot/shared/module.lua',
  'boot/server/module.lua',
  'boot/shared/events.lua',
  'boot/server/events.lua',
  'boot/shared/main.lua',
  'boot/server/main.lua'

}

client_scripts {

  'locale.lua',
  'locales/*.lua',

  'vendor/matrix.lua',

  'config/default/config.lua',
  'config/default/config.*.lua',

  'boot/shared/module.lua',
  'boot/client/module.lua',
  'boot/shared/events.lua',
  'boot/client/events.lua',
  'boot/shared/main.lua',
  'boot/client/main.lua'

}

shared_scripts {

}

