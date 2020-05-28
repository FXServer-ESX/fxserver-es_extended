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

local Command = M("command")

onClient(
	"esx_skin:save",
	function(skin)
		local player = xPlayer.fromId(source)
		local defaultMaxWeight = ESX.GetConfig().MaxWeight
		local backpackModifier = Config.BackpackWeight[skin.bags_1]

		if backpackModifier then
			player:setMaxWeight(defaultMaxWeight + backpackModifier)
		else
			player:setMaxWeight(defaultMaxWeight)
		end

		MySQL.Async.execute(
			"UPDATE users SET skin = @skin WHERE identifier = @identifier",
			{
				["@skin"] = json.encode(skin),
				["@identifier"] = player.identifier
			}
		)
	end
)

onClient(
	"esx_skin:responseSaveSkin",
	function(skin)
		local player = xPlayer.fromId(source)

		if player:getGroup() == "admin" then
			local file = io.open("resources/es_extended/data/skins.txt", "a")

			file:write(json.encode(skin) .. "\n\n")
			file:flush()
			file:close()
		else
			print(("esx_skin: %s attempted saving skin to file"):format(player:getIdentifier()))
		end
	end
)

onRequest(
	"esx_skin:getPlayerSkin",
	function(source, cb)
		local player = xPlayer.fromId(source)

		MySQL.Async.fetchAll(
			"SELECT skin FROM users WHERE identifier = @identifier",
			{
				["@identifier"] = player.identifier
			},
			function(users)
				local user = users[1]

				local jobSkin = {
					skin_male = player.job.skin_male,
					skin_female = player.job.skin_female
				}

				if user.skin then
					skin = json.decode(user.skin)
				end

				cb(skin, jobSkin)
			end
		)
	end
)

Command.Register(
	"skin",
	"admin",
	function(player, args, showError)
		player:emit("esx_skin:openSaveableMenu")
	end,
	false,
	{help = _U("skin")}
)

Command.Register(
	"skinsave",
	"admin",
	function(player, args, showError)
		player:emit("esx_skin:requestSaveSkin")
	end,
	false,
	{help = _U("saveskin")}
)
