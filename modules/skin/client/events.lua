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

M('ui.menu')

on('esx:onPlayerSpawn', function()

	Citizen.CreateThread(function()

    while not ESX.PlayerLoaded do
			Citizen.Wait(100)
		end

		if self.firstSpawn then
			request('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin == nil then
					TriggerEvent('skinchanger:loadSkin', {sex = 0}, OpenSaveableMenu)
				else
					TriggerEvent('skinchanger:loadSkin', skin)
				end
			end)

      self.firstSpawn = false

		end
  end)

end)

on('esx_skin:getLastSkin', function(cb)
	cb(self.lastSkin)
end)

on('esx_skin:setLastSkin', function(skin)
	self.lastSkin = skin
end)

onServer('esx_skin:openMenu', function(submitCb, cancelCb)
	self.OpenMenu(submitCb, cancelCb, nil)
end)

onServer('esx_skin:openRestrictedMenu', function(submitCb, cancelCb, restrict)
	self.OpenMenu(submitCb, cancelCb, restrict)
end)

onServer('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
	self.OpenSaveableMenu(submitCb, cancelCb, nil)
end)

onServer('esx_skin:openSaveableRestrictedMenu', function(submitCb, cancelCb, restrict)
	self.OpenSaveableMenu(submitCb, cancelCb, restrict)
end)

onServer('esx_skin:requestSaveSkin', function()
	TriggerEvent('skinchanger:getSkin', function(skin)
		TriggerServerEvent('esx_skin:responseSaveSkin', skin)
	end)
end)
