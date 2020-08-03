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

local utils = M('utils')
local camera = M("camera")

module.Config     = run('data/config.lua', {vector3 = vector3})['Config']
module.Editor     = Extends(EventEmitter, 'SkinEditor')
module.Skin       = Extends(EventEmitter, 'Skin')

on('ui.menu.mouseChange', function(value)
	if module.openedMenu then
		camera.setMouseIn(value)
	end
end)

module.openedMenu = false

local SkinEditor = module.Editor
local Skin = module.Skin

local getComponentIdentifierFromNumber = function(num)
  if (num == nil) then
    error("nil value passed to getComponentIdentifierFromNumber")
  end
  return Config.componentsConfig[num].id
end

local getComponentNumberFromIdentifier = function(id)
  for k,v in pairs(Config.componentsConfig) do
    if (v.id == id) then
      return k
    end
  end
  return nil
end

function Skin:constructor(config)
  self.super:ctor()

  self.model                    = config and config.model or "mp_m_freemode_01"
  self.components               = config and config.components or self:getDefaultComponents()

  self.blend                    = config and config.blend or self:getDefaultBlend()
  self.blendFaceMix             = config and config.blendFaceMix or self:getDefaultBlendFaceMix()
  self.blendSkinMix             = config and config.blendSkinMix or self:getDefaultBlendSkinMix()

  self.blendOverrideMix         = config and config.blendOverrideMix or self:getDefaultBlendOverrideMix()
  self.eyeState                 = config and config.eyeState or self:getDefaultEyeState()
  self.eyeColor                 = config and config.eyeColor or self:getDefaultEyeColor()
  self.eyebrow                  = config and config.eyebrow or self:getDefaultEyebrow()
  self.eyebrowOpacity           = config and config.eyebrowOpacity or self:getDefaultEyebrowOpacity()
  self.eyebrowColor1            = config and config.eyebrowColor1 or self:getDefaultEyebrowColor1()
  self.eyebrowColor2            = config and config.eyebrowColor2 or self:getDefaultEyebrowColor2()
  self.eyebrowDepth             = config and config.eyebrowDepth or self:getDefaultEyebrowDepth()
  self.eyebrowHeight            = config and config.eyebrowHeight or self:getDefaultEyebrowHeight()

  self.noseWidth                = config and config.noseWidth or self:getDefaultNoseWidth()
  self.noseHeight               = config and config.noseHeight or self:getDefaultNoseHeight()
  self.noseLength               = config and config.noseLength or self:getDefaultNoseLength()
  self.noseBridgeShift          = config and config.noseBridgeShift or self:getDefaultNoseBridgeShift()
  self.noseTip                  = config and config.noseTip or self:getDefaultNoseTip()
  self.noseShift                = config and config.noseShift or self:getDefaultNoseShift()

  self.chinLength               = config and config.chinLength or self:getDefaultChinLength()
  self.chinPosition             = config and config.chinPosition or self:getDefaultChinPosition()
  self.chinWidth                = config and config.chinWidth or self:getDefaultChinWidth()
  self.chinHeight               = config and config.chinHeight or self:getDefaultChinHeight()
  self.jawWidth                 = config and config.jawWidth  or self:getDefaultJawWidth()
  self.jawHeight                = config and config.jawHeight or self:getDefaultJawHeight()

  self.cheekboneHeight          = config and config.cheekboneHeight or self:getDefaultCheekboneHeight()
  self.cheekboneWidth           = config and config.cheekboneWidth or self:getDefaultCheekboneWidth()
  self.cheeksWidth              = config and config.cheeksWidth or self:getDefaultCheeksWidth()

  self.lipsWidth                = config and config.lipsWidth or self:getDefaultLipsWidth()

  self.neckThickness            = config and config.neckThickness or self:getDefaultNeckThickness()

  self.blemishes                = config and config.blemishes or self:getDefaultBlemishes()
  self.blemishesOpacity         = config and config.blemishesOpacity or self:getDefaultBlemishesOpacity()
  self.freckles                 = config and config.freckles or self:getDefaultFreckles()
  self.frecklesOpacity          = config and config.frecklesOpacity or self:getDefaultFrecklesOpacity()
  self.complexion               = config and config.complexion or self:getDefaultComplexion()
  self.complexionOpacity        = config and config.complexionOpacity or self:getDefaultComplexionOpacity()
  self.blush                    = config and config.blush or self:getDefaultBlush()
  self.blushOpacity             = config and config.blushOpacity or self:getDefaultBlushOpacity()
  self.blushColor1              = config and config.blushColor1 or self:getDefaultBlushColor1()
  self.blushColor2              = config and config.blushColor2 or self:getDefaultBlushColor2()

  self.hair                     = config and config.hair or self:getDefaultHair()
  self.hairColor                = config and config.hairColor or self:getDefaultHairColor()

  self.beard                    = config and config.beard or self:getDefaultBeard()
  self.beardOpacity             = config and config.beardOpacity or self:getDefaultBeardOpacity()
  self.beardColor1              = config and config.beardColor1 or self:getDefaultBeardColor1()
  self.beardColor2              = config and config.beardColor2 or self:getDefaultBeardColor2()

  self.makeup                   = config and config.makeup or self:getDefaultMakeup()
  self.makeupOpacity            = config and config.makeupOpacity or self:getDefaultMakeupOpacity()
  self.lipstick                 = config and config.lipstick or self:getDefaultLipstick()
  self.lipstickOpacity          = config and config.lipstickOpacity or self:getDefaultLipstickOpacity()
  self.lipstickColor            = config and config.lipstickColor or self:getDefaultLipstickColor()

  self.aging                    = config and config.aging or self:getDefaultAging()
  self.agingOpacity             = config and config.agingOpacity or self:getDefaultAgingOpacity()

  self.chestHair                = config and config.chestHair or self:getDefaultChestHair()
  self.chestHairOpacity         = config and config.chestHairOpacity or self:getDefaultChestHairOpacity()
  self.chestHairColor           = config and config.chestHairColor or self:getDefaultChestHairColor()

  self.sunDamage                = config and config.sunDamage or self:getDefaultSunDamage()
  self.sunDamageOpacity         = config and config.sunDamageOpacity or self:getDefaultSunDamageOpacity()
  self.bodyBlemishes            = config and config.bodyBlemishes or self:getDefaultBodyBlemishes()
  self.bodyBlemishesOpacity     = config and config.bodyBlemishesOpacity or self:getDefaultBodyBlemishesOpacity()
  self.moreBodyBlemishes        = config and config.moreBodyBlemishes or self:getDefaultMoreBodyBlemishes()
  self.moreBodyBlemishesOpacity = config and config.moreBodyBlemishesOpacity or self:getDefaultMoreBodyBlemishesOpacity()

  self.transactionalChanges = {
    components = {}
  }
end

function Skin:getDefaultComponents()
  local _components = {}
  for k,v in pairs(Config.componentsConfig) do
    _components[k] = v.default or {0, 0}
  end

  return _components
end

function Skin:getDefaultBlend()
  return Config.defaultBlend
end

function Skin:getDefaultBlendFaceMix()
  return Config.defaultBlendFaceMix
end

function Skin:getDefaultBlendSkinMix()
  return Config.defaultBlendSkinMix
end

function Skin:getDefaultBlendOverrideMix()
  return Config.defaultBlendOverrideMix
end

function Skin:getDefaultEyeState()
  return Config.defaultEyeState
end

function Skin:getDefaultEyeColor()
  return Config.defaultEyeColor
end

function Skin:getDefaultEyebrow()
  return Config.defaultEyebrow
end

function Skin:getDefaultEyebrowOpacity()
  return Config.defaultEyebrowOpacity
end

function Skin:getDefaultEyebrowColor1()
  return Config.defaultEyebrowColor1
end

function Skin:getDefaultEyebrowColor2()
  return Config.defaultEyebrowColor2
end

function Skin:getDefaultEyebrowDepth()
  return Config.defaultEyebrowDepth
end

function Skin:getDefaultEyebrowHeight()
  return Config.defaultEyebrowHeight
end

function Skin:getDefaultNoseWidth()
  return Config.defaultNoseWidth
end

function Skin:getDefaultNoseHeight()
  return Config.defaultNoseHeight
end

function Skin:getDefaultNoseLength()
  return Config.defaultNoseLength
end

function Skin:getDefaultNoseBridgeShift()
  return Config.defaultNoseBridgeShift
end

function Skin:getDefaultNoseTip()
  return Config.defaultNoseTip
end

function Skin:getDefaultNoseShift()
  return Config.defaultNoseShift
end

function Skin:getDefaultChinLength()
  return Config.defaultChinLength
end

function Skin:getDefaultChinPosition()
  return Config.defaultChinPosition
end

function Skin:getDefaultChinWidth()
  return Config.defaultChinWidth
end

function Skin:getDefaultChinHeight()
  return Config.defaultChinHeight
end

function Skin:getDefaultJawWidth()
  return Config.defaultJawWidth
end

function Skin:getDefaultJawHeight()
  return Config.defaultJawHeight
end

function Skin:getDefaultCheekboneHeight()
  return Config.defaultCheekboneHeight
end

function Skin:getDefaultCheekboneWidth()
  return Config.defaultCheekboneWidth
end

function Skin:getDefaultCheeksWidth()
  return Config.defaultCheeksWidth
end

function Skin:getDefaultLipsWidth()
  return Config.defaultLipsWidth
end

function Skin:getDefaultNeckThickness()
  return Config.defaultNeckThickness
end

function Skin:getDefaultBlemishes()
  return Config.defaultBlemishes
end

function Skin:getDefaultBlemishesOpacity()
  return Config.defaultBlemishesOpacity
end

function Skin:getDefaultFreckles()
  return Config.defaultFreckles
end

function Skin:getDefaultFrecklesOpacity()
  return Config.defaultFrecklesOpacity
end

function Skin:getDefaultComplexion()
  return Config.defaultComplexion
end

function Skin:getDefaultComplexionOpacity()
  return Config.defaultComplexionOpacity
end

function Skin:getDefaultBlush()
  return Config.defaultBlush
end

function Skin:getDefaultBlushOpacity()
  return Config.defaultBlushOpacity
end

function Skin:getDefaultBlushColor1()
  return Config.defaultBlushColor1
end

function Skin:getDefaultBlushColor2()
  return Config.defaultBlushColor2
end

function Skin:getDefaultHair()
  return Config.defaultHair
end

function Skin:getDefaultHairColor()
  return Config.defaultHairColor
end

function Skin:getDefaultBeard()
  return Config.defaultBeard
end

function Skin:getDefaultBeardOpacity()
  return Config.defaultBeardOpacity
end

function Skin:getDefaultBeardColor1()
  return Config.defaultBeardColor1
end

function Skin:getDefaultBeardColor2()
  return Config.defaultBeardColor2
end

function Skin:getDefaultMakeup()
  return Config.defaultMakeup
end

function Skin:getDefaultMakeupOpacity()
  return Config.defaultMakeupOpacity
end

function Skin:getDefaultLipstick()
  return Config.defaultLipstick
end

function Skin:getDefaultLipstickOpacity()
  return Config.defaultLipstickOpacity
end

function Skin:getDefaultLipstickColor()
  return Config.defaultLipstickColor
end

function Skin:getDefaultAging()
  return Config.defaultAging
end

function Skin:getDefaultAgingOpacity()
  return Config.defaultAgingOpacity
end

function Skin:getDefaultChestHair()
  return Config.defaultChestHair
end

function Skin:getDefaultChestHairOpacity()
  return Config.defaultChestHairOpacity
end

function Skin:getDefaultChestHairColor()
  return Config.defaultChestHairColor
end

function Skin:getDefaultSunDamage()
  return Config.defaultSunDamage
end

function Skin:getDefaultSunDamageOpacity()
  return Config.defaultSunDamageOpacity
end

function Skin:getDefaultBodyBlemishes()
  return Config.defaultBodyBlemishes
end

function Skin:getDefaultBodyBlemishesOpacity()
  return Config.defaultBodyBlemishesOpacity
end

function Skin:getDefaultMoreBodyBlemishes()
  return Config.defaultMoreBodyBlemishes
end

function Skin:getDefaultMoreBodyBlemishesOpacity()
  return Config.defaultMoreBodyBlemishesOpacity
end

function Skin:getComponent(idOrName)
  return self.components[self:getComponentId(idOrName)]
end

function Skin:getComponentId(idOrName)
  if (type(idOrName) == "number") then
    return idOrName
  else
    return getComponentNumberFromIdentifier(idOrName)
  end
end

function Skin:getBlend()
  return self.blend
end

function Skin:getBlendFaceMix()
  return self.blendFaceMix
end

function Skin:getBlendSkinMix()
  return self.blendSkinMix
end

function Skin:getBlendOverrideMix()
  return self.blendOverrideMix
end

function Skin:getEyeState()
  return self.eyeState
end

function Skin:getEyeColor()
  return self.eyeColor
end

function Skin:getEyebrow()
  return self.eyebrow
end

function Skin:getEyebrowOpacity()
  return self.eyebrowOpacity
end

function Skin:getEyebrowColor1()
  return self.eyebrowColor1
end

function Skin:getEyebrowColor2()
  return self.eyebrowColor2
end

function Skin:getEyebrowDepth()
  return self.eyebrowDepth
end

function Skin:getEyebrowHeight()
  return self.eyebrowHeight
end

function Skin:getNoseWidth()
  return self.noseWidth
end

function Skin:getNoseHeight()
  return self.noseHeight
end

function Skin:getNoseLength()
  return self.noseLength
end

function Skin:getNoseBridgeShift()
  return self.noseBridgeShift
end

function Skin:getNoseTip()
  return self.noseTip
end

function Skin:getNoseShift()
  return self.noseShift
end

function Skin:getChinLength()
  return self.chinLength
end

function Skin:getChinPosition()
  return self.chinPosition
end

function Skin:getChinWidth()
  return self.chinWidth
end

function Skin:getChinHeight()
  return self.chinHeight
end

function Skin:getJawWidth()
  return self.jawWidth
end

function Skin:getJawHeight()
  return self.jawHeight
end

function Skin:getCheekboneHeight()
  return self.cheekboneHeight
end

function Skin:getCheekboneWidth()
  return self.cheekboneWidth
end

function Skin:getCheeksWidth()
  return self.cheeksWidth
end

function Skin:getLipsWidth()
  return self.lipsWidth
end

function Skin:getNeckThickness()
  return self.neckThickness
end

function Skin:getBlemishes()
  return self.blemishes
end

function Skin:getBlemishesOpacity()
  return self.blemishesOpacity
end

function Skin:getFreckles()
  return self.freckles
end

function Skin:getFrecklesOpacity()
  return self.frecklesOpacity
end

function Skin:getComplexion()
  return self.complexion
end

function Skin:getComplexionOpacity()
  return self.complexionOpacity
end

function Skin:getBlush()
  return self.blush
end

function Skin:getBlushOpacity()
  return self.blushOpacity
end

function Skin:getBlushColor1()
  return self.blushColor1
end

function Skin:getBlushColor2()
  return self.blushColor2
end

function Skin:getHair()
  return self.hair
end

function Skin:getHairColor()
  return self.hairColor
end

function Skin:getBeard()
  return self.beard
end

function Skin:getBeardOpacity()
  return self.beardOpacity
end

function Skin:getBeardColor1()
  return self.beardColor1
end

function Skin:getBeardColor2()
  return self.beardColor2
end

function Skin:getMakeup()
  return self.makeup
end

function Skin:getMakeupOpacity()
  return self.makeupOpacity
end

function Skin:getLipstick()
  return self.lipstick
end

function Skin:getLipstickOpacity()
  return self.lipstickOpacity
end

function Skin:getLipstickColor()
  return self.lipstickColor
end

function Skin:getAging()
  return self.aging
end

function Skin:getAgingOpacity()
  return self.agingOpacity
end

function Skin:getChestHair()
  return self.chestHair
end

function Skin:getChestHairOpacity()
  return self.chestHairOpacity
end

function Skin:getChestHairColor()
  return self.chestHairColor
end

function Skin:getSunDamage()
  return self.sunDamage
end

function Skin:getSunDamageOpacity()
  return self.sunDamageOpacity
end

function Skin:getBodyBlemishes()
  return self.bodyBlemishes
end

function Skin:getBodyBlemishesOpacity()
  return self.bodyBlemishesOpacity
end

function Skin:getMoreBodyBlemishes()
  return self.moreBodyBlemishes
end

function Skin:getMoreBodyBlemishesOpacity()
  return self.moreBodyBlemishesOpacity
end

function Skin:getModel()
  return self.model
end

function Skin:setComponentDrawable(componentIdOrName, drawableId)
  local component = self:getComponent(componentIdOrName)
  component[1] = drawableId

  self.transactionalChanges.components[self:getComponentId(componentIdOrName)] = component

  return self
end

function Skin:setComponentTexture(componentIdOrName, textureId)
  local component = self:getComponent(componentIdOrName)
  component[2] = textureId

  self.transactionalChanges.components[self:getComponentId(componentIdOrName)] = component

  return self
end

function Skin:setFaceFather(val)
  self.blend[1] = val

  self.transactionalChanges.blend = self.blend

  return self
end

function Skin:setFaceMother(val)
  self.blend[2] = val

  self.transactionalChanges.blend = self.blend

  return self
end

function Skin:setFaceOverride(val)
  self.blend[3] = val

  self.transactionalChanges.blend = self.blend

  return self
end

function Skin:setSkinToneFather(val)
  self.blend[4] = val

  self.transactionalChanges.blend = self.blend

  return self
end

function Skin:setSkinToneMother(val)
  self.blend[5] = val

  self.transactionalChanges.blend = self.blend

  return self
end

function Skin:setSkinToneOverride(val)
  self.blend[6] = val

  self.transactionalChanges.blend = self.blend

  return self
end

function Skin:setFaceMix(val)
  self.blendFaceMix = val / 100

  self.transactionalChanges.blendFaceMix = self.blendFaceMix
  
  return self
end

function Skin:setSkinMix(val)
  self.blendSkinMix = val / 100

  self.transactionalChanges.blendSkinMix = self.blendSkinMix
  
  return self
end

function Skin:setOverrideMix(val)
  self.blendOverrideMix = val / 100

  self.transactionalChanges.blendOverrideMix = self.blendOverrideMix

  return self
end

function Skin:setEyeState(val)
  self.eyeState = (val - 100) / 100

  self.transactionalChanges.eyeState = self.eyeState

  return self
end

function Skin:setEyeColor(val)
  self.eyeColor = val

  self.transactionalChanges.eyeColor = self.eyeColor

  return self
end

function Skin:setEyebrow(val)
  self.eyebrow = val

  self.transactionalChanges.eyebrow = self.eyebrow

  return self
end

function Skin:setEyebrowOpacity(val)
  self.eyebrowOpacity = val / 100

  self.transactionalChanges.eyebrowOpacity = self.eyebrowOpacity

  return self
end

function Skin:setEyebrowColor1(val)
  self.eyebrowColor1 = val

  self.transactionalChanges.eyebrowColor1 = self.eyebrowColor1

  return self
end

function Skin:setEyebrowColor2(val)
  self.eyebrowColor2 = val

  self.transactionalChanges.eyebrowColor2 = self.eyebrowColor2

  return self
end

function Skin:setEyebrowDepth(val)
  self.eyebrowDepth = (val - 100) / 100
  
  self.transactionalChanges.eyebrowDepth = self.eyebrowDepth

  return self
end

function Skin:setEyebrowHeight(val)
  self.eyebrowHeight = (val - 100) / 100

  self.transactionalChanges.eyebrowHeight = self.eyebrowHeight

  return self
end

function Skin:setNoseWidth(val)
  self.noseWidth = (val - 100) / 100

  self.transactionalChanges.noseWidth = self.noseWidth

  return self
end

function Skin:setNoseHeight(val)
  self.noseHeight = (val - 100) / 100

  self.transactionalChanges.noseHeight = self.noseHeight

  return self
end

function Skin:setNoseLength(val)
  self.noseLength = (val - 100) / 100

  self.transactionalChanges.noseLength = self.noseLength

  return self
end

function Skin:setNoseBridgeShift(val)
  self.noseBridgeShift = (val - 100) / 100

  self.transactionalChanges.noseBridgeShift = self.noseBridgeShift

  return self
end

function Skin:setNoseTip(val)
  self.noseTip = (val - 100) / 100

  self.transactionalChanges.noseTip = self.noseTip

  return self
end

function Skin:setNoseShift(val)
  self.noseShift = (val - 100) / 100

  self.transactionalChanges.noseShift = self.noseShift

  return self
end

function Skin:setChinLength(val)
  self.chinLength = (val - 100) / 100

  self.transactionalChanges.chinLength = self.chinLength

  return self
end

function Skin:setChinPosition(val)
  self.chinPosition = (val - 100) / 100

  self.transactionalChanges.chinPosition = self.chinPosition

  return self
end

function Skin:setChinWidth(val)
  self.chinWidth = (val - 100) / 100

  self.transactionalChanges.chinWidth = self.chinWidth

  return self
end

function Skin:setChinHeight(val)
  self.chinHeight = (val - 100) / 100

  self.transactionalChanges.chinHeight = self.chinHeight

  return self
end

function Skin:setJawWidth(val)
  self.jawWidth = (val - 100) / 100

  self.transactionalChanges.jawWidth = self.jawWidth

  return self
end

function Skin:setJawHeight(val)
  self.jawHeight = (val - 100) / 100

  self.transactionalChanges.jawHeight = self.jawHeight

  return self
end

function Skin:setCheekboneHeight(val)
  self.cheekboneHeight = (val - 100) / 100

  self.transactionalChanges.cheekboneHeight = self.cheekboneHeight

  return self
end

function Skin:setCheekboneWidth(val)
  self.cheekboneWidth = (val - 100) / 100

  self.transactionalChanges.cheekboneWidth = self.cheekboneWidth

  return self
end

function Skin:setCheeksWidth(val)
  self.cheeksWidth = (val - 100) / 100

  self.transactionalChanges.cheeksWidth = self.cheeksWidth

  return self
end

function Skin:setLipsWidth(val)
  self.lipsWidth = (val - 100) / 100

  self.transactionalChanges.lipsWidth = self.lipsWidth

  return self
end

function Skin:setNeckThickness(val)
  self.neckThickness = (val - 100) / 100

  self.transactionalChanges.neckThickness = self.neckThickness

  return self
end

function Skin:setBlemishes(val)
  self.blemishes = val

  self.transactionalChanges.blemishes = self.blemishes

  return self
end

function Skin:setBlemishesOpacity(val)
  self.blemishesOpacity = val / 100

  self.transactionalChanges.blemishesOpacity = self.blemishesOpacity

  return self
end

function Skin:setFreckles(val)
  self.freckles = val

  self.transactionalChanges.freckles = self.freckles

  return self
end

function Skin:setFrecklesOpacity(val)
  self.frecklesOpacity = val / 100

  self.transactionalChanges.frecklesOpacity = self.frecklesOpacity

  return self
end

function Skin:setBlemishesOpacity(val)
  self.blemishesOpacity = val / 100

  self.transactionalChanges.blemishesOpacity = self.blemishesOpacity

  return self
end

function Skin:setComplexion(val)
  self.complexion = val

  self.transactionalChanges.complexion = self.complexion

  return self
end

function Skin:setComplexionOpacity(val)
  self.complexionOpacity = val / 100

  self.transactionalChanges.complexionOpacity = self.complexionOpacity

  return self
end

function Skin:setBlush(val)
  self.blush = val

  self.transactionalChanges.blush = self.blush

  return self
end

function Skin:setBlushOpacity(val)
  self.blushOpacity = val / 100

  self.transactionalChanges.blushOpacity = self.blushOpacity

  return self
end


function Skin:setBlushColor1(val)
  self.blushColor1 = val

  self.transactionalChanges.blushColor1 = self.blushColor1

  return self
end

function Skin:setBlushColor2(val)
  self.blushColor2 = val

  self.transactionalChanges.blushColor2 = self.blushColor2

  return self
end

function Skin:setHair(val)
  self.hair[1] = val

  self.transactionalChanges.hair = self.hair

  return self
end

function Skin:setHairColor1(val)
  self.hairColor[1] = val

  self.transactionalChanges.hairColor = self.hairColor

  return self
end

function Skin:setHairColor2(val)
  self.hairColor[2] = val

  self.transactionalChanges.hairColor = self.hairColor

  return self
end

function Skin:setBeard(val)
  self.beard = val

  self.transactionalChanges.beard = self.beard

  return self
end

function Skin:setBeardOpacity(val)
  self.beardOpacity = val / 100

  self.transactionalChanges.beardOpacity = self.beardOpacity

  return self
end

function Skin:setBeardColor1(val)
  self.beardColor1 = val

  self.transactionalChanges.beardColor1 = self.beardColor1

  return self
end

function Skin:setBeardColor2(val)
  self.beardColor2 = val

  self.transactionalChanges.beardColor2 = self.beardColor2

  return self
end

function Skin:setMakeup(val)
  self.makeup = val

  self.transactionalChanges.makeup = self.makeup

  return self
end

function Skin:setMakeupOpacity(val)
  self.makeupOpacity = val / 100

  self.transactionalChanges.makeupOpacity = self.makeupOpacity

  return self
end

function Skin:setLipstick(val)
  self.lipstick = val

  self.transactionalChanges.lipstick = self.lipstick

  return self
end

function Skin:setLipstickOpacity(val)
  self.lipstickOpacity = val / 100

  self.transactionalChanges.lipstickOpacity = self.lipstickOpacity

  return self
end

function Skin:setLipstickColor(val)
  self.lipstickColor = val

  self.transactionalChanges.lipstickColor = self.lipstickColor

  return self
end

function Skin:setAging(val)
  self.aging = val

  self.transactionalChanges.aging = self.aging

  return self
end

function Skin:setAgingOpacity(val)
  self.agingOpacity = val / 100

  self.transactionalChanges.agingOpacity = self.agingOpacity

  return self
end

function Skin:setChestHair(val)
  self.chestHair = val

  self.transactionalChanges.chestHair = self.chestHair

  return self
end

function Skin:setChestHairOpacity(val)
  self.chestHairOpacity = val / 100

  self.transactionalChanges.chestHairOpacity = self.chestHairOpacity

  return self
end

function Skin:setChestHairColor(val)
  self.chestHairColor = val

  self.transactionalChanges.chestHairColor = self.chestHairColor

  return self
end

function Skin:setSunDamage(val)
  self.sunDamage = val

  self.transactionalChanges.sunDamage = self.sunDamage

  return self
end

function Skin:setSunDamageOpacity(val)
  self.sunDamageOpacity = val / 100

  self.transactionalChanges.sunDamageOpacity = self.sunDamageOpacity

  return self
end

function Skin:setBodyBlemishes(val)
  self.bodyBlemishes = val

  self.transactionalChanges.bodyBlemishes = self.bodyBlemishes

  return self
end

function Skin:setBodyBlemishesOpacity(val)
  self.bodyBlemishesOpacity = val / 100

  self.transactionalChanges.bodyBlemishesOpacity = self.bodyBlemishesOpacity

  return self
end

function Skin:setMoreBodyBlemishes(val)
  self.moreBodyBlemishes = val

  self.transactionalChanges.moreBodyBlemishes = self.moreBodyBlemishes

  return self
end

function Skin:setMoreBodyBlemishesOpacity(val)
  self.moreBodyBlemishesOpacity = val / 100

  self.transactionalChanges.moreBodyBlemishesOpacity = self.moreBodyBlemishesOpacity

  return self
end

function Skin:setModel(model)
  self.model = model

  self.transactionalChanges.model = self.model

  return self
end

function Skin:applyAll(cb)
  local modelHash = GetHashKey(self:getModel())
  
  utils.game.requestModel(modelHash, function()
    SetPlayerModel(PlayerId(), modelHash)

    local ped                      = GetPlayerPed(-1)
    local blend                    = self:getBlend()
    local blendFaceMix             = self:getBlendFaceMix()
    local blendSkinMix             = self:getBlendSkinMix()
    local blendOverrideMix         = self:getBlendOverrideMix()
    local blemishes                = self:getBlemishes()
    local blemishesOpacity         = self:getBlemishesOpacity()
    local eyebrow                  = self:getEyebrow()
    local opacity                  = self:getEyebrowOpacity()
    local eyebrowColor1            = self:getEyebrowColor1()
    local eyebrowColor2            = self:getEyebrowColor2()
    local blush                    = self:getBlush()
    local blushOpacity             = self:getBlushOpacity()
    local blushColor1              = self:getBlushColor1()
    local blushColor2              = self:getBlushColor2()
    local complexion               = self:getComplexion()
    local complexionOpacity        = self:getComplexionOpacity()
    local freckles                 = self:getFreckles()
    local frecklesOpacity          = self:getFrecklesOpacity()
    local beard                    = self:getBeard()
    local beardOpacity             = self:getBeardOpacity()
    local beardColor1              = self:getBeardColor1()
    local beardColor2              = self:getBeardColor2()
    local makeup                   = self:getMakeup()
    local makeupOpacity            = self:getMakeupOpacity()
    local lipstick                 = self:getLipstick()
    local lipstickOpacity          = self:getLipstickOpacity()
    local lipstickColor            = self:getLipstickColor()
    local aging                    = self:getAging()
    local agingOpacity             = self:getAgingOpacity()
    local chestHair                = self:getChestHair()
    local chestHairOpacity         = self:getChestHairOpacity()
    local chestHairColor           = self:getChestHairColor()
    local sunDamage                = self:getSunDamage()
    local sunDamageOpacity         = self:getSunDamageOpacity()
    local bodyBlemishes            = self:getBodyBlemishes()
    local bodyBlemishesOpacity     = self:getBodyBlemishesOpacity()
    local moreBodyBlemishes        = self:getMoreBodyBlemishes()
    local moreBodyBlemishesOpacity = self:getMoreBodyBlemishesOpacity()
    local hair                     = self:getHair()
    local hairColor                = self:getHairColor()

    if (utils.game.isFreemodeModel(self:getModel())) then

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
    end

    for componentId,component in pairs(self.components) do
      SetPedComponentVariation(ped, componentId, component[1], component[2], 1)
    end

    SetPedComponentVariation(ped, 2, hair[1], hair[2], 1)

    SetPedHairColor(ped, hairColor[1], hairColor[2])

    SetModelAsNoLongerNeeded(modelHash)

    if (cb) then
      cb()
    end
  end)
  
end

function Skin:commit()

  local isFreemodeModel = utils.game.isFreemodeModel(self:getModel())

  local applyComponentsIfChanged = function()
    local ped = GetPlayerPed(-1)

    for componentId,component in pairs(self.transactionalChanges.components) do
      SetPedComponentVariation(ped, componentId, component[1], component[2], 1)
    end
  end

  local applyBlendIfChanged = function()
    if isFreemodeModel and 
      (self.transactionalChanges.blend
            or
          self.transactionalChanges.blendSkinMix
            or
          self.transactionalChanges.blendFaceMix
            or
          self.transactionalChanges.blendOverrideMix
      ) then

      local ped = GetPlayerPed(-1)

      local blend            = self:getBlend()
      local blendFaceMix     = self:getBlendFaceMix()
      local blendSkinMix     = self:getBlendSkinMix()
      local blendOverrideMix = self:getBlendOverrideMix()
  
      SetPedHeadBlendData(ped, blend[1], blend[2], blend[3], blend[4], blend[5], blend[6], blendFaceMix, blendSkinMix, blendOverrideMix, true)
    end
  end

  local applyEyeStateIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.eyeState) then
      local ped = GetPlayerPed(-1)
      local eyeState = self:getEyeState()
      SetPedFaceFeature(ped, 11, eyeState)
    end
  end

  local applyEyeColorIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.eyeColor) then
      local ped = GetPlayerPed(-1)
      local eyeColor = self:getEyeColor()
      SetPedEyeColor(ped, eyeColor)
    end
  end

  local applyEyebrowIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.eyebrow) or (self.transactionalChanges.eyebrowOpacity) then
      local ped              = GetPlayerPed(-1)
      local eyebrow          = self:getEyebrow()
      local opacity          = self:getEyebrowOpacity()
      SetPedHeadOverlay(ped, 2, eyebrow, opacity) 
    end
  end
    
  local applyEyebrowColorIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.eyebrowColor1) or (self.transactionalChanges.eyebrowColor2) then
      local ped          = GetPlayerPed(-1)
      local eyebrowColor1 = self:getEyebrowColor1()
      local eyebrowColor2 = self:getEyebrowColor2()

      SetPedHeadOverlayColor(ped, 2, 1, eyebrowColor1, eyebrowColor2)
    end
  end

  local applyEyebrowDepthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.eyebrowDepth) then
      local ped = GetPlayerPed(-1)
      local eyebrowDepth = self:getEyebrowDepth()
      SetPedFaceFeature(ped, 7, eyebrowDepth)
    end
  end

  local applyEyebrowHeightIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.eyebrowHeight) then
      local ped = GetPlayerPed(-1)
      local eyebrowHeight = self:getEyebrowHeight()
      SetPedFaceFeature(ped, 6, eyebrowHeight)
    end
  end

  local applyNoseWidthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.noseWidth) then
      local ped = GetPlayerPed(-1)
      local noseWidth = self:getNoseWidth()
      SetPedFaceFeature(ped, 0, noseWidth)
    end
  end

  local applyNoseHeightIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.noseHeight) then
      local ped = GetPlayerPed(-1)
      local noseHeight = self:getNoseHeight()
      SetPedFaceFeature(ped, 1, noseHeight)
    end
  end

  local applyNoseLengthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.noseLength) then
      local ped = GetPlayerPed(-1)
      local noseLength = self:getNoseLength()
      SetPedFaceFeature(ped, 2, noseLength)
    end
  end

  local applyNoseBridgeShiftIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.noseBridgeShift) then
      local ped = GetPlayerPed(-1)
      local noseBridgeShift = self:getNoseBridgeShift()
      SetPedFaceFeature(ped, 3, noseBridgeShift)
    end
  end

  local applyNoseTipIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.noseTip) then
      local ped = GetPlayerPed(-1)
      local noseTip = self:getNoseTip()
      SetPedFaceFeature(ped, 4, noseTip)
    end
  end

  local applyNoseShiftIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.noseShift) then
      local ped = GetPlayerPed(-1)
      local noseShift = self:getNoseShift()
      SetPedFaceFeature(ped, 5, noseShift)
    end
  end

  local applyChinLengthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.chinLength) then
      local ped = GetPlayerPed(-1)
      local chinLength = self:getChinLength()
      SetPedFaceFeature(ped, 16, chinLength)
    end
  end

  local applyChinPositionIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.chinPosition) then
      local ped = GetPlayerPed(-1)
      local chinPosition = self:getChinPosition()
      SetPedFaceFeature(ped, 18, chinPosition)
    end
  end

  local applyChinWidthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.chinWidth) then
      local ped = GetPlayerPed(-1)
      local chinWidth = self:getChinWidth()
      SetPedFaceFeature(ped, 17, chinWidth)
    end
  end

  local applyChinHeightIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.chinHeight) then
      local ped = GetPlayerPed(-1)
      local chinHeight = self:getChinHeight()
      SetPedFaceFeature(ped, 15, chinHeight)
    end
  end

  local applyJawWidthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.jawWidth) then
      local ped = GetPlayerPed(-1)
      local jawWidth = self:getJawWidth()
      SetPedFaceFeature(ped, 13, jawWidth)
    end
  end

  local applyJawHeightIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.jawHeight) then
      local ped = GetPlayerPed(-1)
      local jawHeight = self:getJawHeight()
      SetPedFaceFeature(ped, 14, jawHeight)
    end
  end

  local applyCheekboneHeightIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.cheekboneHeight) then
      local ped = GetPlayerPed(-1)
      local cheekboneHeight = self:getCheekboneHeight()
      SetPedFaceFeature(ped, 8, cheekboneHeight)
    end
  end

  local applyCheekboneWidthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.cheekboneWidth) then
      local ped = GetPlayerPed(-1)
      local cheekboneWidth = self:getCheekboneWidth()
      SetPedFaceFeature(ped, 9, cheekboneWidth)
    end
  end

  local applyCheeksWidthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.cheeksWidth) then
      local ped = GetPlayerPed(-1)
      local cheeksWidth = self:getCheeksWidth()
      SetPedFaceFeature(ped, 10, cheeksWidth)
    end
  end

  local applyLipsWidthIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.lipsWidth) then
      local ped = GetPlayerPed(-1)
      local lipsWidth = self:getLipsWidth()
      SetPedFaceFeature(ped, 12, lipsWidth)
    end
  end

  local applyNeckThicknessIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.neckThickness) then
      local ped = GetPlayerPed(-1)
      local neckThickness = self:getNeckThickness()
      SetPedFaceFeature(ped, 19, neckThickness)
    end
  end

  local applyBlemishesIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.blemishes) or (self.transactionalChanges.blemishesOpacity) then
      local ped = GetPlayerPed(-1)
      local blemishes = self:getBlemishes()
      local blemishesOpacity = self:getBlemishesOpacity()
      if blemishes == 0 then
        SetPedHeadOverlay(ped, 0, 255, blemishesOpacity)
      else
        SetPedHeadOverlay(ped, 0, blemishes, blemishesOpacity)
      end
    end
  end

  local applyFrecklesIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.freckles) or (self.transactionalChanges.frecklesOpacity) then
      local ped = GetPlayerPed(-1)
      local freckles = self:getFreckles()
      local frecklesOpacity = self:getFrecklesOpacity()
      if freckles == 0 then
        SetPedHeadOverlay(ped, 9, 255, frecklesOpacity)
      else
        SetPedHeadOverlay(ped, 9, freckles, frecklesOpacity)
      end
    end
  end

  local applyComplexionIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.complexion) or (self.transactionalChanges.complexionOpacity) then
      local ped = GetPlayerPed(-1)
      local complexion = self:getComplexion()
      local complexionOpacity = self:getComplexionOpacity()
      if complexion == 0 then
        SetPedHeadOverlay(ped, 6, 255, complexionOpacity)
      else
        SetPedHeadOverlay(ped, 6, complexion, complexionOpacity)
      end
    end
  end

  local applyBlushIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.blush) or (self.transactionalChanges.blushOpacity) then
      local ped = GetPlayerPed(-1)
      local blush = self:getBlush()
      local blushOpacity = self:getBlushOpacity()
      if blush == 0 then
        SetPedHeadOverlay(ped, 5, 255, blushOpacity)
      else
        SetPedHeadOverlay(ped, 5, blush, blushOpacity)
      end
    end
  end

  local applyBlushColorIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.blushColor1) or (self.transactionalChanges.blushColor2) then
      local ped = GetPlayerPed(-1)
      local blushColor1 = self:getBlushColor1()
      local blushColor2 = self:getBlushColor2()
      SetPedHeadOverlayColor(ped, 5, 2, blushColor1, blushColor2)
    end
  end

  local applyHairIfChanged = function()
    if (self.transactionalChanges.hair) then
      local ped = GetPlayerPed(-1)
      local hair = self:getHair()
      SetPedComponentVariation(ped, 2, hair[1], hair[2], 1)
    end
  end

  local applyHairColorIfChanged = function()
    if (self.transactionalChanges.hairColor) then
      local ped = GetPlayerPed(-1)

      local hairColor = self:getHairColor()
      SetPedHairColor(ped, hairColor[1], hairColor[2])
    end
  end

  local applyBeardIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.beard) or (self.transactionalChanges.beardOpacity) then
      local ped = GetPlayerPed(-1)

      local beard = self:getBeard()
      local beardOpacity = self:getBeardOpacity()

      if beard == 0 then
        SetPedHeadOverlay(ped, 1, 255, 0)
      else
        SetPedHeadOverlay(ped, 1, beard, beardOpacity)
      end
    end
  end

  local applyBeardColorIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.beardColor1) or (self.transactionalChanges.beardColor2) then
      local ped = GetPlayerPed(-1)
      local beardColor1 = self:getBeardColor1()
      local beardColor2 = self:getBeardColor2()

      SetPedHeadOverlayColor(ped, 1, 1, beardColor1, beardColor2)
    end
  end

  local applyMakeupIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.makeup) or (self.transactionalChanges.makeupOpacity) then
      local ped = GetPlayerPed(-1)
      local makeup = self:getMakeup()
      local makeupOpacity = self:getMakeupOpacity()

      if makeup == 0 then
        SetPedHeadOverlay(ped, 4, 255, 0)
      else
        SetPedHeadOverlay(ped, 4, makeup, makeupOpacity)
      end
    end
  end

  local applyLipstickIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.lipstick) or (self.transactionalChanges.lipstickOpacity) then
      local ped = GetPlayerPed(-1)
      local lipstick = self:getLipstick()
      local lipstickOpacity = self:getLipstickOpacity()

      if lipstick == 0 then
        SetPedHeadOverlay(ped, 8, 255, 0)
      else
        SetPedHeadOverlay(ped, 8, lipstick, lipstickOpacity)
      end
    end
  end

  local applyLipstickColorIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.lipstickColor) then
      local ped = GetPlayerPed(-1)
      local lipstickColor = self:getLipstickColor()

      SetPedHeadOverlayColor(ped, 8, 2, lipstickColor, lipstickColor)
    end
  end

  local applyAgingIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.aging) or (self.transactionalChanges.agingOpacity) then
      local ped = GetPlayerPed(-1)
      local aging = self:getAging()
      local agingOpacity = self:getAgingOpacity()

      if aging == 0 then
        SetPedHeadOverlay(ped, 3, 255, 0)
      else
        SetPedHeadOverlay(ped, 3, aging, agingOpacity)
      end
    end
  end

  local applyChestHairIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.chestHair) or (self.transactionalChanges.chestHairOpacity) then
      local ped = GetPlayerPed(-1)
      local chestHair = self:getChestHair()
      local chestHairOpacity = self:getChestHairOpacity()

      if chestHair == 0 then
        SetPedHeadOverlay(ped, 10, 255, 0)
      else
        SetPedHeadOverlay(ped, 10, chestHair, chestHairOpacity)
      end
    end
  end

  local applyChestHairColorIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.chestHairColor) then
      local ped = GetPlayerPed(-1)
      local chestHairColor = self:getChestHairColor()

      SetPedHeadOverlayColor(ped, 10, 1, chestHairColor, chestHairColor)
    end
  end

  local applySunDamageIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.sunDamage) or (self.transactionalChanges.sunDamageOpacity) then
      local ped = GetPlayerPed(-1)
      local sunDamage = self:getSunDamage()
      local sunDamageOpacity = self:getSunDamageOpacity()

      if sunDamage == 0 then
        SetPedHeadOverlay(ped, 7, 255, 0)
      else
        SetPedHeadOverlay(ped, 7, sunDamage, sunDamageOpacity)
      end
    end
  end

  local applyBodyBlemishesIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.bodyBlemishes) or (self.transactionalChanges.bodyBlemishesOpacity) then
      local ped = GetPlayerPed(-1)
      local bodyBlemishes = self:getBodyBlemishes()
      local bodyBlemishesOpacity = self:getBodyBlemishesOpacity()

      if bodyBlemishes == 0 then
        SetPedHeadOverlay(ped, 11, 255, 0)
      else
        SetPedHeadOverlay(ped, 11, bodyBlemishes, bodyBlemishesOpacity)
      end
    end
  end

  local applyMoreBodyBlemishesIfChanged = function()
    if (isFreemodeModel and self.transactionalChanges.moreBodyBlemishes) or (self.transactionalChanges.moreBodyBlemishesOpacity) then
      local ped = GetPlayerPed(-1)
      local moreBodyBlemishes = self:getMoreBodyBlemishes()
      local moreBodyBlemishesOpacity = self:getMoreBodyBlemishesOpacity()

      if moreBodyBlemishes == 0 then
        SetPedHeadOverlay(ped, 12, 255, 0)
      else
        SetPedHeadOverlay(ped, 12, moreBodyBlemishes, moreBodyBlemishesOpacity)
      end
    end
  end

  local applyModelIfChanged = function(cb)
    if (self.transactionalChanges.model) then
      local modelHash = GetHashKey(self:getModel())

      utils.game.requestModel(modelHash, function()
        SetPlayerModel(PlayerId(), modelHash)
    
        SetModelAsNoLongerNeeded(modelHash)

        return cb()
      end)
    end
    cb()
  end

  applyModelIfChanged(function()
    applyBlendIfChanged()
    applyComponentsIfChanged()

    applyEyeStateIfChanged()
    applyEyeColorIfChanged()
    applyEyebrowIfChanged()
    applyEyebrowColorIfChanged()
    applyEyebrowDepthIfChanged()
    applyEyebrowHeightIfChanged()

    applyNoseWidthIfChanged()
    applyNoseHeightIfChanged()
    applyNoseLengthIfChanged()
    applyNoseBridgeShiftIfChanged()
    applyNoseTipIfChanged()
    applyNoseShiftIfChanged()

    applyChinLengthIfChanged()
    applyChinPositionIfChanged()
    applyChinWidthIfChanged()
    applyChinHeightIfChanged()
    applyJawWidthIfChanged()
    applyJawHeightIfChanged()

    applyCheekboneHeightIfChanged()
    applyCheekboneWidthIfChanged()
    applyCheeksWidthIfChanged()

    applyLipsWidthIfChanged()

    applyNeckThicknessIfChanged()

    applyBlemishesIfChanged()
    applyFrecklesIfChanged()
    applyComplexionIfChanged()
    applyBlushIfChanged()
    applyBlushColorIfChanged()

    applyHairIfChanged()
    applyHairColorIfChanged()

    applyBeardIfChanged()
    applyBeardColorIfChanged()

    applyMakeupIfChanged()
    applyLipstickIfChanged()
    applyLipstickColorIfChanged()

    applyAgingIfChanged()

    applyChestHairIfChanged()
    applyChestHairColorIfChanged()
    applySunDamageIfChanged()
    applyBodyBlemishesIfChanged()
    applyMoreBodyBlemishesIfChanged()

    self.transactionalChanges = {
      components = {}
    }
  end)

  
end

function Skin:serialize()
  return {
    model                    = self.model,
    components               = self.components,          
    blend                    = self.blend,
    blendFaceMix             = self.blendFaceMix,
    blendSkinMix             = self.blendSkinMix,
    blendOverrideMix         = self.blendOverrideMix,
    eyeState                 = self.eyeState,
    eyeColor                 = self.eyeColor,
    eyebrow                  = self.eyebrow,
    eyebrowOpacity           = self.eyebrowOpacity,
    eyebrowColor1            = self.eyebrowColor1,
    eyebrowColor2            = self.eyebrowColor2,
    eyebrowDepth             = self.eyebrowDepth,
    eyebrowHeight            = self.eyebrowHeight,
    noseWidth                = self.noseWidth,
    noseHeight               = self.noseHeight,
    noseLength               = self.noseLength,
    noseBridgeShift          = self.noseBridgeShift,
    noseTip                  = self.noseTip,
    noseShift                = self.noseShift,
    blemishes                = self.blemishes,
    blemishesOpacity         = self.blemishesOpacity,
    freckles                 = self.freckles,
    frecklesOpacity          = self.frecklesOpacity,
    complexion               = self.complexion,
    complexionOpacity        = self.complexionOpacity,
    blush                    = self.blush,
    blushOpacity             = self.blushOpacity,
    blushColor1              = self.blushColor1,
    blushColor2              = self.blushColor2,
    hair                     = self.hair,
    hairColor                = self.hairColor,
    beard                    = self.beard,
    beardOpacity             = self.beardOpacity,
    beardColor1              = self.beardColor1,
    beardColor2              = self.beardColor2,
    makeup                   = self.makeup,
    makeupOpacity            = self.makeupOpacity,
    lipstick                 = self.lipstick,
    lipstickOpacity          = self.lipstickOpacity,
    lipstickColor            = self.lipstickColor,
    aging                    = self.aging,
    agingOpacity             = self.agingOpacity,
    chestHair                = self.chestHair,
    chestHairOpacity         = self.chestHairOpacity,
    chestHairColor           = self.chestHairColor,
    sunDamage                = self.sunDamage,
    sunDamageOpacity         = self.sunDamageOpacity,
    bodyBlemishes            = self.bodyBlemishes,
    bodyBlemishesOpacity     = self.bodyBlemishesOpacity,
    moreBodyBlemishes        = self.moreBodyBlemishes,
    moreBodyBlemishesOpacity = self.moreBodyBlemishesOpacity
  }
end

function SkinEditor:constructor(skinContent)
  self.super:ctor()

  if skinContent then
    self.skin = Skin(skinContent)
  else
    self.skin = Skin()
  end
  self._ped = 0
  self.tick = nil
  self.mainMenu = nil
  self.currentMenu = nil
  self.modelTimeout = nil

  self:ensurePed()
end

function SkinEditor:destructor()

  camera.destroy()
  self.mainMenu:destroy()

  -- TODO : Fix this, field super is nil ?
  -- self.super:destructor()
end

function SkinEditor:start()
  DoScreenFadeOut(1000)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  SetEntityCoords(PlayerPedId(), 402.869, -996.5966, -99.0003, 0.0, 0.0, 0.0, true)
  SetEntityHeading(PlayerPedId(), 180.01846313477)

  Citizen.Wait(1000)

  DoScreenFadeIn(1000)

  module.openedMenu = true
	emit('esx:identity:preventSaving', true)
  camera.start()
  self:openMenu()
  self.skin:applyAll(function()
    self:mainCameraScene()
    self:emit('start')
  end)
end

function SkinEditor:ensurePed()
  local ped = GetPlayerPed(-1)
  self._ped                 = ped
  self.pedModel             = GetEntityModel(ped)
  self.isPedPlayer          = IsPedAPlayer(ped)
  self.isPedHuman           = utils.game.isHumanModel(self.pedModel)
  self.isPedFreemode        = self.isPedHuman and utils.game.isFreemodeModel(self.pedModel)
  self.canEnforceComponents = self.isPedFreemode

  if self.isPedPlayer then
    
    self.player = NetworkGetPlayerIndexFromPed(self._ped)

    if self.player ~= PlayerId() then
      error('Editing other players is forbidden')
    end

  end

  if self.isPedHuman then
    self.models = Config.humans
  else
    self.models = Config.animals
  end

end

function SkinEditor:getPed()
  self:ensurePed()
  return self._ped
end

function SkinEditor:openMenu()

  self:ensurePed()

  camera.resetCamera()

  local items = {
    {name = 'model',   label = self:getModelLabelByIndex(0),         type = 'slider', max   = #self.models - 1, visible = self.isPedPlayer},
    {name = 'enforce', label = 'Enforce compatible elements (WIP)',  type = 'check',  value = false,            visible = self.canEnforceComponents},
  }
  
  items[#items + 1] = {type= 'button', name = 'skin.base', label = "Base", visible = self.canEnforceComponents}
  items[#items + 1] = {type= 'button', name = 'skin.style', label = "Style", visible = self.canEnforceComponents}
  items[#items + 1] = {type= 'button', name = 'skin.clothes', label = "Clothes", visible = self.canEnforceComponents}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {type= 'button', name = 'save', label = "💾 Save 💾"}

  self.mainMenu = Menu('skin', {
    title = 'Character',
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = self.mainMenu

  self.mainMenu:on('item.change', function(item, prop, val, index)
    self:onItemChanged(item, prop, val, index)
  end)

  self.mainMenu:on('item.click', function(item, index)

    if item.name == 'skin.base' then
      return self:openBaseMenu(item.component)
    elseif item.name == 'skin.style' then
      return self:openStyleMenu(item.component)
    elseif item.name == 'skin.clothes' then
      return self:openClothesMenu(item.component)
    elseif item.name == 'skin.old' then
      return self:openOldMenu(item.component)
    end
    
    if item.name == 'save' then
      self:saveFromMenu()
    end

  end)

end

function SkinEditor:openBaseMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'button', name = 'skin.base.parents', label = "Parents"}
  items[#items + 1] = {type= 'button', name = 'skin.base.eyes', label = "Eyes"}
  items[#items + 1] = {type= 'button', name = 'skin.base.nose', label = "Nose"}
  items[#items + 1] = {type= 'button', name = 'skin.base.chin', label = "Chin"}
  items[#items + 1] = {type= 'button', name = 'skin.base.cheek', label = "Cheeks"}
  items[#items + 1] = {type= 'button', name = 'skin.base.lips', label = "Lips"}
  items[#items + 1] = {type= 'button', name = 'skin.base.neck', label = "Neck"}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.mainMenu.visible then
    self.mainMenu:hide()
  end

  self.baseMenu = Menu('skin.base', {
    title = "Base",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = self.baseMenu

  self.baseMenu:on('destroy', function()
    self.mainMenu:show()
  end)

  self.baseMenu:on('item.click', function(item, index) 
    if item.name == 'skin.base.parents' then
      return self:openParentsMenu(item.component)
    elseif item.name == 'skin.base.eyes' then
      return self:openEyesMenu(item.component)   
    elseif item.name == 'skin.base.nose' then
      return self:openNoseMenu(item.component)   
    elseif item.name == 'skin.base.chin' then
      return self:openChinMenu(item.component)    
    elseif item.name == 'skin.base.cheek' then
      return self:openCheeksMenu(item.component) 
    elseif item.name == 'skin.base.lips' then
      return self:openLipsMenu(item.component) 
    elseif item.name == 'skin.base.neck' then
      return self:openNeckMenu(item.component) 
    elseif item.name == 'submit' then
      self.baseMenu:destroy()
      
      self.currentMenu = self.mainMenu

      self.mainMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openStyleMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'button', name = 'skin.style.face', label = "Face"}
  items[#items + 1] = {type= 'button', name = 'skin.style.markings', label = "Markings"}
  items[#items + 1] = {type= 'button', name = 'skin.style.hair', label = "Hair"}
  items[#items + 1] = {type= 'button', name = 'skin.style.beard', label = "Beard"}
  items[#items + 1] = {type= 'button', name = 'skin.style.makeup', label = "Makeup"}
  items[#items + 1] = {type= 'button', name = 'skin.style.aging', label = "Aging"}
  items[#items + 1] = {type= 'button', name = 'skin.style.chest', label = "Chest"}
  items[#items + 1] = {type= 'button', name = 'skin.style.body', label = "Body"}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.mainMenu.visible then
    self.mainMenu:hide()
  end

  self.styleMenu = Menu('skin.style', {
    title = "Style",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = self.styleMenu

  self.styleMenu:on('destroy', function()
    self.mainMenu:show()
  end)

  self.styleMenu:on('item.click', function(item, index) 
    if item.name == 'skin.style.face' then
      return self:openFaceMenu(item.component)
    elseif item.name == 'skin.style.markings' then
      return self:openMarkingsMenu(item.component)
    elseif item.name == 'skin.style.hair' then
      return self:openHairMenu(item.component)   
    elseif item.name == 'skin.style.beard' then
      return self:openBeardMenu(item.component)   
    elseif item.name == 'skin.style.makeup' then
      return self:openMakeupMenu(item.component)    
    elseif item.name == 'skin.style.aging' then
      return self:openAgingMenu(item.component) 
    elseif item.name == 'skin.style.chest' then
      return self:openChestMenu(item.component) 
    elseif item.name == 'skin.style.body' then
      return self:openBodyMenu(item.component) 
    elseif item.name == 'submit' then
      self.styleMenu:destroy()
      
      self.currentMenu = self.mainMenu

      self.mainMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openClothesMenu()

  self:ensurePed()

  local items = {}

  for i=1, #Config.componentOrder, 1 do

    local comp  = Config.componentOrder[i]
    local label = Config.componentsConfig[comp].label

    items[#items + 1] = {type= 'button', name = 'component.' .. GetEnumKey(PED_COMPONENTS, comp), component = comp, label = label}

  end

  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}


  self.clothesMenu = Menu('skin.clothes', {
    title = 'Clothes',
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = self.clothesMenu

  if self.mainMenu.visible then
    self.mainMenu:hide()
  end

  self.clothesMenu:on('destroy', function()
    self.mainMenu:show()
  end)

  self.clothesMenu:on('item.click', function(item, index)

    if item.component ~= nil then

      self:openComponentMenu(item.component)
    elseif item.name == 'submit' then
      self.clothesMenu:destroy()
      
      self.currentMenu = self.mainMenu

      self.mainMenu:focus()
      self:mainCameraScene()
    end

  end)

end

-- TODO: refactor this so split into either a different class or another file
function SkinEditor:openParentsMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.face.father',   max   = 45,  value = self.skin:getBlend()[1],         label = self:getBlendFaceFatherLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.face.mother',   max   = 45,  value = self.skin:getBlend()[2],         label = self:getBlendFaceMotherLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.face.override', max   = 45,  value = self.skin:getBlend()[3],         label = self:getBlendFaceOverrideLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.skin.father',   max   = 45,  value = self.skin:getBlend()[4],         label = self:getBlendSkinToneFatherLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.skin.mother',   max   = 45,  value = self.skin:getBlend()[5],         label = self:getBlendSkinToneMotherLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.skin.override', max   = 45,  value = self.skin:getBlend()[6],         label = self:getBlendSkinToneOverrideLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.face.mix',      max   = 100, value = self.skin:getBlendFaceMix(),     label = self:getBlendFaceMixLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.skin.mix',      max   = 100, value = self.skin:getBlendSkinMix(),     label = self:getBlendSkinMixLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.parents.override.mix',  max   = 100, value = self.skin:getBlendOverrideMix(), label = self:getBlendOverrideMixLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.parents', {
    title = "Parents",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.parents.face.father' then
        self.skin:setFaceFather(val)
        item.label = self:getBlendFaceFatherLabel()
      elseif item.name == 'skin.base.parents.face.mother' then
        self.skin:setFaceMother(val)
        item.label = self:getBlendFaceMotherLabel()
      elseif item.name == 'skin.base.parents.face.override' then
        self.skin:setFaceOverride(val)
        item.label = self:getBlendFaceOverrideLabel()
      elseif item.name == 'skin.base.parents.skin.father' then
        self.skin:setSkinToneFather(val)
        item.label = self:getBlendSkinToneFatherLabel()
      elseif item.name == 'skin.base.parents.skin.mother' then
        self.skin:setSkinToneMother(val)
        item.label = self:getBlendSkinToneMotherLabel()
      elseif item.name == 'skin.base.parents.skin.override' then
        self.skin:setSkinToneOverride(val)
        item.label = self:getBlendSkinToneOverrideLabel()
      elseif item.name == 'skin.base.parents.face.mix' then
        self.skin:setFaceMix(val)
        item.label = self:getBlendFaceMixLabel()
      elseif item.name == 'skin.base.parents.skin.mix' then
        self.skin:setSkinMix(val)
        item.label = self:getBlendSkinMixLabel()
      elseif item.name == 'skin.base.parents.override.mix' then
        self.skin:setOverrideMix(val)
        item.label = self:getBlendOverrideMixLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openEyesMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.state', max   = 200,  value = self.skin:getEyeState(), label = self:getEyeStateLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.color', max   = 31,  value = self.skin:getEyeColor(), label = self:getEyeColorLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.brows', max   = 33,  value = self.skin:getEyebrow(), label = self:getEyebrowLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.brows.opacity', max = 100,  value = self.skin:getEyebrowOpacity(), label = self:getEyebrowOpacityLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.brow.color1', max = 64,  value = self.skin:getEyebrowColor1(), label = self:getEyebrowColor1Label()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.brow.color2', max  = 64,  value = self.skin:getEyebrowColor2(), label = self:getEyebrowColor2Label()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.brow.width', max  = 200,  value = self.skin:getEyebrowDepth(), label = self:getEyebrowDepthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.eyes.brow.shape', max  = 200,  value = self.skin:getEyebrowHeight(), label = self:getEyebrowHeightLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.eyes', {
    title = "Eyes",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.eyes.state' then
        self.skin:setEyeState(val)
        item.label = self:getEyeStateLabel()
      elseif item.name == 'skin.base.eyes.color' then
        self.skin:setEyeColor(val)
        item.label = self:getEyeColorLabel()
      elseif item.name == 'skin.base.eyes.brows' then
        self.skin:setEyebrow(val)
        item.label = self:getEyebrowLabel()
      elseif item.name == 'skin.base.eyes.brows.opacity' then
        self.skin:setEyebrowOpacity(val)
        item.label = self:getEyebrowOpacityLabel()
      elseif item.name == 'skin.base.eyes.brow.color1' then
        self.skin:setEyebrowColor1(val)
        item.label = self:getEyebrowColor1Label()
      elseif item.name == 'skin.base.eyes.brow.color2' then
        self.skin:setEyebrowColor2(val)
        item.label = self:getEyebrowColor2Label()
      elseif item.name == 'skin.base.eyes.brow.width' then
        self.skin:setEyebrowDepth(val)
        item.label = self:getEyebrowDepthLabel()
      elseif item.name == 'skin.base.eyes.brow.shape' then
        self.skin:setEyebrowHeight(val)
        item.label = self:getEyebrowHeightLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openNoseMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.nose.width', max   = 200,  value = self.skin:getNoseWidth(), label = self:getNoseWidthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.nose.height', max   = 31,  value = self.skin:getNoseHeight(), label = self:getNoseHeightLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.nose.length', max   = 33,  value = self.skin:getNoseLength(), label = self:getNoseLengthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.nose.bridge.shift', max = 100,  value = self.skin:getNoseBridgeShift(), label = self:getNoseBridgeShiftLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.nose.tip', max = 64,  value = self.skin:getNoseTip(), label = self:getNoseTipLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.nose.shift', max  = 64,  value = self.skin:getNoseShift(), label = self:getNoseShiftLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.nose', {
    title = "Nose",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.nose.width' then
        self.skin:setNoseWidth(val)
        item.label = self:getNoseWidthLabel()
      elseif item.name == 'skin.base.nose.height' then
        self.skin:setNoseHeight(val)
        item.label = self:getNoseHeightLabel()
      elseif item.name == 'skin.base.nose.length' then
        self.skin:setNoseLength(val)
        item.label = self:getNoseLengthLabel()
      elseif item.name == 'skin.base.nose.bridge.shift' then
        self.skin:setNoseBridgeShift(val)
        item.label = self:getNoseBridgeShiftLabel()
      elseif item.name == 'skin.base.nose.tip' then
        self.skin:setNoseTip(val)
        item.label = self:getNoseTipLabel()
      elseif item.name == 'skin.base.nose.shift' then
        self.skin:setNoseShift(val)
        item.label = self:getNoseShiftLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openChinMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.chin.length', max = 200,  value = self.skin:getChinLength(), label = self:getChinLengthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.chin.position', max = 200,  value = self.skin:getChinPosition(), label = self:getChinPositionLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.chin.width', max = 200,  value = self.skin:getChinWidth(), label = self:getChinWidthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.chin.height', max = 200,  value = self.skin:getChinHeight(), label = self:getChinHeightLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.jaw.width', max = 200,  value = self.skin:getJawWidth(), label = self:getJawWidthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.jaw.height', max = 200,  value = self.skin:getJawHeight(), label = self:getJawHeightLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.chin', {
    title = "Chin",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.chin.length' then
        self.skin:setChinLength(val)
        item.label = self:getChinLengthLabel()
      elseif item.name == 'skin.base.chin.position' then
        self.skin:setChinPosition(val)
        item.label = self:getChinPositionLabel()
      elseif item.name == 'skin.base.chin.width' then
        self.skin:setChinWidth(val)
        item.label = self:getChinWidthLabel()
      elseif item.name == 'skin.base.chin.height' then
        self.skin:setChinHeight(val)
        item.label = self:getChinHeightLabel()
      elseif item.name == 'skin.base.jaw.width' then
        self.skin:setJawWidth(val)
        item.label = self:getJawWidthLabel()
      elseif item.name == 'skin.base.jaw.height' then
        self.skin:setJawHeight(val)
        item.label = self:getJawHeightLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openCheeksMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.cheekbone.height', max = 200,  value = self.skin:getCheekboneHeight(), label = self:getCheekboneHeightLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.cheekbone.width', max = 200,  value = self.skin:getCheekboneWidth(), label = self:getCheekboneWidthLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.base.cheeks.width', max = 200,  value = self.skin:getCheeksWidth(), label = self:getCheeksWidthLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.cheeks', {
    title = "Cheeks",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.cheekbone.height' then
        self.skin:setCheekboneHeight(val)
        item.label = self:getCheekboneHeightLabel()
      elseif item.name == 'skin.base.cheekbone.width' then
        self.skin:setCheekboneWidth(val)
        item.label = self:getCheekboneWidthLabel()
      elseif item.name == 'skin.base.cheeks.width' then
        self.skin:setCheeksWidth(val)
        item.label = self:getCheeksWidthLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openLipsMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.lips.width', max = 200,  value = self.skin:getLipsWidth(), label = self:getLipsWidthLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.lips', {
    title = "Lips",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.lips.width' then
        self.skin:setLipsWidth(val)
        item.label = self:getLipsWidthLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openNeckMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.base.neck.height', max = 200,  value = self.skin:getNeckThickness(), label = self:getNeckThicknessLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.baseMenu.visible then
    self.baseMenu:hide()
  end

  local menu = Menu('skin.base.neck', {
    title = "Lips",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.baseMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.base.neck.height' then
        self.skin:setNeckThickness(val)
        item.label = self:getNeckThicknessLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.baseMenu
      self.baseMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openFaceMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.style.face.complexion', max = 12, value = self.skin:getComplexion(), label = self:getComplexionLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.face.complexion.opacity', max = 100, value = self.skin:getComplexionOpacity(), label = self:getComplexionOpacityLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.face.blush', max = 7, value = self.skin:getBlush(), label = self:getBlushLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.face.blush.opacity', max = 100, value = self.skin:getBlushOpacity(), label = self:getBlushOpacityLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.face.blush.color1', max = GetNumHairColors(), value = self.skin:getBlushColor1(), label = self:getBlushColor1Label()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.face.blush.color2', max = GetNumHairColors(), value = self.skin:getBlushColor2(), label = self:getBlushColor2Label()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.face', {
    title = "Face",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.face.complexion' then
        self.skin:setComplexion(val)
        item.label = self:getComplexionLabel()
      elseif item.name == 'skin.style.face.complexion.opacity' then
        self.skin:setComplexionOpacity(val)
        item.label = self:getComplexionOpacityLabel()
      elseif item.name == 'skin.style.face.blush' then
        self.skin:setBlush(val)
        item.label = self:getBlushLabel()
      elseif item.name == 'skin.style.face.blush.opacity' then
        self.skin:setBlushOpacity(val)
        item.label = self:getBlushOpacityLabel()
      elseif item.name == 'skin.style.face.blush.color1' then
        self.skin:setBlushColor1(val)
        item.label = self:getBlushColor1Label()
      elseif item.name == 'skin.style.face.blush.color2' then
        self.skin:setBlushColor2(val)
        item.label = self:getBlushColor2Label()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openMarkingsMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type= 'slider', name = 'skin.style.markings.blemishes', max = 23, value = self.skin:getBlemishes(), label = self:getBlemishesLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.markings.blemishes.opacity', max = 100, value = self.skin:getBlemishesOpacity(), label = self:getBlemishesOpacityLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.markings.freckles', max = 17, value = self.skin:getFreckles(), label = self:getFrecklesLabel()}
  items[#items + 1] = {type= 'slider', name = 'skin.style.markings.freckles.opacity', max = 100, value = self.skin:getFrecklesOpacity(), label = self:getFrecklesOpacityLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.markings', {
    title = "markings",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.markings.blemishes' then
        self.skin:setBlemishes(val)
        item.label = self:getBlemishesLabel()
      elseif item.name == 'skin.style.markings.blemishes.opacity' then
        self.skin:setBlemishesOpacity(val)
        item.label = self:getBlemishesOpacityLabel() 
      elseif item.name == 'skin.style.markings.freckles' then
        self.skin:setFreckles(val)
        item.label = self:getFrecklesLabel()
      elseif item.name == 'skin.style.markings.freckles.opacity' then
        self.skin:setFrecklesOpacity(val)
        item.label = self:getFrecklesOpacityLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openHairMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type  = 'slider', name  = 'skin.style.hair.hair', max  = GetNumberOfPedDrawableVariations(self._ped, PV_COMP_HAIR) - 1, value = self.skin:getHair(), label = self:getHairLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.hair.color', max  = GetNumHairColors(), value = self.skin:getHairColor()[1], label = self:getHairColor1Label()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.hair.hightlights', max  = GetNumHairColors(), value = self.skin:getHairColor()[2], label = self:getHairColor2Label()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.hair', {
    title = "Hair",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.hair.hair' then
        self.skin:setHair(val)
        item.label = self:getHairLabel()
      elseif item.name == 'skin.style.hair.color' then
        self.skin:setHairColor1(val)
        item.label = self:getHairColor1Label()
      elseif item.name == 'skin.style.hair.highlights' then
        self.skin:setHairColor2(val)
        item.label = self:getHairColor2Label()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openBeardMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type  = 'slider', name  = 'skin.style.beard.beard', max  = 29, value = self.skin:getBeard(), label = self:getBeardLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.beard.opacity', max  = 100, value = self.skin:getBeardOpacity(), label = self:getBeardOpacityLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.beard.color1', max  = GetNumHairColors(), value = self.skin:getBeardColor1(), label = self:getBeardColor1Label()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.beard.color2', max  = GetNumHairColors(), value = self.skin:getBeardColor2(), label = self:getBeardColor2Label()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.beard', {
    title = "Beard",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.beard.beard' then
        self.skin:setBeard(val)
        item.label = self:getBeardLabel()
      elseif item.name == 'skin.style.beard.opacity' then
        self.skin:setBeardOpacity(val)
        item.label = self:getBeardOpacityLabel()
      elseif item.name == 'skin.style.beard.color1' then
        self.skin:setBeardColor1(val)
        item.label = self:getBeardColor1Label()
      elseif item.name == 'skin.style.beard.color2' then
        self.skin:setBeardColor2(val)
        item.label = self:getBeardColor2Label()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openMakeupMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type  = 'slider', name  = 'skin.style.makeup.makeup', max  = 74, value = self.skin:getMakeup(), label = self:getMakeupLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.makeup.opacity', max  = 100, value = self.skin:getMakeupOpacity(), label = self:getMakeupOpacityLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.makeup.lipstick', max  = 9, value = self.skin:getLipstick(), label = self:getLipstickLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.makeup.lipstick.opacity', max  = 100, value = self.skin:getLipstickOpacity(), label = self:getLipstickOpacityLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.makeup.lipstick.color', max  = GetNumHairColors(), value = self.skin:getLipstickColor(), label = self:getLipstickColorLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.beard', {
    title = "Beard",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.makeup.makeup' then
        self.skin:setMakeup(val)
        item.label = self:getMakeupLabel()
      elseif item.name == 'skin.style.makeup.opacity' then
        self.skin:setMakeupOpacity(val)
        item.label = self:getMakeupOpacityLabel()
      elseif item.name == 'skin.style.makeup.lipstick' then
        self.skin:setLipstick(val)
        item.label = self:getLipstickLabel()
      elseif item.name == 'skin.style.makeup.lipstick.opacity' then
        self.skin:setLipstickOpacity(val)
        item.label = self:getLipstickOpacityLabel()
      elseif item.name == 'skin.style.makeup.lipstick.color' then
        self.skin:setLipstickColor(val)
        item.label = self:getLipstickLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openAgingMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type  = 'slider', name  = 'skin.style.aging.aging', max  = 14, value = self.skin:getAging(), label = self:getAgingLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.aging.opacity', max  = 100, value = self.skin:getAgingOpacity(), label = self:getAgingOpacityLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.aging', {
    title = "Aging",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.aging.aging' then
        self.skin:setAging(val)
        item.label = self:getAgingLabel()
      elseif item.name == 'skin.style.aging.opacity' then
        self.skin:setAgingOpacity(val)
        item.label = self:getAgingOpacityLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openChestMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type  = 'slider', name  = 'skin.style.chest.chesthair', max  = 16, value = self.skin:getChestHair(), label = self:getChestHairLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.chest.chesthair.opacity', max  = 100, value = self.skin:getChestHairOpacity(), label = self:getChestHairOpacityLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.chest.chesthair.color', max  = GetNumHairColors(), value = self.skin:getChestHairColor(), label = self:getChestHairColorLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.chest', {
    title = "Chest",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.chest.chesthair' then
        self.skin:setChestHair(val)
        item.label = self:getChestHairLabel()
      elseif item.name == 'skin.style.chest.chesthair.opacity' then
        self.skin:setChestHairOpacity(val)
        item.label = self:getChestHairOpacityLabel()
      elseif item.name == 'skin.style.chest.chesthair.color' then
        self.skin:setChestHairColor(val)
        item.label = self:getChestHairColorLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:openBodyMenu(comp)

  self:ensurePed()

  local items = {}

  items[#items + 1] = {type  = 'slider', name  = 'skin.style.body.sundamage', max  = 10, value = self.skin:getSunDamage(), label = self:getSunDamageLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.body.sundamage.opacity', max  = 100, value = self.skin:getSunDamageOpacity(), label = self:getSunDamageOpacityLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.body.blemishes', max  = 11, value = self.skin:getBodyBlemishes(), label = self:getBodyBlemishesLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.body.blemishes.opacity', max  = 100, value = self.skin:getBodyBlemishesOpacity(), label = self:getBodyBlemishesOpacityLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.body.blemishes.more', max  = 1, value = self.skin:getMoreBodyBlemishes(), label = self:getMoreBodyBlemishesLabel()}
  items[#items + 1] = {type  = 'slider', name  = 'skin.style.body.blemishes.opacity', max  = 100, value = self.skin:getMoreBodyBlemishesOpacity(), label = self:getMoreBodyBlemishesOpacityLabel()}
  items[#items + 1] = {name = 'sep', label = ""}
  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.styleMenu.visible then
    self.styleMenu:hide()
  end

  local menu = Menu('skin.style.body', {
    title = "Body",
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.styleMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then
      local byName = menu:by('name')

      if item.name == 'skin.style.body.sundamage' then
        self.skin:setSunDamage(val)
        item.label = self:getSunDamageLabel()
      elseif item.name == 'skin.style.body.sundamage.opacity' then
        self.skin:setSunDamageOpacity(val)
        item.label = self:getSunDamageOpacityLabel()
      elseif item.name == 'skin.style.body.blemishes' then
        self.skin:setBodyBlemishes(val)
        item.label = self:getBodyBlemishesLabel()
      elseif item.name == 'skin.style.body.blemishes.opacity' then
        self.skin:setBodyBlemishesOpacity(val)
        item.label = self:getBodyBlemishesOpacityLabel()
      elseif item.name == 'skin.style.body.blemishes.more' then
        self.skin:setMoreBodyBlemishes(val)
        item.label = self:getMoreBodyBlemishesLabel()
      elseif item.name == 'skin.style.body.blemishes.more.opacity' then
        self.skin:setMoreBodyBlemishesOpacity(val)
        item.label = self:getMoreBodyBlemishesOpacityLabel()
      end

      self.skin:commit()
    end
  end)

  menu:on('item.click', function(item, index)
    if item.name == 'submit' then
      menu:destroy()
      self.currentMenu = self.styleMenu
      self.styleMenu:focus()
      self:mainCameraScene()
    end
  end)
end

function SkinEditor:onItemChanged(item, prop, val, index)
  
  if prop == 'value' then

    if item.name == 'model' then

      item.label = self:getModelLabelByIndex(val)
      -- Ensure not spamming model changes
      if self.modelTimeout ~= nil then
        ESX.ClearTimeout(self.modelTimeout)
      end

      self.modelTimeout = ESX.SetTimeout(250, function()

        local model  = self.models[val + 1]
        local ped    = self:getPed()

        self.skin = nil
        self.skin = Skin({model = PED_MODELS_BY_HASH[self.models[val + 1]]})

        self.skin:applyAll(function()
          
          local byName = self.mainMenu:by('name')
          -- byName['enforce'].visible = self.isPedFreemode

          local modelLabel = self:getModelLabelByIndex(val)

          ped = self:getPed()
        end)
      end)

    elseif item.name == 'ensure' then
    
      self.canEnforceComponents = val

    elseif item.name == 'blend.face' then

      self.skin:setFace(val)
      self.skin:commit()

      item.label = self:getBlendFaceLabel()
      
    elseif item.name == 'blend.skin' then

      self.skin:setSkinTone(val)
      self.skin:commit()

      item.label = self:getBlendSkinToneLabel()

    end
  
  end

end

function SkinEditor:getBlendFaceFatherLabel()
  return "Face One ( " .. (self.skin:getBlend()[1] + 1) .. " / " .. 46 .. " )"
end

function SkinEditor:getBlendFaceMotherLabel()
  return "Face Two ( " .. (self.skin:getBlend()[2] + 1) .. " / " .. 46 .. " )"
end

function SkinEditor:getBlendFaceOverrideLabel()
  return "Face Override ( " .. (self.skin:getBlend()[3] + 1) .. " / " .. 46 .. " )"
end

function SkinEditor:getBlendSkinToneFatherLabel()
  return "Skin One ( " .. (self.skin:getBlend()[4] + 1) .. " / " .. 46 .. " )"
end

function SkinEditor:getBlendSkinToneMotherLabel()
  return "Skin Two ( " .. (self.skin:getBlend()[5] + 1) .. " / " .. 46 .. " )"
end

function SkinEditor:getBlendSkinToneOverrideLabel()
  return "Skin Override ( " .. (self.skin:getBlend()[6] + 1) .. " / " .. 46 .. " )"
end

function SkinEditor:getBlendFaceMixLabel()
  return "Face Mix ( " .. (self.skin:getBlendFaceMix()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBlendSkinMixLabel()
  return "Skin Mix ( " .. (self.skin:getBlendSkinMix()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBlendOverrideMixLabel()
  return "Override Mix ( " .. (self.skin:getBlendOverrideMix()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getEyeStateLabel()
  return "Eye State ( " .. (self.skin:getEyeState()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getEyeColorLabel()
  local eyeColor = self.skin:getEyeColor()
  return "Eye Color ( " .. Config.EyeColors[eyeColor + 1] .. " )"
end

function SkinEditor:getEyebrowLabel()
  return "Eyebrows ( " .. (self.skin:getEyebrow() + 1) .. " / " .. 34 .. " ) "
end

function SkinEditor:getEyebrowOpacityLabel()
  return "Eyebrows Opacity ( " .. (self.skin:getEyebrowOpacity()) .. " / " .. 1.0 .. " ) "
end

function SkinEditor:getEyebrowColor1Label()
  return "Eyebrows Color 1 ( " .. (self.skin:getEyebrowColor1() + 1) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getEyebrowColor2Label()
  return "Eyebrows Color 2 ( " .. (self.skin:getEyebrowColor1() + 1) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getEyebrowDepthLabel()
  return "Eyebrow Depth ( " .. (self.skin:getEyebrowDepth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getEyebrowHeightLabel()
  return "Eyebrow Height ( " .. (self.skin:getEyebrowHeight()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNoseWidthLabel()
  return "Nose Width ( " .. (self.skin:getNoseWidth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNoseHeightLabel()
  return "Nose Height ( " .. (self.skin:getNoseHeight()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNoseLengthLabel()
  return "Nose Length ( " .. (self.skin:getNoseLength()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNoseBridgeShiftLabel()
  return "Nose Bridge Shift ( " .. (self.skin:getNoseBridgeShift()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNoseTipLabel()
  return "Nose Tip ( " .. (self.skin:getNoseTip()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNoseShiftLabel()
  return "Nose Shift ( " .. (self.skin:getNoseShift()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getComponentDrawableLabel(componentId)
  return "Model ( " .. (self.skin:getComponent(componentId)[1]) .. " / " .. GetNumberOfPedDrawableVariations(GetPlayerPed(-1), componentId) - 1 .. " )"
end

function SkinEditor:getComponentTextureLabel(componentId)
  return "Variant ( " .. (self.skin:getComponent(componentId)[2]) .. " / " .. GetNumberOfPedTextureVariations(GetPlayerPed(-1), componentId, self.skin:getComponent(componentId)[1]) .. " )"
end

function SkinEditor:getChinLengthLabel()
  return "Chin Length ( " .. (self.skin:getChinLength()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getChinPositionLabel()
  return "Chin Position ( " .. (self.skin:getChinPosition()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getChinWidthLabel()
  return "Chin Width ( " .. (self.skin:getChinWidth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getChinHeightLabel()
  return "Chin Height ( " .. (self.skin:getChinHeight()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getJawWidthLabel()
  return "Jaw Width ( " .. (self.skin:getJawWidth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getJawHeightLabel()
  return "Jaw Height ( " .. (self.skin:getJawHeight()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getCheekboneHeightLabel()
  return "Cheekbone Height ( " .. (self.skin:getCheekboneHeight()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getCheekboneWidthLabel()
  return "Cheekbone Width ( " .. (self.skin:getCheekboneWidth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getCheeksWidthLabel()
  return "Cheeks Width ( " .. (self.skin:getCheeksWidth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getLipsWidthLabel()
  return "Lips Width ( " .. (self.skin:getLipsWidth()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getNeckThicknessLabel()
  return "Neck Thickness ( " .. (self.skin:getNeckThickness()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBlemishesLabel()
  return "Blemishes ( " .. (self.skin:getBlemishes()) .. " / " .. 24 .. " )"
end

function SkinEditor:getBlemishesOpacityLabel()
  return "Blemishes Opacity ( " .. (self.skin:getBlemishesOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getFrecklesLabel()
  return "Freckles ( " .. (self.skin:getFreckles()) .. " / " .. 18 .. " )"
end

function SkinEditor:getFrecklesOpacityLabel()
  return "Freckles Opacity( " .. (self.skin:getFrecklesOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getComplexionLabel()
  return "Complexion ( " .. (self.skin:getComplexion()) .. " / " .. 12 .. " )"
end

function SkinEditor:getComplexionOpacityLabel()
  return "Complexion Opacity ( " .. (self.skin:getComplexionOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBlushLabel()
  return "Blush ( " .. (self.skin:getBlush()) .. " / " .. 7 .. " )"
end

function SkinEditor:getBlushOpacityLabel()
  return "Blush Opacity ( " .. (self.skin:getBlushOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBlushColor1Label()
  return "Blush Color 1 ( " .. (self.skin:getBlushColor1()) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getBlushColor2Label()
  return "Blush Color 2 ( " .. (self.skin:getBlushColor2()) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getHairLabel()
  return "Hair ( " .. (self.skin:getHair()[1]) .. " / " .. 73 .. " )"
end

function SkinEditor:getHairColor1Label()
  return "Hair Color 1 ( " .. (self.skin:getHairColor()[1]) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getHairColor2Label()
  return "Hair Color 2 ( " .. (self.skin:getHairColor()[2]) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getBeardLabel()
  return "Beard ( " .. (self.skin:getBeard()) .. " / " .. 28 .. " )"
end

function SkinEditor:getBeardOpacityLabel()
  return "Beard Opacity ( " .. (self.skin:getBeardOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBeardColor1Label()
  return "Beard Color 1 ( " .. (self.skin:getBeardColor1()) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getBeardColor2Label()
  return "Beard Color 2 ( " .. (self.skin:getBeardColor2()) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getMakeupLabel()
  return "Makeup ( " .. (self.skin:getMakeup()) .. " / " .. 74 .. " )"
end

function SkinEditor:getMakeupOpacityLabel()
  return "Makeup Opacity ( " .. (self.skin:getMakeupOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getLipstickLabel()
  return "Lipstick ( " .. (self.skin:getLipstick()) .. " / " .. 9 .. " )"
end

function SkinEditor:getLipstickOpacityLabel()
  return "Lipstick Opacity ( " .. (self.skin:getLipstickOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getLipstickColorLabel()
  return "Lipstick Color ( " .. (self.skin:getLipstickColor()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getAgingLabel()
  return "Aging ( " .. (self.skin:getAging()) .. " / " .. 14 .. " )"
end

function SkinEditor:getAgingOpacityLabel()
  return "Aging Opacity ( " .. (self.skin:getAgingOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getChestHairLabel()
  return "Chest Hair ( " .. (self.skin:getChestHair()) .. " / " .. 16 .. " )"
end

function SkinEditor:getChestHairOpacityLabel()
  return "Chest Hair Opacity ( " .. (self.skin:getChestHairOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getChestHairColorLabel()
  return "Chest Hair Color ( " .. (self.skin:getChestHairColor()) .. " / " .. GetNumHairColors() .. " )"
end

function SkinEditor:getSunDamageLabel()
  return "Sun Damage ( " .. (self.skin:getSunDamage()) .. " / " .. 10 .. " )"
end

function SkinEditor:getSunDamageOpacityLabel()
  return "Sun Damage Opacity ( " .. (self.skin:getSunDamageOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getBodyBlemishesLabel()
  return "Body Blemishes ( " .. (self.skin:getBodyBlemishes()) .. " / " .. 11 .. " )"
end

function SkinEditor:getBodyBlemishesOpacityLabel()
  return "Body Blemishes Opacity ( " .. (self.skin:getBodyBlemishesOpacity()) .. " / " .. 1.0 .. " )"
end

function SkinEditor:getMoreBodyBlemishesLabel()
  return "More Body Blemishes ( " .. (self.skin:getMoreBodyBlemishes()) .. " / " .. 1 .. " )"
end

function SkinEditor:getMoreBodyBlemishesOpacityLabel()
  return "More Body Blemishes Opacity ( " .. (self.skin:getMoreBodyBlemishesOpacity()) .. " / " .. 1.0 .. " )"
end

-- -- TODO: refactor this so split into either a different class or another file
function SkinEditor:openComponentMenu(comp)

  self:ensurePed()

  local cfg = Config.componentsConfig[comp]

  camera.setRadius(cfg.radius)
  
  camera.pointToBone(cfg.bone, cfg.offset)

  local items = {}
  local label = cfg.label

  items[#items + 1] = {
    name  = 'drawable',
    label = self:getComponentDrawableLabel(comp),
    type  = 'slider',
    max   = GetNumberOfPedDrawableVariations(self._ped, comp) - 1,
    value = self.skin:getComponent(comp)[1],
  }

  items[#items + 1] = {
    name  = 'texture',
    label = self:getComponentTextureLabel(comp),
    type  = 'slider',
    min   = 0,
    max   = GetNumberOfPedTextureVariations(self._ped, comp, self.skin:getComponent(comp)[1]) - 1,
    value = self.skin:getComponent(comp)[2],
  }

  items[#items + 1] = {name = 'submit', label = '>> apply <<', type = 'button'}
  
  if self.clothesMenu.visible then
    self.clothesMenu:hide()
  end

  local menu = Menu('skin.component.' .. GetEnumKey(PED_COMPONENTS, comp), {
    title = label,
    float = 'top|left', -- not needed, default value
    items = items
  })

  self.currentMenu = menu

  menu:on('destroy', function()
    self.clothesMenu:show()
  end)

  menu:on('item.change', function(item, prop, val, index)

    if prop == 'value' then

      local byName = menu:by('name')

      if item.name == 'drawable' then
        self.skin:setComponentDrawable(comp, val)
        self.skin:setComponentTexture(comp, 0)

        byName['drawable'].label = self:getComponentDrawableLabel(comp, val)
        byName['texture'].max    = GetNumberOfPedTextureVariations(self._ped, comp, val)
        byName['texture'].value  = 0

      elseif item.name == 'texture' then
        self.skin:setComponentTexture(comp, val)
      end

      byName['texture'].label = self:getComponentTextureLabel(comp)

      self.skin:commit()
    end

  end)

  menu:on('item.click', function(item, index)
    
    if item.name == 'submit' then
      
      menu:destroy()
      
      self.currentMenu = self.clothesMenu

      self.clothesMenu:focus()
      self:mainCameraScene()
    end

  end)

end

function SkinEditor:mainCameraScene()
  local ped       = GetPlayerPed(-1)
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  camera.setRadius(2.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  camera.pointToBone(SKEL_Head, vector3(0.0,0.0,0.0))
end

function SkinEditor:getModelLabelByIndex(value)
  return 'Model (' .. PED_MODELS_BY_HASH[self.models[value + 1]] .. ')'
end

function SkinEditor:saveFromMenu()
  if not IsScreenFadedOut() and module.openedMenu then
    emit('esx:identity:preventSaving', false)
    module.openedMenu = false
    self:fade()

    while not IsScreenFadedOut() do
      Citizen.Wait(0)
    end
  end

  request('skin:save', function()
    self:destructor()
  end, self.skin:serialize())

  self:returnPlayer()
end

function SkinEditor:save()
  request('skin:save', function()
    self:destructor()
  end, self.skin:serialize())
end

function SkinEditor:fade()
  DoScreenFadeOut(1000)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end
end

function SkinEditor:returnPlayer()
  SetEntityCoords(PlayerPedId(), -269.4, -955.3, 31.2, 0.0, 0.0, 0.0, true)
  SetEntityHeading(PlayerPedId(), 205.8)

  Citizen.Wait(1000)

  DoScreenFadeIn(1000)
end

function SkinEditor:destroyMenu()
  self.mainMenu:destroy()
  self.mainMenu = nil
end

module.init = function()
  -- check if the player already has a skin
  request("skin:getIdentitySkin", function(skinContent)
    if skinContent == nil then
      module.askOpenEditor()
    else
      module.loadPlayerSkin(skinContent)
    end
  end)
end

module.loadPlayerSkin = function(skinContent, cb)
  if (skinContent == nil) then
    return request("skin:getIdentitySkin", function(skinContent)
      if (skinContent == nil) then
        error("Cannot load player skin when the skin isn't created yet")
      end
      module.loadPlayerSkin(skinContent, cb)
    end)
  end

  local skin = Skin(skinContent)
  skin:applyAll(cb)
end

-- skinContent might be nil
module.askOpenEditor = function(skinContent)
  local editor = SkinEditor(skinContent)
  editor:start()
end