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

self.lastSkin       = nil
self.playerLoaded   = false
self.cam            = nil
self.Menu           = nil
self.isCameraActive = false
self.firstSpawn     = true
self.zoomOffset     = 1.5
self.camOffsetX     = 0.0
self.camOffsetY     = 1.2
self.camOffsetZ     = 0.8
self.camPointOffset = 0.2
self.heading        = 90.0
self.angle          = 0.0

self.Init = function()
	local translations =
		ESX.EvalFile(GetCurrentResourceName(), "modules/skin/data/locales/" .. Config.Locale .. ".lua")["Translations"]
	LoadLocale("skin", Config.Locale, translations)
end

self.OpenMenu = function(submitCb, cancelCb, restrict)
	local playerPed = PlayerPedId()

	TriggerEvent(
		"skinchanger:getSkin",
		function(skin)
			self.lastSkin = skin
		end
	)

	TriggerEvent(
		"skinchanger:getData",
		function(components, maxVals)
			local elements = {}
			local _components = {}

			-- Restrict menu
			if restrict == nil then
				for i = 1, #components, 1 do
					_components[i] = components[i]
				end
			else
				for i = 1, #components, 1 do
					local found = false

					for j = 1, #restrict, 1 do
						if components[i].name == restrict[j] then
							found = true
						end
					end

					if found then
						table.insert(_components, components[i])
					end
				end
			end

			-- Insert elements
			for i = 1, #_components, 1 do
				local value = _components[i].value
				local componentId = _components[i].componentId

				if componentId == 0 then
					value = GetPedPropIndex(playerPed, _components[i].componentId)
				end

				local data = {
					label = _components[i].label,
					name = _components[i].name,
					value = value,
					min = _components[i].min,
					textureof = _components[i].textureof,
					zoomOffset = _components[i].zoomOffset,
					camOffset = _components[i].camOffset,
					type = "slider"
				}

				for k, v in pairs(maxVals) do
					if k == _components[i].name then
						data.max = v
						break
					end
				end

				table.insert(elements, data)
			end

			table.insert(
				elements,
				{
					name = "submit",
					label = "Submit",
					type = "button"
				}
			)

			self.CreateSkinCam()
			self.zoomOffset = _components[1].zoomOffset
			self.camOffset = _components[1].camOffset

			self.Menu =
				Menu:create(
				"skin",
				{
					title = _U("skin:skin_menu"),
					items = elements
				}
			)

			-- 	function(data, menu)
			-- 		TriggerEvent(
			-- 			"skinchanger:getSkin",
			-- 			function(skin)
			-- 				self.lastSkin = skin
			-- 			end
			-- 		)

			-- 		submitCb(data, menu)
			-- 		DeleteSkinCam()
			-- 	end,
			-- 	function(data, menu)
			-- 		menu.close()
			-- 		self.DeleteSkinCam()
			-- 		TriggerEvent("skinchanger:loadSkin", lastSkin)

			-- 		if cancelCb ~= nil then
			-- 			cancelCb(data, menu)
			-- 		end
			-- 	end,
			-- 	function(data, menu)
			-- 		local skin, components, maxVals

			-- 		TriggerEvent(
			-- 			"skinchanger:getSkin",
			-- 			function(getSkin)
			-- 				skin = getSkin
			-- 			end
			-- 		)

			-- 		zoomOffset = data.current.zoomOffset
			-- 		camOffset = data.current.camOffset

			-- 		if skin[data.current.name] ~= data.current.value then
			-- 			-- Change skin element
			-- 			TriggerEvent("skinchanger:change", data.current.name, data.current.value)

			-- 			-- Update max values
			-- 			TriggerEvent(
			-- 				"skinchanger:getData",
			-- 				function(comp, max)
			-- 					components, maxVals = comp, max
			-- 				end
			-- 			)

			-- 			local newData = {}

			-- 			for i = 1, #elements, 1 do
			-- 				newData = {}
			-- 				newData.max = maxVals[elements[i].name]

			-- 				if elements[i].textureof ~= nil and data.current.name == elements[i].textureof then
			-- 					newData.value = 0
			-- 				end

			-- 				menu.update({name = elements[i].name}, newData)
			-- 			end

			-- 			menu.refresh()
			-- 		end
			-- 	end,
			-- 	function(data, menu)
			-- 		self.DeleteSkinCam()
			-- 	end
			-- )

			self.Menu:on(
				"item.change",
				function(item, prop, val, index)
					TriggerEvent("skinchanger:change", item.name, item.value)
				end
			)

			self.Menu:on(
				"item.click",
				function(item, index)
					if item.name == "submit" then
						local props = self.Menu:kvp()

						print(json.encode(props))

						self.Menu:destroy()
						self.Menu = nil
						self.DeleteSkinCam()

						utils.ui.showNotification(_U('skin:skin_saved'))

						TriggerServerEvent("esx_skin:save", props)
					end
				end
			)
		end
	)
end

self.CreateSkinCam = function()
	local playerPed = PlayerPedId()
	
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(self.cam, false)

	if not DoesCamExist(self.cam) then
		self.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(self.cam, true)
		RenderScriptCams(true,  false, 500,  true, true)
		self.isCameraActive = true
		SetEntityHeading(playerPed, 0.0)
		SetCamRot(self.cam, 0.0, 0.0, 270.0, 2)
	end
end

self.DeleteSkinCam = function()
	self.isCameraActive = false
	SetCamActive(self.cam, false)
	RenderScriptCams(false, true, 500, true, true)
	self.cam = nil
end

self.OpenSaveableMenu = function(submitCb, cancelCb, restrict)
	TriggerEvent(
		"skinchanger:getSkin",
		function(skin)
			lastSkin = skin
		end
	)

	self.OpenMenu(
		function(data, menu)
			menu.close()
			self.DeleteSkinCam()

			TriggerEvent(
				"skinchanger:getSkin",
				function(skin)
					TriggerServerEvent("esx_skin:save", skin)

					if submitCb ~= nil then
						submitCb(data, menu)
					end
				end
			)
		end,
		cancelCb,
		restrict
	)
end
