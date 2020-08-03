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

M("identity")
local camera = M("camera")

onServer('esx:character:request:register', function()
  module.RequestRegister()
end)

onServer('esx:character:request:select', function(identities)
  if identities then
    local instancedIdentities = table.map(identities, function(identity)
      return Identity(identity)
    end)

    module.RequestIdentitySelection(instancedIdentities)
  else
    module.RequestIdentitySelection()
  end
end)

on('ui.menu.mouseChange', function(value)
	if module.AreMenuInUse() then
		camera.setMouseIn(value)
	end
end)
