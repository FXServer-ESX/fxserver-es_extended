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

local HUD    = M('game.hud')
local utils  = M("utils")
local camera = M("camera")

module.enableVehicleStats             = true
module.drawDistance                   = 30
module.plateLetters                   = 3
module.plateNumbers                   = 3
module.plateUseSpace                  = true
module.resellPercentage               = 50
module.numberCharset                  = {}
module.charset                        = {}

module.xoffset                        = 0.6
module.yoffset                        = 0.122
module.windowSizeX                    = 0.25
module.windowSizY                     = 0.15
module.statSizeX                      = 0.24
module.statSizeY                      = 0.01
module.statOffsetX                    = 0.55
module.fastestVehicleSpeed            = 200

module.currentDisplayVehicle          = nil
module.hasAlreadyEnteredMarker        = false
module.isInShopMenu                   = false
module.letSleep                       = nil
module.currentDisplayVehicle          = nil
module.currentVehicleData             = nil
module.currentMenu                    = nil
module.vehicle                        = nil
module.vehicleData                    = nil

module.selectedCCVehicle              = module.selectedCCVehicle or 1
module.selectedCSVehicle              = module.selectedCSVehicle or 1
module.selectedSportsVehicle          = module.selectedSportsVehicle or 1
module.selectedSports2Vehicle         = module.selectedSports2Vehicle or 1
module.selectedSports3Vehicle         = module.selectedSports3Vehicle or 1
module.selectedSportsClassicsVehicle  = module.selectedSportsClassicsVehicle or 1
module.selectedSPortsClassics2Vehicle = module.selectedSportsClassics2Vehicle or 1
module.selectedSuperVehicle           = module.selectedSuperVehicle or 1
module.selectedSuper2Vehicle          = module.selectedSuper2Vehicle or 1
module.selectedMuscleVehicle          = module.selectedMuscleVehicle or 1
module.selectedMuscle2Vehicle         = module.selectedMuscle2Vehicle or 1
module.selectedOffroadVehicle         = module.selectedOffroadVehicle or 1
module.selectedSUVsVehicle            = module.selectedSUVsVehicle or 1
module.selectedVansVehicle            = module.selectedVansVehicle or 1
module.selectedMotorcyclesVehicle     = module.selectedMotorcyclesVehicle or 1
module.selectedMotorcycles2Vehicle    = module.selectedMotorcycles2Vehicle or 1
module.selectedMotorcycles3Vehicle    = module.selectedMotorcycles3Vehicle or 1

module.zones = {
	shopBuy = {
		pos   = vector3(-57.45989, -1096.654, 25.45),
		size  = {x = 2.0, y = 2.0, z = 1.0},
		type  = 27,
		markerColor = {r = 0, g = 255, b = 0}
	},
	shopSell  = {
		pos   = vector3(-42.08379, -1115.916, 25.5),
		size  = {x = 3.0, y = 3.0, z = 1.5},
		type  = 27,
		markerColor = {r = 255, g = 0, b = 0}
	}
}

module.shopInside               = {
	pos     = vector3(-47.5, -1097.2, 25.4),
	heading = -20.0
}

module.shopOutside               = {
	pos     = vector3(-33.50243, -1079.901, 26.3878),
	heading = 69.750938415527
}

for i = 48, 57 do
	table.insert(module.numberCharset, string.char(i))
end

for i = 65, 90 do
	table.insert(module.charset, string.char(i))
end

for i = 97, 122 do
	table.insert(module.charset, string.char(i))
end

module.Init = function()
	Citizen.CreateThread(function()
		local blip = AddBlipForCoord(module.zones.shopBuy.pos)
	
		SetBlipSprite (blip, 326)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.75)
		SetBlipAsShortRange(blip, true)
	
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName("Car Dealer")
		EndTextCommandSetBlipName(blip)
		SetBlipColour (blip,11)
	end)

	request("vehicleshop:storeAllVehicles", function(result)

	end)

	request("vehicleshop:getCategories", function(categories)
		module.categories = categories
	end)

	request("vehicleshop:getCompactsCoupes", function(cc)
		module.cc = cc
	end)

	request("vehicleshop:getCoupesSedans", function(cs)
		module.cs = cs
	end)

	request("vehicleshop:getSports", function(sports)
		module.sports = sports
	end)

	request("vehicleshop:getSports2", function(sports2)
		module.sports2 = sports2
	end)

	request("vehicleshop:getSports3", function(sports3)
		module.sports3 = sports3
	end)

	request("vehicleshop:getSportsClassics", function(sportsclassics)
		module.sportsclassics = sportsclassics
	end)

	request("vehicleshop:getSportsClassics2", function(sportsclassics2)
		module.sportsclassics2 = sportsclassics2
	end)

	request("vehicleshop:getSuper", function(super)
		module.super = super
	end)

	request("vehicleshop:getSuper2", function(super2)
		module.super2 = super2
	end)

	request("vehicleshop:getMuscle", function(muscle)
		module.muscle = muscle
	end)

	request("vehicleshop:getMuscle2", function(muscle2)
		module.muscle2 = muscle2
	end)

	request("vehicleshop:getOffroad", function(offroad)
		module.offroad = offroad
	end)

	request("vehicleshop:getSUVs", function(suvs)
		module.suvs = suvs
	end)

	request("vehicleshop:getVans", function(vans)
		module.vans = vans
	end)

	request("vehicleshop:getMotorcycles", function(motorcycles)
		module.motorocycles = motorcycles
	end)

	request("vehicleshop:getMotorcycles2", function(motorcycles2)
		module.motorocycles2 = motorcycles2
	end)

	request("vehicleshop:getMotorcycles3", function(motorcycles3)
		module.motorocycles3 = motorcycles3
	end)

	request("vehicleshop:getSellableVehicles", function(sellableVehicles)
		module.sellableVehicles = sellableVehicles
	end)
end

-----------------------------------------------------------------------------------
-- Shop Menu Functions
-----------------------------------------------------------------------------------

module.DestroyShopMenu = function()
	module.shopMenu:destroy()
end

module.OpenShopMenu = function()

	module.EnterShop()

	Citizen.Wait(500)

	camera.setPolarAzimuthAngle(250.0, 120.0)
	camera.setRadius(3.5)
	emit('esx:identity:preventSaving', true)

	DoScreenFadeIn(250)

	local items = {}

	for i=1, #module.categories, 1 do
  
	  local category = module.categories[i].name
	  local label    = module.categories[i].label
  
	  items[#items + 1] = {type= 'button', name = category, label = label}
  
	end

	items[#items + 1] = {type= 'button', name = 'exit', label = ">> Exit <<"}

	module.shopMenu = Menu('vehicleshop.main', {
		title = 'Vehicle Shop',
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.shopMenu

	module.shopMenu:on('item.click', function(item, index)
		if item.name == 'cc' then
			module.OpenCompactsCoupesMenu()
		elseif item.name == 'cs' then
			module.OpenCoupesSedansMenu()
		elseif item.name == 'sports' then
			module.OpenSportsMenu()
		elseif item.name == 'sports2' then
			module.OpenSports2Menu()
		elseif item.name == 'sports3' then
			module.OpenSports3Menu()
		elseif item.name == 'sportsclassics' then
			module.OpenSportsClassicsMenu()
		elseif item.name == 'sportsclassics2' then
			module.OpenSportsClassics2Menu()
		elseif item.name == 'super' then
			module.OpenSuperMenu()
		elseif item.name == 'super2' then
			module.OpenSuper2Menu()
		elseif item.name == 'muscle' then
			module.OpenMuscleMenu()
		elseif item.name == 'muscle2' then
			module.OpenMuscle2Menu()
		elseif item.name == 'offroad' then
			module.OpenOffroadMenu()
		elseif item.name == 'suvs' then
			module.OpenSUVsMenu()
		elseif item.name == 'vans' then
			module.OpenVansMenu()
		elseif item.name == 'motorcycles' then
			module.OpenMotorcyclesMenu()
		elseif item.name == 'motorcycles2' then
			module.OpenMotorcycles2Menu()
		elseif item.name == 'motorcycles3' then
			module.OpenMotorcycles3Menu()
		elseif item.name == 'exit' then
			module.DestroyShopMenu()
			DoScreenFadeOut(250)

			while not IsScreenFadedOut() do
			  Citizen.Wait(0)
			end

			module.ExitShop()
		end
	end)
end

on('ui.menu.mouseChange', function(value)
	if module.isInShopMenu then
		camera.setMouseIn(value)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if module.IsInShopMenu then
			if module.currentMenu then
				if module.currentMenu.mouseIn then
					print(true)
					camera.setMouseIn(true)
				else
					camera.setMouseIn(false)
				end
			end
		end
	end
end)

-----------------------------------------------------------------------------------
-- Shop Sub-Menu Functions
-----------------------------------------------------------------------------------

module.OpenCompactsCoupesMenu = function()	
	local items = {}
	local count = 0

	for i=1, #module.cc, 1 do
		count = count + 1

		local model = module.cc[i].model
		local label = module.cc[i].name .. " - $" .. module.GroupDigits(module.cc[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.ccMenu = Menu('vehicleshop.compacts', {
		title = "Compacts/Coupes",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.ccMenu

	module.ccMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.ccMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.ccMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedCCVehicle(item.value)
			module.commit(module.cc, item.value)
		end
    end)
end

module.OpenCoupesSedansMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.cs, 1 do
		count = count + 1

		local model = module.cs[i].model
		local label = module.cs[i].name .. " - $" .. module.GroupDigits(module.cs[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.csMenu = Menu('vehicleshop.coupes', {
		title = "Coupes/Sedans",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.csMenu

	module.csMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.csMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.csMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedCSVehicle(item.value)
			module.commit(module.cs, item.value)
		end
	end)
end

module.OpenSportsMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.sports, 1 do
		count = count + 1

		local model = module.sports[i].model
		local label = module.sports[i].name .. " - $" .. module.GroupDigits(module.sports[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.sportsMenu = Menu('vehicleshop.sports', {
		title = "Sports",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.sportsMenu

	module.sportsMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.sportsMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.sportsMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSportsVehicle(item.value)
			module.commit(module.sports, item.value)
		end
	end)
end

module.OpenSports2Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.sports2, 1 do
		count = count + 1

		local model = module.sports2[i].model
		local label = module.sports2[i].name .. " - $" .. module.GroupDigits(module.sports2[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.sports2Menu = Menu('vehicleshop.sports', {
		title = "Sports 2",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.sports2Menu

	module.sports2Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.sports2Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.sports2Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSports2Vehicle(item.value)
			module.commit(module.sports2, item.value)
		end
	end)
end

module.OpenSports3Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.sports3, 1 do
		count = count + 1

		local model = module.sports3[i].model
		local label = module.sports3[i].name .. " - $" .. module.GroupDigits(module.sports3[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.sports3Menu = Menu('vehicleshop.sports', {
		title = "Sports 3",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.sports3Menu

	module.sports3Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.sports3Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.sports3Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSports3Vehicle(item.value)
			module.commit(module.sports3, item.value)
		end
	end)
end

module.OpenSportsClassicsMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.sportsclassics, 1 do
		count = count + 1

		local model = module.sportsclassics[i].model
		local label = module.sportsclassics[i].name .. " - $" .. module.GroupDigits(module.sportsclassics[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.sportsClassicsMenu = Menu('vehicleshop.sportsclassics', {
		title = "Sports Classics",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.sportsClassicsMenu

	module.sportsClassicsMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.sportsClassicsMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.sportsClassicsMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSportsClassicsVehicle(item.value)
			module.commit(module.sportsclassics, item.value)
		end
	end)
end

module.OpenSportsClassics2Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.sportsclassics2, 1 do
		count = count + 1

		local model = module.sportsclassics2[i].model
		local label = module.sportsclassics2[i].name .. " - $" .. module.GroupDigits(module.sportsclassics2[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.sportsClassics2Menu = Menu('vehicleshop.sportsclassics', {
		title = "Sports Classics 2",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.sportsClassics2Menu

	module.sportsClassics2Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.sportsClassics2Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.sportsClassics2Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSportsClassics2Vehicle(item.value)
			module.commit(module.sportsclassics2, item.value)
		end
	end)
end

module.OpenSuperMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.super, 1 do
  		count = count + 1
	
		local model = module.super[i].model
		local label = module.super[i].name .. " - $" .. module.GroupDigits(module.super[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.superMenu = Menu('vehicleshop.super', {
		title = "Super",
		float = 'top|left', -- not needed, default value
		items = items
	})
	
	module.currentMenu = module.superMenu

	module.superMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.superMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.superMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSuperVehicle(item.value)
			module.commit(module.super, item.value)
		end
	end)
end

module.OpenSuper2Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.super2, 1 do
  		count = count + 1
	
		local model = module.super2[i].model
		local label = module.super2[i].name .. " - $" .. module.GroupDigits(module.super2[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.super2Menu = Menu('vehicleshop.super', {
		title = "Super 2",
		float = 'top|left', -- not needed, default value
		items = items
	})
	
	module.currentMenu = module.super2Menu

	module.super2Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.super2Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.super2Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSuper2Vehicle(item.value)
			module.commit(module.super2, item.value)
		end
	end)
end

module.OpenMuscleMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.muscle, 1 do
		count = count + 1

		local model = module.muscle[i].model
		local label = module.muscle[i].name .. " - $" .. module.GroupDigits(module.muscle[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.muscleMenu = Menu('vehicleshop.muscle', {
		title = "Muscle",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.muscleMenu

	module.muscleMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.muscleMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.muscleMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedMuscleVehicle(item.value)
			module.commit(module.muscle, item.value)
		end
	end)
end

module.OpenMuscle2Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.muscle2, 1 do
		count = count + 1

		local model = module.muscle2[i].model
		local label = module.muscle2[i].name .. " - $" .. module.GroupDigits(module.muscle2[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.muscle2Menu = Menu('vehicleshop.muscle', {
		title = "Muscle 2",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.muscle2Menu

	module.muscle2Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.muscle2Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.muscle2Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedMuscle2Vehicle(item.value)
			module.commit(module.muscle2, item.value)
		end
	end)
end

module.OpenOffroadMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.offroad, 1 do
		count = count + 1

		local model = module.offroad[i].model
		local label = module.offroad[i].name .. " - $" .. module.GroupDigits(module.offroad[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.offroadMenu = Menu('vehicleshop.offroad', {
		title = "Offroad",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.offroadMenu

	module.offroadMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.offroadMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.offroadMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedOffroadVehicle(item.value)
			module.commit(module.offroad, item.value)
		end
	end)
end

module.OpenSUVsMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.suvs, 1 do
		count = count + 1

		local model = module.suvs[i].model
		local label = module.suvs[i].name .. " - $" .. module.GroupDigits(module.suvs[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.SUVsMenu = Menu('vehicleshop.suvs', {
		title = "SUVs",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.SUVsMenu

	module.SUVsMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.SUVsMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.SUVsMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedSUVsVehicle(item.value)
			module.commit(module.suvs, item.value)
		end
	end)
end

module.OpenVansMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.vans, 1 do
		count = count + 1

		local model = module.vans[i].model
		local label = module.vans[i].name .. " - $" .. module.GroupDigits(module.vans[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.vansMenu = Menu('vehicleshop.vans', {
		title = "Vans",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.vansMenu

	module.vansMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.vansMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.vansMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedVansVehicle(item.value)
			module.commit(module.vans, item.value)
		end
	end)
end

module.OpenMotorcyclesMenu = function()
	local items = {}
	local count = 0

	for i=1, #module.motorcycles, 1 do
		count = count + 1

		local model = module.motorcycles[i].model
		local label = module.motorcycles[i].name .. " - $" .. module.GroupDigits(module.motorcycles[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.motorcyclesMenu = Menu('vehicleshop.motorcycles', {
		title = "Motorcycles",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.motorcyclesMenu

	module.motorcyclesMenu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.motorcyclesMenu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.motorcyclesMenu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedMotorcyclesVehicle(item.value)
			module.commit(module.motorcycles, item.value)
		end
	end)
end

module.OpenMotorcycles2Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.motorcycles2, 1 do
		count = count + 1

		local model = module.motorcycles2[i].model
		local label = module.motorcycles2[i].name .. " - $" .. module.GroupDigits(module.motorcycles2[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.motorcycles2Menu = Menu('vehicleshop.motorcycles', {
		title = "Motorcycles 2",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.motorcycles2Menu

	module.motorcycles2Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.motorcycles2Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.motorcycles2Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
			
		else
			module.setSelectedMotorcycles2Vehicle(item.value)
			module.commit(module.motorcycles2, item.value)
		end
	end)
end

module.OpenMotorcycles3Menu = function()
	local items = {}
	local count = 0

	for i=1, #module.motorcycles3, 1 do
		count = count + 1

		local model = module.motorcycles3[i].model
		local label = module.motorcycles3[i].name .. " - $" .. module.GroupDigits(module.motorcycles3[i].price)

		items[#items + 1] = {type = 'button', name = model, label = label, value = count}
	end

	items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

	if module.shopMenu.visible then
		module.shopMenu:hide()
	end

	module.motorcycles3Menu = Menu('vehicleshop.motorcycles', {
		title = "Motorcycles 3",
		float = 'top|left', -- not needed, default value
		items = items
	})

	module.currentMenu = module.motorcycles3Menu

	module.motorcycles3Menu:on('destroy', function()
		module.shopMenu:show()
	end)

	module.motorcycles3Menu:on('item.click', function(item, index)
		if item.name == 'back' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil 

			module.motorcycles3Menu:destroy()

			module.currentMenu = module.shopMenu

			module.shopMenu:focus()
		else
			module.setSelectedMotorcycles3Vehicle(item.value)
			module.commit(module.motorcycles3, item.value)
		end
	end)
end

module.OpenBuyMenu = function(category, value, vehicle)
	local items = {}

	items[#items + 1] = {name = 'yes', label = '>> Yes <<', type = 'button', value = category[model]}
	items[#items + 1] = {name = 'no', label = '>> No <<', type = 'button'}

	module.lastMenu = module.currentMenu

	if module.lastMenu.visible then
		module.lastMenu:hide()
	end

	module.buyMenu = Menu('vehicleshop.buy', {
		title = "Buy " .. category[value].name .. " for $" .. module.GroupDigits(category[value].price) .. "?",
		float = 'top|left', -- not needed, default value
		items = items
	})
	
	module.currentMenu = module.buyMenu

	module.buyMenu:on('destroy', function()
		module.lastMenu:show()
	end)

	module.buyMenu:on('item.click', function(item, index)
		if item.name == 'no' then
			module.DeleteDisplayVehicleInsideShop()
			module.currentDisplayVehicle = nil

			module.buyMenu:destroy()

			module.currentMenu = module.lastMenu

			module.lastMenu:focus()
		elseif item.name == 'yes' then
			local generatedPlate = module.GeneratePlate()
			local buyPrice = category[value].price
			local formattedPrice = module.GroupDigits(category[value].price)
			local model = category[value].model
			local displaytext = GetDisplayNameFromVehicleModel(model)
			local name = GetLabelText(displaytext)
			local playerPed = PlayerPedId()

			request('vehicleshop:buyVehicle', function(result)
				if result then
					
					DoScreenFadeOut(250)

					while not IsScreenFadedOut() do
					  Citizen.Wait(0)
					end

					module.DeleteDisplayVehicleInsideShop()
					module.currentDisplayVehicle = nil
					module.buyMenu:destroy()
					module.lastMenu:destroy()
					module.ExitShop()
					camera.destroy()
					module.DestroyShopMenu()

					module.SpawnVehicle(model, module.shopOutside.pos, module.shopOutside.heading, function(vehicle)
						TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
						SetVehicleNumberPlateText(vehicle, generatedPlate)
						local vehicleProps = module.GetVehicleProperties(vehicle)
						emitServer('vehicleshop:updateVehicle', vehicleProps, generatedPlate)
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)
					end)

					Citizen.Wait(500)

					utils.ui.showNotification("You have bought a ~y~" .. name .. "~s~ with the plates ~b~" .. generatedPlate .. "~s~ for ~g~$" .. formattedPrice)

					DoScreenFadeIn(500)
				else
					module.DeleteDisplayVehicleInsideShop()
					module.currentDisplayVehicle = nil
				
					module.BuyMenu:destroy()
				
					module.currentMenu = module.lastMenu
				
					module.lastMenu:focus()
				end
			end, model, generatedPlate, buyPrice, formattedPrice)
		end
	end)
end

module.GetVehicleProperties = function(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}

		for extraId=0, 12 do
			if DoesExtraExist(vehicle, extraId) then
				local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
				extras[tostring(extraId)] = state
			end
		end

		return {
			model             = GetEntityModel(vehicle),

			plate             = module.Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = module.Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = module.Round(GetVehicleEngineHealth(vehicle), 1),
			tankHealth        = module.Round(GetVehiclePetrolTankHealth(vehicle), 1),

			fuelLevel         = module.Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = module.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),
			xenonColor        = GetVehicleXenonLightsColour(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleLivery(vehicle)
		}
	else
		return
	end
end

module.SpawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
  
	  Citizen.CreateThread(function()
		  module.RequestModel(model)
  
		  local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		  local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		  local timeout = 0
  
		  SetNetworkIdCanMigrate(networkId, true)
		  SetEntityAsMissionEntity(vehicle, true, false)
		  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		  SetVehicleNeedsToBeHotwired(vehicle, false)
		  SetVehRadioStation(vehicle, 'OFF')
		  SetModelAsNoLongerNeeded(model)
		  RequestCollisionAtCoord(coords.x, coords.y, coords.z)
  
		  -- we can get stuck here if any of the axies are "invalid"
		  while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			  Citizen.Wait(0)
			  timeout = timeout + 1
		  end
  
		  if cb then
			  cb(vehicle)
		  end
	end)
end


-----------------------------------------------------------------------------------
-- Vehicle Model Loading Functions
-----------------------------------------------------------------------------------

module.commit = function(category, value)
	local playerPed = PlayerPedId()

	module.DeleteDisplayVehicleInsideShop()

	module.WaitForVehicleToLoad(category[value].model)

	module.SpawnLocalVehicle(category[value].model, module.shopInside.pos, module.shopInside.heading, function(vehicle)
		module.currentDisplayVehicle = vehicle
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
		SetModelAsNoLongerNeeded(category[value].model)

		module.OpenBuyMenu(category, value, vehicle)
		module.vehicleLoaded = true
		if module.enableVehicleStats then
			module.showVehicleStats()
		end
	end)
end

module.RenderBox = function(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4)
end

module.DrawText = function(string, x, y)
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.5, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(2)
	SetTextEntry("STRING")
	AddTextComponentString(string)
	DrawText(x,y)
end

module.showVehicleStats = function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if module.vehicleLoaded then
				local playerPed = PlayerPedId()

				if IsPedSittingInAnyVehicle(playerPed) then
					local vehicle = GetVehiclePedIsIn(playerPed, false)

					if DoesEntityExist(vehicle) then
						local model            = GetEntityModel(vehicle, false)
						local hash             = GetHashKey(model)

						local topSpeed         = GetVehicleMaxSpeed(vehicle) * 3.6
						local acceleration     = GetVehicleModelAcceleration(model)
						local gears            = GetVehicleHighGear(vehicle)
						local capacity         = GetVehicleMaxNumberOfPassengers(vehicle) + 1

						local topSpeedStat     = (((topSpeed / module.fastestVehicleSpeed) / 2) * module.statSizeX)
						local accelerationStat = (((acceleration / 1.6) / 2) * module.statSizeX)
						local gearStat         = tostring(gears)
						local capacityStat     = tostring(capacity)

						if topSpeedStat > 0.24 then
							topSpeedStat = 0.24
						end

						if accelerationStat > 0.24 then
							accelerationStat = 0.24
						end
			
						module.RenderBox(module.xoffset - 0.05, module.windowSizeX, (module.yoffset - 0.0325), module.windowSizY, 0, 0, 0, 225)

						module.DrawText("Top Speed", module.xoffset - 0.146, module.yoffset - 0.105)
						module.RenderBox(module.statOffsetX, module.statSizeX, (module.yoffset - 0.07), module.statSizeY, 60, 60, 60, 225)
						module.RenderBox(module.statOffsetX - ((module.statSizeX - topSpeedStat) / 2), topSpeedStat, (module.yoffset - 0.07), module.statSizeY, 0, 255, 255, 225)

						module.DrawText("Acceleration", module.xoffset - 0.138, module.yoffset - 0.065)
						module.RenderBox(module.statOffsetX, module.statSizeX, (module.yoffset - 0.03), module.statSizeY, 60, 60, 60, 225)
						module.RenderBox(module.statOffsetX - ((module.statSizeX - (accelerationStat * 4)) / 2), accelerationStat * 4, (module.yoffset - 0.03), module.statSizeY, 0, 255, 255, 225)

						module.DrawText("Gears", module.xoffset - 0.1565, module.yoffset - 0.025)
						module.DrawText(gearStat, module.xoffset + 0.068, module.yoffset - 0.025)

						module.DrawText("Seating Capacity", module.xoffset - 0.1275, module.yoffset + 0.002)
						module.DrawText(capacityStat, module.xoffset + 0.068, module.yoffset + 0.002)
					end
				end
			else
				break
			end
		end
	end)
end

--------------------------------
-- CC
--------------------------------

module.setSelectedCCVehicle = function(val)
	module.selectedCCVehicle = val
	
	return module.selectedCCVehicle
end

module.getSelectedCCVehicle = function()
	return module.selectedCCVehicle
end

module.getSelectedCCVehicleLabel = function()
	return module.cc[module.selectedCCVehicle].name
end

--------------------------------
-- CS
--------------------------------

module.setSelectedCSVehicle = function(val)
	module.selectedCSVehicle = val
	
	return module.selectedCSVehicle
end

module.getSelectedCSVehicle = function()
	return module.selectedCSVehicle
end

module.getSelectedCSVehicleLabel = function()
	return module.cs[module.selectedCSVehicle].name
end

--------------------------------
-- Sports
--------------------------------

module.setSelectedSportsVehicle = function(val)
	module.selectedSportsVehicle = val
	
	return module.selectedSportsVehicle
end

module.getSelectedSportsVehicle = function()
	return module.selectedSportsVehicle
end

module.getSelectedSportsVehicleLabel = function()
	return module.sports[module.selectedSportsVehicle].name
end

module.setSelectedSports2Vehicle = function(val)
	module.selectedSports2Vehicle = val
	
	return module.selectedSports2Vehicle
end

module.getSelectedSports2Vehicle = function()
	return module.selectedSports2Vehicle
end

module.getSelectedSportsVehicleLabel = function()
	return module.sports2[module.selectedSports2Vehicle].name
end

module.setSelectedSports3Vehicle = function(val)
	module.selectedSports3Vehicle = val
	
	return module.selectedSports3Vehicle
end

module.getSelectedSports3Vehicle = function()
	return module.selectedSports3Vehicle
end

module.getSelectedSports3VehicleLabel = function()
	return module.sports3[module.selectedSports3Vehicle].name
end

--------------------------------
-- Sports Classics
--------------------------------

module.setSelectedSportsClassicsVehicle = function(val)
	module.selectedSportsClassicsVehicle = val
	
	return module.selectedSportsClassicsVehicle
end

module.getSelectedSportsClassicsVehicle = function()
	return module.selectedSportsClassicsVehicle
end

module.getSelectedSportsClassicsVehicleLabel = function()
	return module.sportsclassics[module.selectedSportsClassicsVehicle].name
end

module.setSelectedSportsClassics2Vehicle = function(val)
	module.selectedSportsClassics2Vehicle = val
	
	return module.selectedSportsClassics2Vehicle
end

module.getSelectedSportsClassics2Vehicle = function()
	return module.selectedSportsClassics2Vehicle
end

module.getSelectedSportsClassics2VehicleLabel = function()
	return module.sportsclassics2[module.selectedSportsClassics2Vehicle].name
end

--------------------------------
-- Super
--------------------------------

module.setSelectedSuperVehicle = function(val)
	module.selectedSuperVehicle = val
	
	return module.selectedSuperVehicle
end

module.getSelectedSuperVehicle = function()
	return module.selectedSuperVehicle
end

module.getSelectedSuperVehicleLabel = function()
	return module.super[module.selectedSuperVehicle].name
end

module.setSelectedSuper2Vehicle = function(val)
	module.selectedSuper2Vehicle = val
	
	return module.selectedSuper2Vehicle
end

module.getSelectedSuper2Vehicle = function()
	return module.selectedSuper2Vehicle
end

module.getSelectedSuper2VehicleLabel = function()
	return module.super2[module.selectedSuper2Vehicle].name
end

--------------------------------
-- Muscle
--------------------------------

module.setSelectedMuscleVehicle = function(val)
	module.selectedMuscleVehicle = val
	
	return module.selectedMuscleVehicle
end

module.getSelectedMuscleVehicle = function()
	return module.selectedMuscleVehicle
end

module.getSelectedMuscleVehicleLabel = function()
	return module.muscle[module.selectedMuscleVehicle].name
end

module.setSelectedMuscle2Vehicle = function(val)
	module.selectedMuscle2Vehicle = val
	
	return module.selectedMuscle2Vehicle
end

module.getSelectedMuscle2Vehicle = function()
	return module.selectedMuscle2Vehicle
end

module.getSelectedMuscle2VehicleLabel = function()
	return module.muscle2[module.selectedMuscle2Vehicle].name
end

--------------------------------
-- Offroad
--------------------------------

module.setSelectedOffroadVehicle = function(val)
	module.selectedOffroadVehicle = val
	
	return module.selectedOffroadVehicle
end

module.getSelectedOffroadVehicle = function()
	return module.selectedOffroadVehicle
end

module.getSelectedOffroadVehicleLabel = function()
	return module.offroad[module.selectedOffroadVehicle].name
end

--------------------------------
-- SUVs
--------------------------------

module.setSelectedSUVsVehicle = function(val)
	module.selectedSUVsVehicle = val
	
	return module.selectedSUVsVehicle
end

module.getSelectedSUVsVehicle = function()
	return module.selectedSUVsVehicle
end

module.getSelectedSUVsVehicleLabel = function()
	return module.suvs[module.selectedSUVsVehicle].name
end

--------------------------------
-- Vans
--------------------------------

module.setSelectedVansVehicle = function(val)
	module.selectedVansVehicle = val
	
	return module.selectedVansVehicle
end

module.getSelectedVansVehicle = function()
	return module.selectedVansVehicle
end

module.getSelectedVansVehicleLabel = function()
	return module.vans[module.selectedVansVehicle].name
end

--------------------------------
-- Motorcycles
--------------------------------

module.setSelectedMotorcyclesVehicle = function(val)
	module.selectedMotorcyclesVehicle = val
	
	return module.selectedMotorcyclesVehicle
end

module.getSelectedMotorcyclesVehicle = function()
	return module.selectedMotorcyclesVehicle
end

module.getSelectedMotorcyclesVehicleLabel = function()
	return module.motorcycles[module.selectedMotorcyclesVehicle].name
end

module.setSelectedMotorcycles2Vehicle = function(val)
	module.selectedMotorcycles2Vehicle = val
	
	return module.selectedMotorcycles2Vehicle
end

module.getSelectedMotorcycles2Vehicle = function()
	return module.selectedMotorcycles2Vehicle
end

module.getSelectedMotorcycles2VehicleLabel = function()
	return module.motorcycles2[module.selectedMotorcycles2Vehicle].name
end

module.setSelectedMotorcycles3Vehicle = function(val)
	module.selectedMotorcycles3Vehicle = val
	
	return module.selectedMotorcycles3Vehicle
end

module.getSelectedMotorcycles3Vehicle = function()
	return module.selectedMotorcycles3Vehicle
end

module.getSelectedMotorcycles3VehicleLabel = function()
	return module.motorcycles3[module.selectedMotorcycles3Vehicle].name
end

-----------------------------------------------------------------------------------
-- BASE FUNCTIONS
-----------------------------------------------------------------------------------

module.SellVehicle = function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)

		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			for i=1, #module.sellableVehicles, 1 do
				if tostring(GetHashKey(module.sellableVehicles[i].model)) == tostring(GetEntityModel(vehicle)) then
					module.vehicleData = module.sellableVehicles[i]
					break
				end
			end

			if module.vehicleData then
				local resellPrice = module.Round(module.vehicleData.price / 100 * module.resellPercentage)
				local formattedPrice = module.GroupDigits(resellPrice)
				local model = GetEntityModel(vehicle)
				local displaytext = GetDisplayNameFromVehicleModel(model)
				local name = GetLabelText(displaytext)
				local plate = module.Trim(GetVehicleNumberPlateText(vehicle))

				if model == module.currentActionData.model and plate == module.currentActionData.plate then
					request("vehicleshop:checkOwnedVehicle", function(result)
						if result then
							request("vehicleshop:sellVehicle", function(success)
								if success then
									DoScreenFadeOut(250)

									while not IsScreenFadedOut() do
									  Citizen.Wait(0)
									end
									
									utils.ui.showNotification("You have sold your ~y~" .. name .. "~s~ with the plates ~b~" .. plate .. "~s~ for ~g~$" .. formattedPrice)
									module.DeleteVehicle(vehicle)

									Citizen.Wait(500)
									DoScreenFadeIn(250)
								end
							end, plate, resellPrice)
						end
					end, plate)
				end
			end
		end
	end
end

module.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. ","):reverse())..right
end

module.Round = function(value)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

module.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

module.GeneratePlate = function()
	local generatedPlate
	local doBreak = false

	while true do
		Citizen.Wait(2)
		math.randomseed(GetGameTimer())
		if module.plateUseSpace then
			generatedPlate = string.upper(module.GetRandomLetter(module.plateLetters) .. ' ' .. module.GetRandomNumber(module.plateNumbers))
		else
			generatedPlate = string.upper(module.GetRandomLetter(module.plateLetters) .. module.GetRandomNumber(module.plateNumbers))
		end

		request('vehicleshop:isPlateTaken', function(isPlateTaken)
			if not isPlateTaken then
				doBreak = true
			end
		end, generatedPlate)

		if doBreak then
			break
		end
	end

	return generatedPlate
end

module.IsPlateTaken = function(plate)
	local callback = 'waiting'

	request('vehicleshop:isPlateTaken', function(isPlateTaken)
		callback = isPlateTaken
	end, plate)

	while type(callback) == 'string' do
		Citizen.Wait(0)
	end

	return callback
end

module.GetRandomNumber = function(length)
	Citizen.Wait(0)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return module.GetRandomNumber(length - 1) .. module.numberCharset[math.random(1, #module.numberCharset)]
	else
		return ''
	end
end

module.GetRandomLetter = function(length)
	Citizen.Wait(0)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return module.GetRandomLetter(length - 1) .. module.charset[math.random(1, #module.charset)]
	else
		return ''
	end
end

module.GetVehicleLabelFromModel = function(model)
	for k,v in ipairs(Vehicles) do
		if v.model == model then
			return v.name
		end
	end

	return
end

module.StartShopRestriction = function()
	Citizen.CreateThread(function()
		while module.isInShopMenu do
			Citizen.Wait(0)

			DisableControlAction(0, 75,  true)
			DisableControlAction(27, 75, true)
		end
	end)
end

module.EnterShop = function()

	module.isInShopMenu = true

	module.StartShopRestriction()
	
	DoScreenFadeOut(250)

	while not IsScreenFadedOut() do
	  Citizen.Wait(0)
	end

	camera.start()
	module.mainCameraScene()

	Citizen.CreateThread(function()
		local ped = PlayerPedId()

		FreezeEntityPosition(ped, true)
		SetEntityVisible(ped, false)
		SetEntityCoords(ped, module.shopInside.pos)
	end)
end

module.ExitShop = function()
	Citizen.CreateThread(function()
		local ped = PlayerPedId()
		FreezeEntityPosition(ped, false)
		SetEntityVisible(ped, true)
		module.ReturnPlayer()
		camera.destroy()
		emit('esx:identity:preventSaving', false)
	end)

	module.isInShopMenu = false
end

module.ReturnPlayer = function()
	local ped = PlayerPedId()
	SetEntityCoords(ped, module.zones.shopBuy.pos)

	Citizen.Wait(1000)
	DoScreenFadeIn(250)
end

module.WaitForVehicleToLoad = function(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName("Please wait for the model to load...")
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

module.DeleteDisplayVehicleInsideShop = function()
	local attempt = 0

	if module.currentDisplayVehicle and DoesEntityExist(module.currentDisplayVehicle) then
		while DoesEntityExist(module.currentDisplayVehicle) and not NetworkHasControlOfEntity(module.currentDisplayVehicle) and attempt < 100 do
			Citizen.Wait(100)
			NetworkRequestControlOfEntity(module.currentDisplayVehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(module.currentDisplayVehicle) and NetworkHasControlOfEntity(module.currentDisplayVehicle) then
			module.DeleteVehicle(module.currentDisplayVehicle)
			module.vehicleLoaded = false
		end
	end
end

module.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

module.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		module.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
		local timeout = 0

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb then
			cb(vehicle)
		end
	end)
end

module.RequestModel = function(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function module.mainCameraScene()
	local ped       = GetPlayerPed(-1)
	local pedCoords = GetEntityCoords(ped)
	local forward   = GetEntityForwardVector(ped)
  
	camera.setRadius(1.25)
	camera.setCoords(pedCoords + forward * 1.25)
	camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  
	camera.pointToBone(SKEL_ROOT)
end
