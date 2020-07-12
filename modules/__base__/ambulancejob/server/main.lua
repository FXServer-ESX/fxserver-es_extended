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

--[[xPlayer = M('player')

xPlayer.createDBAccessor('faction', {name = 'faction', type = 'VARCHAR', length = 64, default = 'gang.ballas', extra = nil})

local player = xPlayer:fromId(2)

print(player:getFaction())

player:setFaction('another.faction')

player:save()--]]