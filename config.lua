Config = {}
Config.Locale = 'en'

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

Config.StartingAccountMoney 	= {bank = 50000}

-- IF YOU DISABLE THIS YOU MUST REMOVE THE LINE ``'@mysql-async/lib/MySQL.lua',`` FROM THE fxmanifest.lua
Config.UseMySQLAsync = true -- If you want to use mysql-async leave this true if you want to use ghmattimysql set this to false (DO NOT TOUCH IF YOU DO NOT KNOW WHAT YOU ARE DOING)

Config.EnableSocietyPayouts 	= false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            	= true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            	= 24   -- the max inventory weight without backpack
Config.PaycheckInterval         = 7 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?
Config.EnableDefaultInventory   = true -- Display the default Inventory ( F2 )
Config.EnableWantedLevel    	= false -- Use Normal GTA wanted Level?
Config.EnablePVP                = true -- Allow Player to player combat

