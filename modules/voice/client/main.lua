local self = ESX.Modules['voice']
local Input = ESX.Modules['input']

self.Init()

-- Add loading screen off event handler to wait for loading screen to be off before showing Voice HUD (ArkSeyonet)
AddEventHandler('esx:loadingScreenOff', function()
	ESX.Loop('draw-voice-level',function ()
		if NetworkIsPlayerTalking(PlayerId()) then
			self.DrawLevel(41, 128, 185, 255)
		else
			self.DrawLevel(185, 185, 185, 255)
		end
	end,0)
end)
