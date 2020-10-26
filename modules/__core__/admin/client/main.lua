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
M('ui.menu')

module.Init()

-- Admin Menu
module.OpenMenu = function()
	local menu = Menu('admin.main', {
    float = 'top|left',
    title = 'Administrator Menu',
    items = {
		{label = _U('admin:menu_player'), name = 'OpenPlayerMenu',  type = 'button'},
		{label = _U('admin:menu_vehicle'), name = 'OpenVehicleMenu',  type = 'button'},
		{label = _U('admin:menu_job'), name = 'OpenJobMenu',  type = 'button'},
		{label = _U('admin:menu_esx'), name = 'OpenEsxMenu',  type = 'button'},
		{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, false) then return end

		module[item.name](menu)
	end)
end

-- Player menu
module.OpenPlayerMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.player_menu', {
    float = 'top|left',
    title = 'Player Menu',
    items = {
		{label = _U('admin:command_tptm'), name = 'TPTMarkerMenu', type='button'},
		{label = _U('admin:command_tptp'), name = 'TPTPlayerMenu', type='button'},
		{label = _U('admin:command_spectate'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SpectatePlayer', value = true, type = 'button'},
		{label = _U('admin:command_revive'), name = 'ReviveMenu', type='button'},
		{label = _U('admin:command_health'), name = 'HealthMenu', type='button'},
		{label = _U('admin:command_armor'), name = 'ArmorMenu', type='button'},
		{label = _U('admin:command_give_weapon'), name = 'GiveWeaponMenu', type='button'},
		-- {label = _U('admin:command_del_weapon'), name = 'DelWeaponMenu', type='button'},
		-- {label = _U('admin:command_kick'), name = 'KickPlayerMenu', type='button'},
		-- {label = _U('admin:command_ban'), name = 'BanPlayerMenu', type='button'},
		-- {label = _U('admin:command_unban'), name = 'UnBanPlayerMenu', type='button'},
		{label = _U('admin:back'), name = 'back', type = 'button'},
		{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module[item.name](menu)
	end)
end

module.TPTMarkerMenu = function(m)
	module.HideMenu(m)
	
	local menu = Menu('admin.tptm_menu', {
		float = 'top|left',
		title = 'Teleport Menu (TPTM)',
		items = {
			{label = _U('admin:command_tptm'), name = 'TPTMarker', type='button'},
			{label = _U('admin:command_on_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'TPTMarker', value = false, type='button'},
			{label = _U('admin:back'), name = 'back', type = 'button'},
			{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module.CloseMenu(false, menu)

		module[item.name]()
	end)
end

module.TPTPlayerMenu = function(m)
	module.HideMenu(m)
	
	local menu = Menu('admin.tptp_menu', {
		float = 'top|left',
		title = 'Teleport Menu (TPTP)',
		items = {
			{label = _U('admin:command_tptp'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'TPTPlayer', value = true, type='button'},
			{label = _U('admin:command_tptp_rev'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'TPTPlayer', value = false, type='button', arg = { GetPlayerServerId(PlayerId()) }},
			{label = _U('admin:back'), name = 'back', type = 'button'},
			{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end
	end)
end

module.ReviveMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.revive_menu', {
		float = 'top|left',
		title = 'Revive Menu',
		items = {
			{label = _U('admin:command_revive'), name = 'RevivePlayer', type='button'},
			{label = _U('admin:command_on_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'RevivePlayer', value = false, type='button'},
			{label = _U('admin:back'), name = 'back', type = 'button'},
			{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module.CloseMenu(false, menu)

		module[item.name]()
	end)
end

module.HealthMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.health_menu', {
		float = 'top|left',
		title = 'Health Menu',
		items = {
			{label = _U('admin:command_health'), name = 'SetPlayerHealth', type='button', arg = { 100 }},
			{label = _U('admin:command_on_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SetPlayerHealth', value = false, type='button', arg = { 100 }},
			{label = _U('admin:command_kill_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SetPlayerHealth', value = false, type='button', arg = { 0 }},
			{label = _U('admin:back'), name = 'back', type = 'button'},
			{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end
		
		module.CloseMenu(false, menu)

		module[item.name](nil, table.unpack(item.arg))
	end)
end

module.ArmorMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.armor_menu', {
		float = 'top|left',
		title = 'Armor Menu',
		items = {
			{label = _U('admin:command_armor'), name = 'SetPlayerArmor', type='button', arg = { 100 }},
			{label = _U('admin:command_on_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SetPlayerArmor', value = false, type='button', arg = { 100 }},
			{label = _U('admin:back'), name = 'back', type = 'button'},
			{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module.CloseMenu(false, menu)

		module[item.name](nil, table.unpack(item.arg))
	end)
end

module.GiveWeaponMenu = function(m) -- maybe need optimization
	module.HideMenu(m)

	local weaponHashName = module.WeaponList[1].name

	local menu = Menu('admin.give_weapon_menu', {
		float = 'top|left',
		title = 'Give Weapon Menu',
		items = {
			{label = module.WeaponList[1].label .. '	' .. weaponHashName, type = 'slider', max = #module.WeaponList - 1},
			{label = _U('admin:command_get_weapon'), name = 'GiveWeaponPlayer', type='button'},
			{label = _U('admin:command_on_player'), toUser = true, source = GetPlayerServerId(PlayerId()), name = 'GiveWeaponPlayer', value = false, type='button'},
			{label = _U('admin:back'), name = 'back', type = 'button'},
			{label = _U('admin:close'), name = 'close', type = 'button'}
	}})

	menu:on('item.change', function(item, prop, val)
		item.label = module.WeaponList[val+1].label .. '	' .. module.WeaponList[val+1].name
		weaponHashName = module.WeaponList[val+1].name
	end)

	menu:on('item.click', function(item, index)
		if module.BasicButtonsMenu(item, menu, m) then return end

		if item.toUser then
			return module.UserListMenu(menu, item.value, item.name, item.source, weaponHashName, 250)
		end

		if item.type ~= "slider" then
			module.CloseMenu(false, menu)

			module[item.name](nil, weaponHashName, 250)
		end
	end)
end

-- Vehicle menu
module.OpenVehicleMenu = function(m)
	module.HideMenu(m)



end

-- 
-- Reusable functions
module.UserListMenu = function(m, onSelf, ...)
	module.HideMenu(m)

	elements = {
		{label = _U('admin:back'), name = 'back', type = 'button'},
		{label = _U('admin:close'), name = 'close', type = 'button'},
	}
	
	local playersActive = GetActivePlayers()

	if #playersActive > 0 then
		local ownID = GetPlayerIndex()

		table.insert(elements, {label = '', name = 'spacer', type='button'})

		for _, playerId in ipairs(playersActive) do

			if ownID ~= playerId then
				local playerSrc = GetPlayerServerId(playerId)
				table.insert(elements, {label = playerSrc ..' | '.. GetPlayerName(playerId), id = playerSrc, type = 'button'})
			end

			-- debug option.
			-- local playerSrc = GetPlayerServerId(playerId)
			-- table.insert(elements, {label = playerSrc ..' | '.. GetPlayerName(playerId), id = playerSrc, type = 'button'})
		end
	end

	local menu = Menu('admin.user_list_menu', {
		float = 'top|left',
		title = 'Player List',
		items = elements
	})

	local vArg = {...}

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		if onSelf then
			module.OnSelfCommand(table.unpack(vArg), item.id)
		else
			emitServer('esx:admin:sendToPlayer', item.id, table.unpack(vArg))
		end
	end)
end

module.HideMenu = function(m)
	m:hide()
	table.insert(module.MenuHiddenList, m)
end

module.BasicButtonsMenu = function(item, menu, m)
	if item.name == 'spacer' then return true end

	if m then
		module.BackMenu(item, menu, m)
	end
		
	module.CloseMenu(item, menu)

	if item.name == 'close' or item.name == 'back' then return true end

	if item.playerList then
		if item.arg then
			module.UserListMenu(menu, item.value, item.name, item.source, table.unpack(item.arg))
		else
			module.UserListMenu(menu, item.value, item.name, item.source)
		end
		return true
	end
end

module.CloseMenu = function(item, m)
	if not(item) or item.name == 'close' then
		m:destroy()

		if #module.MenuHiddenList ~= 0 then
			for k, menu in ipairs(module.MenuHiddenList) do
				menu:destroy()
			end

			module.MenuHiddenList = {}
		end
	end
end

module.BackMenu = function(item, m, targetM)
	if targetM and item.name == 'back' then
		m:destroy()

		targetM:show()
		targetM:focus()

		module.MenuHiddenList[#module.MenuHiddenList] = nil
	end
end
