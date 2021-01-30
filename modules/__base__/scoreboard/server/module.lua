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

M("command")
M('events')
M('ui.hud')

module.Init = function()
end

local uptimeStart, uptimeCurrent, uptimeDays, uptimeHours, uptimeMinutes = 0, 0, 0, 0, 0
module.Players = {}
module.Debug = false

Citizen.CreateThread(function()
    local uptimeStart = GetGameTimer() -- Initialize game timer

    while true do -- Being execution
      Citizen.Wait(1000 * 60) -- Execute every minute
  
        -- Calculate uptime
        uptimeCurrent = GetGameTimer()
        uptimeDays    = math.floor((uptimeCurrent - uptimeStart) / 86400000)
        uptimeHours   = math.floor((uptimeCurrent - uptimeStart) / 3600000) % 24
        uptimeMinutes = math.floor((uptimeCurrent - uptimeStart) / 60000) % 60

        if module.Debug then
          print(uptimeCurrent)
          print(uptimeDays)
          print(uptimeHours)
          print(uptimeMinutes)
        end
        
    end
end)

onClient('esx:scoredboard:addPlayer', function()
  module.Players[source] = true
end)

AddEventHandler('playerDropped', function()
  module.Players[source] = nil
end)

onRequest('esx:scoreboard:Getplayers', function(source, cb)
local players = {}

  for playerId,bool in pairs(module.Players) do
    if bool then
      local name = Sanitize(GetPlayerName(playerId))
      local ping = GetPlayerPing(playerId)

      if module.Debug then
        print(name)
        print(ping)
        print(playerId)
      end

      local player = Player.fromId(playerId)
    
      if player ~= nil then
        local playerData = player:getIdentity()
        local firstname  = playerData:getFirstName()
        local lastname   = playerData:getLastName()

        RPname = Sanitize((""..firstname.." "..lastname))

        if module.Debug then
          print(firstname)
          print(lastname)
          print(RPname)
        end
        
        table.insert(players,'<tr><td>' .. Sanitize(GetPlayerName(playerId)).. '</td><td>' .. RPname .. '</td><td>' .. playerId .. '</td><td>' .. ping ..'</td></tr>')
      else 
        return
      end
    end
  end

  if module.Debug then
    print(players)
  end
  
  cb(players) 
end)


onRequest('esx:scoreboard:Getuptime', function(source, cb)
  uptime = string.format("UPTIME: %02d:%02d:%02d", uptimeDays, uptimeHours, uptimeMinutes)
  cb(uptime) 
end)

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end