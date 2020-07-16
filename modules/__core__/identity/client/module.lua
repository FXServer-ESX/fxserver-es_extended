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
M('serializable')
M('cache')
M('ui.menu')

local HUD   = M('game.hud')
local utils = M("utils")

local spawn = {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}

Identity = Extends(Serializable, 'Identity')

Identity.parseRole = module.Identity_parseRoles
Identity.getRole   = module.Identity_getRole
Identity.hasRole   = module.Identity_hasRole

IdentityCacheConsumer = Extends(CacheConsumer, 'IdentityCacheConsumer')

function IdentityCacheConsumer:provide(key, cb)

  request('esx:cache:identity:get', function(exists, data)
    cb(exists, exists and Identity(data) or nil)
  end, key)

end

Cache.identity = IdentityCacheConsumer()

module.Menu          = nil
module.PreventSaving = false

module.OpenMenu = function(cb)

  utils.ui.showNotification(_U('identity_register'))

  module.Menu = Menu("identity", {
    float = "center|middle",
    title = "Create Character",
    items = {
      {name = "firstName", label = "First name",    type = "text", placeholder = "John"},
      {name = "lastName",  label = "Last name",     type = "text", placeholder = "Smith"},
      {name = "dob",       label = "Date of birth", type = "text", placeholder = "01/02/1234"},
      {name = "isMale",    label = "Male",          type = "check", value = true},
      {name = "submit",    label = "Submit",        type = "button"}
    }
  })

  module.Menu:on("item.change", function(item, prop, val, index)

    if (item.name == "isMale") and (prop == "value") then
      if val then
        item.label = "Male"
      else
        item.label = "Female"
      end
    end

  end)

  module.Menu:on("item.click", function(item, index)

    if item.name == "submit" then

      local props = module.Menu:kvp()

      if (props.firstName ~= '') and (props.lastName ~= '') and (props.dob ~= '') then

        module.Menu:destroy()
        module.Menu = nil

        request('esx:identity:register', cb, props)

        utils.ui.showNotification(_U('identity_welcome', props.firstName, props.lastName))
      else
        utils.ui.showNotification(_U('identity_fill_in'))
      end

    end

  end)

end

module.DoSpawn = function(data, cb)
  exports.spawnmanager:spawnPlayer(data, cb)
end

module.Init = function(id)
  if id == nil then
    error('Identity is not defined')
  end

  Cache.identity:resolve(id, function(exists, identity)
    if not exists then
      error('Identity not found')
    end

    ESX.Player:field('identity', identity)

    local playerPed = PlayerPedId()

    if Config.EnablePvP then
      SetCanAttackFriendly(playerPed, true, false)
      NetworkSetFriendlyFireOption(true)
    end

    if Config.EnableHUD then
      module.LoadHUD()
    end

    ESX.Ready = true

    
    emitServer('esx:client:ready')
    emit('esx:ready')

    Citizen.Wait(2000)

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
  end)
end

module.EnsureIdentity = function()

  local player     = ESX.Player
  local identityId = player:getIdentityId()

  local requestRegistration = function()
    module.DoSpawn({

      x        = spawn.x,
      y        = spawn.y,
      z        = spawn.z,
      heading  = spawn.heading,
      model    = 'mp_m_freemode_01',
      skipFade = false

    }, function()

      module.OpenMenu(module.Init)

    end)
  end

  if identityId == nil then

    requestRegistration()

  else

    Cache.identity:fetch(identityId, function(exists, identity)

      if exists then

        local position = identity:getPosition()

        request('esx:identity:getSavedPosition', function(savedPos)
          if savedPos then
            module.DoSpawn({

              x        = savedPos.x,
              y        = savedPos.y,
              z        = savedPos.z,
              heading  = savedPos.heading,
              model    = 'mp_m_freemode_01',
              skipFade = false

            }, function()
              module.Init(identityId)
            end)
          else
            module.DoSpawn({

              x        = position.x,
              y        = position.y,
              z        = position.z,
              heading  = position.heading,
              model    = 'mp_m_freemode_01',
              skipFade = false

            }, function()
              module.Init(identityId)
            end)
          end
        end, id)

      else

        requestRegistration()

      end

    end)

  end

end

module.LoadHUD = function()

  Citizen.CreateThread(function()

    while (not HUD.Frame) or (not HUD.Frame.loaded) do
      Citizen.Wait(0)
    end

    HUD.RegisterElement('display_name', 1, 0, '{{firstName}} {{lastName}}', ESX.Player.identity:serialize())

  end)

end

module.SavePosition = ESX.SetInterval(30000, function()
  if NetworkIsPlayerActive(PlayerId()) then
    if not module.PreventSaving then
      local playerCoords = GetEntityCoords(PlayerPedId())
      local heading      = GetEntityHeading(PlayerPedId())
      local position     = {
        x       = math.round(playerCoords.x, 1),
        y       = math.round(playerCoords.y, 1),
        z       = math.round(playerCoords.z, 1),
        heading = math.round(heading, 1)
      }

      emitServer('esx:identity:updatePosition', position)
    end
  end
end)
