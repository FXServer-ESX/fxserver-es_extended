Config = {}
Config.Locale = 'en'

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

Config.StartingAccountMoney 	= {bank = 50000}

Config.EnableSocietyPayouts 	= false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            	= true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            	= 24   -- the max inventory weight without backpack
Config.PaycheckInterval         = 7 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?
Config.EnableDefaultInventory   = true -- Display the default Inventory ( F2 )
Config.EnableWantedLevel    	= false -- Use Normal GTA wanted Level?
Config.EnablePVP                = true -- Allow Player to player combat

Config.DropItemList = {
    default 	= 'prop_cs_cardbox_01',
    money 		= 'prop_money_bag_01',
	black_money	= 'prop_money_bag_01',
    bread 		= 'prop_cs_burger_01',
    water 		= 'prop_ld_flow_bottle',
    beer 		= 'prop_cs_beer_bot_01'
}