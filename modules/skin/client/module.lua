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
M("ui.menu")
M("table")

self.lastSkin = nil
self.playerLoaded = false
self.cam = nil
self.isCameraActive = false

self.firstSpawn = true
self.zoomOffset = 1.5
self.camOffsetX = 0.0
self.camOffsetY = 1.2
self.camOffsetZ = 0.8
self.camPointOffset = 0.2
self.heading = 90.0
self.angle = 0.0

self.Init = function()
	local translations =
		ESX.EvalFile(GetCurrentResourceName(), "modules/skin/data/locales/" .. Config.Locale .. ".lua")["Translations"]
	LoadLocale("skin", Config.Locale, translations)
end

self.OpenMenu = function(submitCb, cancelCb, restrict)
	local playerPed = PlayerPedId()

	local props = {}
	local body = {}
	local clothes = {}

	local bodymenuelements = {}
	local clothesmenuelements = {}

	local bodyparts = {
		"sex",
		"face",
		"hair_1",
		"hair_2",
		"hair_color_1",
		"hair_color_2",
		"eye_color",
		"skin",
		"eyebrows_2",
		"eyebrows_1",
		"eyebrows_3",
		"eyebrows_4",
		"makeup_1",
		"makeup_2",
		"makeup_3",
		"makeup_4",
		"lipstick_1",
		"lipstick_2",
		"lipstick_3",
		"lipstick_4",
		"chest_1",
		"chest_2",
		"chest_3",
		"bodyb_1",
		"bodyb_2",
		"age_1",
		"age_2",
		"blemishes_1",
		"blemishes_2",
		"blush_1",
		"blush_2",
		"blush_3",
		"complexion_1",
		"complexion_2",
		"sun_1",
		"sun_2",
		"moles_1",
		"moles_2",
		"beard_1",
		"beard_2",
		"beard_3",
		"beard_4"
	}

	table.insert(
		bodymenuelements,
		1,
		{
			name = "back",
			label = _U("skin:skin_back"),
			type = "button"
		}
	)
	table.insert(
		clothesmenuelements,
		1,
		{
			name = "back",
			label = _U("skin:skin_back"),
			type = "button"
		}
	)

	TriggerEvent(
		"skinchanger:getSkin",
		function(skin)
			self.lastSkin = skin
		end
	)

	TriggerEvent(
		"skinchanger:getData",
		function(components, maxVals)
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

				local found = false
				if found == false then
					for _, v in ipairs(bodyparts) do
						if v == data.name then
							found = true
							table.insert(bodymenuelements, data)
							break
						end
					end
				end
				if found == false then
					table.insert(clothesmenuelements, data)
				end
			end

			self.CreateSkinCam()
			self.zoomOffset = _components[1].zoomOffset
			self.camOffset = _components[1].camOffset
		end
	)

	function createMainMenu()
		local menu =
			Menu:create(
			"principalmenu",
			{
				title = _U("skin:skin_menu"),
				float = "top|left",
				items = {
					{name = "body", label = _U("skin:skin_body"), type = "button"},
					{name = "clothes", label = _U("skin:skin_clothes"), type = "button"},
					{name = "submit", label = _U("skin:skin_submit"), type = "button"}
				}
			}
		)

		menu:on(
			"item.click",
			function(item, index)
				if item.name == "body" then
					menu:destroy()
					menu = nil

					createBodySubmenu()
				elseif item.name == "clothes" then
					menu:destroy()
					menu = nil

					createClothesSubmenu()
				elseif item.name == "submit" then
					if next(body) == nil then
						-- print("body false")
					elseif next(clothes) == nil then
						-- print("clothes false")
					else
						table.merge(props, body)
						table.merge(props, clothes)

						-- print(json.encode(props))
						menu:destroy()
						menu = nil
						self.DeleteSkinCam()

						TriggerServerEvent("esx_skin:save", props)
					end
				end
			end
		)
	end

	function createBodySubmenu()
		local menu =
			Menu:create(
			"bodymenu",
			{
				title = _U("skin:skinbody_menu"),
				float = "top|left",
				items = bodymenuelements
			}
		)

		menu:on(
			"item.change",
			function(item, prop, val, index)
				TriggerEvent("skinchanger:change", item.name, item.value)
			end
		)

		menu:on(
			"item.click",
			function(item, index)
				if item.name == "back" then
					body = menu:kvp()

					menu:destroy()
					menu = nil

					createMainMenu()
				end
			end
		)
	end

	function createClothesSubmenu()
		local menu =
			Menu:create(
			"bodymenu",
			{
				title = _U("skin:skinclothes_menu"),
				float = "top|left",
				items = clothesmenuelements
			}
		)

		menu:on(
			"item.change",
			function(item, prop, val, index)
				TriggerEvent("skinchanger:change", item.name, item.value)
			end
		)

		menu:on(
			"item.click",
			function(item, index)
				if item.name == "back" then
					clothes = menu:kvp()
					-- print(json.encode(head))

					menu:destroy()
					menu = nil

					createMainMenu()
				end
			end
		)
	end

	createMainMenu()
end

self.CreateSkinCam = function()
	local playerPed = PlayerPedId()

	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(self.cam, false)

	if not DoesCamExist(self.cam) then
		self.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(self.cam, true)
		RenderScriptCams(true, false, 500, true, true)
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
