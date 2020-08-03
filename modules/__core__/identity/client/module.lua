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
M('table')
M('ui.menu')
local HUD   = M('game.hud')
local utils = M('utils')

local spawn = {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}
module.SavePositionInterval = nil

Identity = Extends(Serializable, 'Identity')

Identity.parseRole = module.Identity_parseRoles
Identity.getRole   = module.Identity_getRole
Identity.hasRole   = module.Identity_hasRole

IdentityCacheConsumer = Extends(CacheConsumer, 'IdentityCacheConsumer')

function IdentityCacheConsumer:provide(key, cb)

  -- @TODO make a way to get the identities or identity based on id
  -- for now it return an Array by default, but it should be better
  -- to split this into 2 differents places to make it more clear.
  request('esx:cache:identity:get', function(exists, identities)
    local instancedIdentities = nil
    if exists then
      instancedIdentities = table.map(identities, function(identity)
        return Identity(identity)
      end)
    end
    cb(exists, exists and instancedIdentities or nil)
  end, key)

end

Cache.identity = IdentityCacheConsumer()

module.SelectIdentityAndSpawnCharacter = function(requestedIdentity)
  if requestedIdentity == nil then
    error('Expect identity to be defined')
  end

  request('esx:identity:selectIdentity', function(identity)
    module.initIdentity(identity)
  end, requestedIdentity:getId())
end

-- take a serialized identity, load it, fetch position server-side
-- spawn the character (ped) and start init routine
-- it's not a good idea to call it from outside as the function is.
-- @TODO: split this into tinier pieces so we can be modular
module.initIdentity = function(identity)
  local identity = Identity(identity)

  ESX.Player:field('identity', identity)
  local position = spawn

  request('esx:identity:getSavedPosition', function(savedPos)
    module.DoSpawn({

        x        = savedPos and savedPos.x or position.x,
        y        = savedPos and savedPos.y or position.y,
        z        = savedPos and savedPos.z or position.z,
        heading  = savedPos and savedPos.heading or position.heading,
        model    = 'mp_m_freemode_01',
        skipFade = false

      }, function()
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

        initPlayerDeadCheckInterval()

        Citizen.Wait(2000)

        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()

        module.SavePositionInterval = ESX.SetInterval(Config.Modules.identity.playerCoordsSaveInterval * 1000, module.SavePosition)
      end)

  end, identity:serialize())
end

module.LoadHUD = function()

  Citizen.CreateThread(function()

    while (not HUD.Frame) or (not HUD.Frame.loaded) do
      Citizen.Wait(0)
    end

    HUD.RegisterElement('display_name', 1, 0, '{{firstName}} {{lastName}}', ESX.Player.identity:serialize())

  end)

end

module.DoSpawn = function(data, cb)
  exports.spawnmanager:spawnPlayer(data, cb)
end

-- request a coords sync with the server.
-- @TODO: maybe move this code server-side if we can ensure \
-- server is running OneSync
module.SavePosition = function()
  if NetworkIsPlayerActive(PlayerId()) then
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

-- open the registration menu and save the created identity
-- then load it into the player
module.RequestRegistration = function(cb)

  utils.ui.showNotification(_U('identity_register'))

  ESX.Player:field('identity', identity)
  
  module.Menu = Menu("identity", {
    float = "center|middle",
    title = _U('identity_create'),
    items = {
      {name = "firstName", label =  _U('identity_firstname'),    type = "text", placeholder = "John"},
      {name = "lastName",  label =  _U('identity_lastname'),     type = "text", placeholder = "Smith"},
      {name = "dob",       label =  _U('identity_birthdate'),    type = "text", placeholder = "01/02/1234"},
      {name = "isMale",    label =  _U('identity_male'),         type = "check", value = true},
      {name = "submit",    label =  _U('submit'),                type = "button"}
    }
  })

  module.Menu:on("item.change", function(item, prop, val, index)

    if (item.name == "isMale") and (prop == "value") then
      if val then
        item.label = _U('identity_male')
      else
        item.label = _U('identity_female')
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
