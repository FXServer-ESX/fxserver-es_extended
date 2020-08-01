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

onClient('esx_sit:takePlace', function(objectCoords)
  module.seatsTaken[objectCoords] = true
end)

onClient('esx_sit:leavePlace', function(objectCoords)
  if module.seatsTaken[objectCoords] then
    module.seatsTaken[objectCoords] = nil
  end
end)

onRequest('esx_sit:getPlace', function(source, cb, objectCoords)
  cb(module.seatsTaken[objectCoords])
end)
