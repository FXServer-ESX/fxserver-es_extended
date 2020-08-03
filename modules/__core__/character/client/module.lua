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

local utils    = M('utils')
local identity = M('identity')
local camera   = M("camera")
M("table")

-- /config/default/config.character.lua, is it the right place ?
local characterConfig = Config.Modules.character

module.registrationMenu = nil
module.characterSelectionMenu = nil
module.isInMenu = false

module.AreMenuInUse = function()
  return not(module.characterSelectionMenu.isDestroyed and module.characterSelectionMenu.isDestroyed)
end

module.OpenMenu = function(cb)

  utils.ui.showNotification(_U('identity_register'))

  module.registrationMenu = Menu("character_creation", {
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

  module.registrationMenu:on("item.change", function(item, prop, val, index)

    if (item.name == "isMale") and (prop == "value") then
      if val then
        item.label = "Male"
      else
        item.label = "Female"
      end
    end

  end)

  module.registrationMenu:on("item.click", function(item, index)

    if item.name == "submit" then

      local props = module.registrationMenu:kvp()

      if (props.firstName ~= '') and (props.lastName ~= '') and (props.dob ~= '') then

        module.registrationMenu:destroy()

        request('esx:character:creation', cb, props)

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

module.InitiateCharacterSelectionSpawn = function()
  local spawnCoords = characterConfig.spawnCoords

  module.DoSpawn({

    x        = spawnCoords.x,
    y        = spawnCoords.y,
    z        = spawnCoords.z,
    heading  = spawnCoords.heading,
    model    = 'mp_m_freemode_01',
    skipFade = false

  }, function()

    local playerPed = PlayerPedId()

  end)

  module.isInMenu = true

  Citizen.Wait(2000)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()
end

module.mainCameraScene = function()
  local ped       = GetPlayerPed(-1)
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  camera.setRadius(1.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))

  camera.pointToBone(SKEL_ROOT)
end

module.RequestIdentitySelection = function(identities)

  -- TP the player to a spawn point defined in the config file
  module.InitiateCharacterSelectionSpawn()

  -- Start a camera on the player (skin preview)
  camera.start()
  module.mainCameraScene()

  -- Fetch the loaded player
  local player = ESX.Player

  local menuElements = {}

  if identities then
    -- for each identities, insert a button to select it
    menuElements = table.map(identities, function(identity)
      return {type = 'button', name = identity:getId(), label = identity:getFirstName() .. " " .. identity:getLastName(), identity = identity:serialize()}
    end)
  end

  table.insert(menuElements, {name = "register", label = ">> Create a New Identity <<", type = "button", shouldDestroyMenu = true})

  module.characterSelectionMenu = Menu('character.select', {
      title = 'Choose An Identity',
      float = 'top|left',
      items = menuElements
  })

  module.characterSelectionMenu:on('item.click', function(item)

    if item.name == 'register' then
      -- delegate to the identity module, responsible of the registration
      emit("esx:identity:openRegistration")

      module.characterSelectionMenu:destroy()

      camera.stop()
      module.isInMenu = false
      camera.setMouseIn(false)
    elseif item.name == "none" then

    else
      request("esx:character:fetchSkin", function(skinContent)
        if skinContent then
            module.SelectCharacter(item.name, item.label, item.identity, skinContent)
        else
          module.SelectCharacter(item.name, item.label, item.identity)
        end
      end, item.name)
    end
  end)

end

module.SelectCharacter = function(name, label, identity, skinContent)

  if skinContent then
    module.LoadPreviewSkin(skinContent)
  end

  local items = {
    {name = "submit", label = "Start", type = "button"},
    {name = "back", label = "Go Back", type = "button"}
  }
  
  if module.characterSelectionMenu.visible then
    module.characterSelectionMenu:hide()
  end

  module.confirmMenu = Menu('character.confirm', {
    title = 'Start with ' .. label .. '?',
    float = 'top|left',
    items = items
  })

  module.confirmMenu:on('destroy', function()
    module.characterSelectionMenu:show()
  end)

  module.confirmMenu:on('item.click', function(item, index)
    if item.name == "submit" then
      module.SelectIdentity(identity)
      module.confirmMenu:destroy()
      module.characterSelectionMenu:destroy()
      camera.stop()
      module.isInMenu = false
    elseif item.name == "back" then
      module.DestroyCharacterModel()
      module.confirmMenu:destroy()
      module.characterSelectionMenu:focus()
    end
  end)
end

module.LoadPreviewSkin = function(skinContent)
  if skinContent["model"] == "mp_m_freemode_01" then

    local modelHash = GetHashKey(skinContent["model"])
    
    utils.game.requestModel(modelHash, function()
      SetPlayerModel(PlayerId(), modelHash)

      local ped                      = PlayerPedId()
      local blend                    = skinContent["blend"]
      local blendFaceMix             = skinContent["blendFaceMix"]
      local blendSkinMix             = skinContent["blendSkinMix"]
      local blendOverrideMix         = skinContent["blendOverrideMix"]
      local blemishes                = skinContent["blemishes"]
      local blemishesOpacity         = skinContent["blemishesOpacity"]
      local eyebrow                  = skinContent["eyebrow"]
      local opacity                  = skinContent["eyebrowOpacity"]
      local eyebrowColor1            = skinContent["eyebrowColor1"]
      local eyebrowColor2            = skinContent["eyebrowColor2"]
      local blush                    = skinContent["blush"]
      local blushOpacity             = skinContent["blushOpacity"]
      local blushColor1              = skinContent["blushColor1"]
      local blushColor2              = skinContent["blushColor2"]
      local complexion               = skinContent["complexion"]
      local complexionOpacity        = skinContent["complexionOpacity"]
      local freckles                 = skinContent["freckles"]
      local frecklesOpacity          = skinContent["frecklesOpacity"]
      local beard                    = skinContent["beard"]
      local beardOpacity             = skinContent["beardOpacity"]
      local beardColor1              = skinContent["beardColor1"]
      local beardColor2              = skinContent["beardColor2"]
      local makeup                   = skinContent["makeup"]
      local makeupOpacity            = skinContent["makeupOpacity"]
      local lipstick                 = skinContent["lipstick"]
      local lipstickOpacity          = skinContent["lipstickOpacity"]
      local lipstickColor            = skinContent["lipstickColor"]
      local aging                    = skinContent["aging"]
      local agingOpacity             = skinContent["agingOpacity"]
      local chestHair                = skinContent["chestHair"]
      local chestHairOpacity         = skinContent["chestHairOpacity"]
      local chestHairColor           = skinContent["chestHairColor"]
      local sunDamage                = skinContent["sunDamage"]
      local sunDamageOpacity         = skinContent["sunDamageOpacity"]
      local bodyBlemishes            = skinContent["bodyBlemishes"]
      local bodyBlemishesOpacity     = skinContent["bodyBlemishesOpacity"]
      local moreBodyBlemishes        = skinContent["moreBodyBlemishes"]
      local moreBodyBlemishesOpacity = skinContent["moreBodyBlemishesOpacity"]
      local hair                     = skinContent["hair"]
      local hairColor                = skinContent["hairColor"]

      SetPedHeadBlendData(ped, blend[1], blend[2], blend[3], blend[4], blend[5], blend[6], blendFaceMix, blendSkinMix, blendOverrideMix, true)

      while HasPedHeadBlendFinished(ped) do
        Citizen.Wait(0)
      end

      SetPedHeadOverlay(ped, 0, blemishes, blemishesOpacity)

      SetPedHeadOverlay(ped, 2, eyebrow, opacity)
      SetPedHeadOverlayColor(ped, 2, 1, eyebrowColor1, eyebrowColor2)

      SetPedHeadOverlay(ped, 1, beard, beardOpacity)
      SetPedHeadOverlayColor(ped, 1, 1, beardColor1, beardColor2)

      SetPedHeadOverlay(ped, 5, blush, blushOpacity)
      SetPedHeadOverlayColor(ped, 5, 2, blushColor1, blushColor2)

      SetPedHeadOverlay(ped, 6, complexion, complexionOpacity)

      SetPedHeadOverlay(ped, 9, freckles, frecklesOpacity)

      SetPedHeadOverlay(ped, 4, makeup, makeupOpacity)

      SetPedHeadOverlay(ped, 8, lipstick, lipstickOpacity)
      SetPedHeadOverlayColor(ped, 8, 2, lipstickColor, lipstickColor)

      SetPedHeadOverlay(ped, 10, chestHair, chestHairOpacity)
      SetPedHeadOverlayColor(ped, 10, 1, chestHairColor, chestHairColor)

      SetPedHeadOverlay(ped, 7, sunDamage, sunDamageOpacity)
      SetPedHeadOverlay(ped, 11, bodyBlemishes, bodyBlemishesOpacity)
      SetPedHeadOverlay(ped, 12, moreBodyBlemishes, moreBodyBlemishesOpacity)

      for componentId,component in pairs(skinContent["components"]) do
        SetPedComponentVariation(ped, componentId, component[1], component[2], 1)
      end

      SetPedComponentVariation(ped, 2, hair[1], hair[2], 1)
      SetPedHairColor(ped, hairColor[1], hairColor[2])

      camera.setRadius(1.25)
  
      camera.pointToBone(SKEL_Head, vector3(0.0,0.0,0.0))

      SetModelAsNoLongerNeeded(modelHash)
    end)

    SetEntityVisible(PlayerPedId(), true)
  else
    local modelHash = GetHashKey(skinContent["model"])
    
    utils.game.requestModel(modelHash, function()
      SetPlayerModel(PlayerId(), modelHash)

      camera.setRadius(1.25)
  
      camera.pointToBone(SKEL_Head, vector3(0.0,0.0,0.0))

      SetModelAsNoLongerNeeded(modelHash)
    end)

    SetEntityVisible(PlayerPedId(), true)
  end
end

module.DestroyCharacterModel = function()
  camera.pointToBone(SKEL_ROOT)

  SetEntityVisible(PlayerPedId(), false)
end

module.SelectIdentity = function(identity)
  emit("esx:identity:selectIdentity", Identity(identity))
  camera.setMouseIn(false)
end