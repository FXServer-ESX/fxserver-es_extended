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

local utils = M("utils")

module.camIsActive         = false
module.camRadius           = 1.25
module.camCoords           = vector3(0.0, 0.0, 0.0)
module.camPolarAngle       = 0.0
module.camAzimuthAngle     = 0.0
module.camTargetBone       = SKEL_ROOT
module.camTargetBoneOffset = vector3(0.0, 0.0, 0.0)
module.timestamp           = utils.time.timestamp()
module.shouldMoveCam       = true
module.cameraId            = nil
module.tick                = nil

-- TODO: split this into multiple pieces
-- and make it re-usable (extends camera so it could be use for anything)
module.start = function()
  module.onMouseMoveOffest = on('mouse:move:offset', function(offsetX, offsetY, data)

    -- Mouse not inside menu
    if module.checkShouldMoveCam() then
      
      if data.down[0] then

        module.camPolarAngle   = module.camPolarAngle   + offsetX / 5.0;
        module.camAzimuthAngle = module.camAzimuthAngle + offsetY / 5.0;

        module.camPolarAngle = module.camPolarAngle % 360

        if module.camAzimuthAngle >= 180 then
          module.camAzimuthAngle = 180;
        elseif module.camAzimuthAngle <= 0 then
          module.camAzimuthAngle = 0;
        end

      elseif data.down[2] then

        if data.direction.right then
          module.timestamp = module.timestamp + 250
        elseif data.direction.left then
          module.timestamp = module.timestamp - 250
        end

      end

    end

  end)

  module.onMouseWheel = on('mouse:wheel', function(delta)

    if module.checkShouldMoveCam() then

      module.camRadius = module.camRadius + delta * -0.25
      
      if module.camRadius < 0.75 then
        module.camRadius = 0.75
      elseif module.camRadius > 2.5 then
        module.camRadius = 2.5
      end

    end

  end)

  local ped = GetPlayerPed(-1)
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  module.camRadius                           = 1.25
  module.camCoords                           = pedCoords + forward * module.camRadius
  module.camPolarAngle, module.camAzimuthAngle = utils.math.world3DtoPolar3D(pedCoords, module.camCoords)

  if not DoesCamExist(module.cameraId) then
    module.cameraId = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
  end

  SetCamActive(module.cameraId, true)
  RenderScriptCams(true, false, 500, true, true)

  SetCamCoord(module.cameraId, module.camCoords.x, module.camCoords.y, module.camCoords.z)

  module.camIsActive = true

  emit('cam.enable')

  module.tick = ESX.SetTick(function()
    module.onTick()
  end)
end

module.stop = function()
  SetCamActive(module.cameraId, false)
  RenderScriptCams(false, true, 500, true, true)

  module.camIsActive = false

  emit('cam.disable')
end

module.destroy = function()

  module.stop()

  off('mouse:move:offset', module.onMouseMoveOffest)
  off('mouse:move:wheel',  module.onMouseWheel)

  ESX.ClearTick(module.tick)

  DestroyCam(module.cameraId, false)
  module.cameraId = nil

  emit('destoyed')
end

module.pointToBone = function(boneIndex, offset)
  module.camTargetBone       = boneIndex
  module.camTargetBoneOffset = offset or vector3(0.0, 0.0, 0.0)

  PointCamAtPedBone(module.cameraId, GetPlayerPed(-1), module.camTargetBone, module.camTargetBoneOffset.x, module.camTargetBoneOffset, module.camTargetBoneOffset.z, 0)
end

module.onTick = function()
  local coords = GetPedBoneCoords(GetPlayerPed(-1), module.camTargetBone, module.camTargetBoneOffset.x, module.camTargetBoneOffset.y, module.camTargetBoneOffset.z)

  module.camCoords = utils.math.polar3DToWorld3D(coords, module.camPolarAngle, module.camAzimuthAngle, module.camRadius)

  SetCamCoord(module.cameraId, module.camCoords.x, module.camCoords.y, module.camCoords.z)

  -- time
  local w, d, h, m, s = utils.time.fromTimestamp(module.timestamp)
  NetworkOverrideClockTime(h, m, s)
end

module.setRadius = function(radius)
  module.camRadius = radius
end

module.setCoords = function(coords)
  module.camCoords = coords
end

module.setPolarAzimuthAngle = function(polarAngle, azimuthAngle)
  module.camPolarAngle = polarAngle
  module.camAzimuthAngle = azimuthAngle
end

module.resetCamera = function()
  local ped       = GetPlayerPed(-1)
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  module.setRadius(2.25)
  module.setCoords(pedCoords + forward * 1.25)
  module.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  module.pointToBone(SKEL_Head, vector3(0.0,0.0,0.0))
end

module.setMouseIn = function(value)
  if value == true then
    module.shouldMoveCam = false
  else
    module.shouldMoveCam = true
  end
end

module.checkShouldMoveCam = function()
  return module.shouldMoveCam
end

module.moduleLoaded = true
