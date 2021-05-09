Locales['it'] = {
  -- Inventory
  ['inventory'] = 'inventario %s / %s',
  ['use'] = 'usa',
  ['give'] = 'dai',
  ['remove'] = 'getta',
  ['return'] = 'indietro',
  ['give_to'] = 'dai a',
  ['amount'] = 'quantità',
  ['giveammo'] = 'dai munizioni',
  ['amountammo'] = 'quantità munizioni',
  ['noammo'] = 'non hai abbastanza munizioni!',
  ['gave_item'] = 'hai dato ~y~%sx~s~ ~b~%s~s~ a ~y~%s~s~',
  ['received_item'] = 'hai ricevuto ~y~%sx~s~ ~b~%s~s~ da ~b~%s~s~',
  ['gave_weapon'] = 'hai dat ~b~%s~s~ a ~y~%s~s~',
  ['gave_weapon_ammo'] = 'hai dato ~o~%sx %s~s~ per ~b~%s~s~ a ~y~%s~s~',
  ['gave_weapon_withammo'] = 'hai dato ~b~%s~s~ con ~o~%sx %s~s~ a ~y~%s~s~',
  ['gave_weapon_hasalready'] = '~y~%s~s~ ha già un ~y~%s~s~',
  ['gave_weapon_noweapon'] = '~y~%s~s~ non ha quest\'arma',
  ['received_weapon'] = 'hai ricevuto ~b~%s~s~ da ~b~%s~s~',
  ['received_weapon_ammo'] = 'hai ricevuto ~o~%sx %s~s~ per your ~b~%s~s~ da ~b~%s~s~',
  ['received_weapon_withammo'] = 'hai ricevuto ~b~%s~s~ with ~o~%sx %s~s~ da ~b~%s~s~',
  ['received_weapon_hasalready'] = '~b~%s~s~ ha tentato di darti ~y~%s~s~, me ne hai già una',
  ['received_weapon_noweapon'] = '~b~%s~s~ ha tentato di darti munizioni per una ~y~%s~s~, ma non hai quest\'arma',
  ['gave_account_money'] = 'hai dato ~g~$%s~s~ (%s) a ~y~%s~s~',
  ['received_account_money'] = 'hai ricevuto ~g~$%s~s~ (%s) da ~b~%s~s~',
  ['amount_invalid'] = 'quantità non valida',
  ['players_nearby'] = 'non ci sono giocatori vicini',
  ['ex_inv_lim'] = 'azione non possibile, supera il limite dell\'inventario di ~y~%s~s~',
  ['imp_invalid_quantity'] = 'azione impossibile, quantità non valida',
  ['imp_invalid_amount'] = 'azione impossibile, quantità non valida',
  ['threw_standard'] = 'hai gettato ~y~%sx~s~ ~b~%s~s~',
  ['threw_account'] = 'hai gettato ~g~$%s~s~ ~b~%s~s~',
  ['threw_weapon'] = 'hai gettato ~b~%s~s~',
  ['threw_weapon_ammo'] = 'hai gettato ~b~%s~s~ con ~o~%sx %s~s~',
  ['threw_weapon_already'] = 'stai già portando la stessa arma',
  ['threw_cannot_pickup'] = 'non puoi raccogliere altro, il tuo inventario è pieno!',
  ['threw_pickup_prompt'] = 'premi ~y~E~s~ per raccogliere',

  -- Key mapping
  ['keymap_showinventory'] = 'mostra Inventario',

  -- Salary related
  ['received_salary'] = 'hai ricevuto lo stipendio: ~g~$%s~s~',
  ['received_help'] = 'hai ricevuto il tuo assegno di disoccupazione: ~g~$%s~s~',
  ['company_nomoney'] = 'l\'azienda per cui lavori non ha soldi per pagarti lo stipendio',
  ['received_paycheck'] = 'hai ricevuto un assegno',
  ['bank'] = 'maze Bank',
  ['account_bank'] = 'banca',
  ['account_black_money'] = 'soldi sporchi',
  ['account_money'] = 'contanti',

  ['act_imp'] = 'azione impossibile',
  ['in_vehicle'] = 'non puoi dare nulla a qualcuno in un veicolo',

  -- Commands
  ['command_car'] = 'genera un veicolo',
  ['command_car_car'] = 'nome o hash del veicolo',
  ['command_cardel'] = 'elimina veicoli in prossimità',
  ['command_cardel_radius'] = 'opzionale, elimina tutti i veicoli in un determinato raggio',
  ['command_clear'] = 'pulisci chat',
  ['command_clearall'] = 'pulisci chat per tutti i giocatore',
  ['command_clearinventory'] = 'pulisci l\'inventario di un giocatore',
  ['command_clearloadout'] = 'pulisci l\'armamentario di un giocatore',
  ['command_giveaccountmoney'] = 'dai moneta a un giocatore',
  ['command_giveaccountmoney_account'] = 'tipo di moneta valido',
  ['command_giveaccountmoney_amount'] = 'quantità di moneta da aggiungere',
  ['command_giveaccountmoney_invalid'] = 'tipo di moneta non valido',
  ['command_giveitem'] = 'dai un oggetto a un giocatore',
  ['command_giveitem_item'] = 'nome oggetto',
  ['command_giveitem_count'] = 'quantità oggetto',
  ['command_giveweapon'] = 'dai un\'arma a un giocatore',
  ['command_giveweapon_weapon'] = 'nome dell\'arma',
  ['command_giveweapon_ammo'] = 'quantità munizioni',
  ['command_giveweapon_hasalready'] = 'il giocatore ha gia quest\'arma',
  ['command_giveweaponcomponent'] = 'dai un componente per l\'arma',
  ['command_giveweaponcomponent_component'] = 'nome del componente',
  ['command_giveweaponcomponent_invalid'] = 'componente dell\'arma non valido',
  ['command_giveweaponcomponent_hasalready'] = 'il giocatore ha già questo componente',
  ['command_giveweaponcomponent_missingweapon'] = 'il giocatore non ha quest\'arma',
  ['command_save'] = 'salva un giocatore sul database',
  ['command_saveall'] = 'salva tutti i giocatori sul database',
  ['command_setaccountmoney'] = 'imposta moneta a un giocatore',
  ['command_setaccountmoney_amount'] = 'quantità di moneta da impostare',
  ['command_setcoords'] = 'vai alle coordinate',
  ['command_setcoords_x'] = 'x',
  ['command_setcoords_y'] = 'y',
  ['command_setcoords_z'] = 'z',
  ['command_setjob'] = 'imposta lavoro per un giocatore',
  ['command_setjob_job'] = 'nome del lavoro',
  ['command_setjob_grade'] = 'grado del lavoro',
  ['command_setjob_invalid'] = 'il lavoro, il grado o entrambi non sono validi',
  ['command_setgroup'] = 'imposta gruppo per un giocatore',
  ['command_setgroup_group'] = 'nome del gruppo',
  ['commanderror_argumentmismatch'] = 'gli argomenti passati non corrsipondono a quelli previsti (passati %s, previsti %s)',
  ['commanderror_argumentmismatch_number'] = 'l\'argomento #%s è del formato sbagliato (passata una stringa, previsto un numero)',
  ['commanderror_invaliditem'] = 'nome oggetto non valido',
  ['commanderror_invalidweapon'] = 'arma non valida',
  ['commanderror_console'] = 'questo comando non può essere eseguito dalla console',
  ['commanderror_invalidcommand'] = '^3%s^0 non è un giocatore valido!',
  ['commanderror_invalidplayerid'] = 'non c\'è nessun giocatore online con questo ID',
  ['commandgeneric_playerid'] = 'ID del giocatore',

  -- Locale settings
  ['locale_digit_grouping_symbol'] = '.',
  ['locale_currency'] = '$%s',

  -- Weapons

  -- Melee
  ['weapon_dagger'] = 'Pugnale',
  ['weapon_bat'] = 'Mazza',
  ['weapon_battleaxe'] = 'Ascia da battaglia',
  ['weapon_bottle'] = 'Bottiglia',
  ['weapon_crowbar'] = 'Piede di porco',
  ['weapon_flashlight'] = 'Torcia',
  ['weapon_golfclub'] = 'Mazza da golf',
  ['weapon_hammer'] = 'Martello',
  ['weapon_hatchet'] = 'Accetta',
  ['weapon_knife'] = 'Coltello',
  ['weapon_knuckle'] = 'Tirapugni',
  ['weapon_machete'] = 'Machete',
  ['weapon_nightstick'] = 'Manganello',
  ['weapon_wrench'] = 'Chiave Giratubi',
  ['weapon_poolcue'] = 'Stecca da biliardo',
  ['weapon_stone_hatchet'] = 'Accetta di pietra',
  ['weapon_switchblade'] = 'Coltello a serramanico',

  -- Handguns
  ['weapon_appistol'] = 'Pistola AP',
  ['weapon_ceramicpistol'] = 'Pistola di ceramica',
  ['weapon_combatpistol'] = 'Pistola da combattimento',
  ['weapon_doubleaction'] = 'Revolver a doppia azione',
  ['weapon_navyrevolver'] = 'Revolver militare',
  ['weapon_flaregun'] = 'Pistola lanciarazzi',
  ['weapon_gadgetpistol'] = 'Pistola gadget',
  ['weapon_heavypistol'] = 'Pistola pesante',
  ['weapon_revolver'] = 'Revolver pesante',
  ['weapon_revolver_mk2'] = 'Revolver pesante MK2',
  ['weapon_marksmanpistol'] = 'Pistola da tiratore',
  ['weapon_pistol'] = 'Pistola',
  ['weapon_pistol_mk2'] = 'Pistola MK2',
  ['weapon_pistol50'] = 'Pistola .50',
  ['weapon_snspistol'] = 'Pistola SNS',
  ['weapon_snspistol_mk2'] = 'Pistola SNS MK2',
  ['weapon_stungun'] = 'Taser',
  ['weapon_raypistol'] = 'Up-N-Atomizer',
  ['weapon_vintagepistol'] = 'Pistola Vintage',

  -- Shotguns
  ['weapon_assaultshotgun'] = 'Fucile a pompa d\'assalto',
  ['weapon_autoshotgun'] = 'Fucile a pompa automatico',
  ['weapon_bullpupshotgun'] = 'Fucile a pompa bullpup',
  ['weapon_combatshotgun'] = 'Fucile a pompa da combattimento',
  ['weapon_dbshotgun'] = 'Fucile a pompa a doppia canna',
  ['weapon_heavyshotgun'] = 'Fucile a pompa pesante',
  ['weapon_musket'] = 'Moschetto',
  ['weapon_pumpshotgun'] = 'Fucile a pompa',
  ['weapon_pumpshotgun_mk2'] = 'Fucile a pompa MK2',
  ['weapon_sawnoffshotgun'] = 'Fucile a pompa a canne mozze',

  -- SMG & LMG
  ['weapon_assaultsmg'] = 'SMG d\'assalto',
  ['weapon_combatmg'] = 'MG da combattimento',
  ['weapon_combatmg'] = 'MG da combattimento MK2',
  ['weapon_combatpdw'] = 'PDW da combattimento',
  ['weapon_gusenberg'] = 'Thompson',
  ['weapon_machinepistol'] = 'Mitragliatrice',
  ['weapon_mg'] = 'MG',
  ['weapon_microsmg'] = 'Micro SMG',
  ['weapon_minismg'] = 'Mini SMG',
  ['weapon_smg'] = 'SMG',
  ['weapon_smg_mk2'] = 'SMG MK2',
  ['weapon_raycarbine'] = 'Unholy Hellbringer',

  -- Rifles
  ['weapon_advancedrifle'] = 'Fucile avanzato',
  ['weapon_assaultrifle'] = 'Fucile d\'assalto',
  ['weapon_assaultrifle_mk2'] = 'Fucile d\'assalto MK2',
  ['weapon_bullpuprifle'] = 'Fucile bullpup',
  ['weapon_bullpuprifle_mk2'] = 'Fucile bullpup MK2',
  ['weapon_carbinerifle'] = 'Carabina',
  ['weapon_carbinerifle_mk2'] = 'Carabina MK2',
  ['weapon_compactrifle'] = 'Fucile compatto',
  ['weapon_militaryrifle'] = 'Fucile militare',
  ['weapon_specialcarbine'] = 'Carabina speciale',
  ['weapon_specialcarbine_mk2'] = 'Carabina speciale MK2',

  -- Sniper
  ['weapon_heavysniper'] = 'Fucile da cecchino pesante',
  ['weapon_heavysniper_mk2'] = 'Fucile da cecchino pesante MK2',
  ['weapon_marksmanrifle'] = 'Fucile da tiratore',
  ['weapon_marksmanrifle_mk2'] = 'Fucile da tiratore MK2',
  ['weapon_sniperrifle'] = 'Fucile da cecchino',

  -- Heavy / Launchers
  ['weapon_compactlauncher'] = 'Lanciagranate compatto',
  ['weapon_firework'] = 'Cannone pirotecnico',
  ['weapon_grenadelauncher'] = 'Lanciagranate',
  ['weapon_hominglauncher'] = 'Lanciarazzi pesante',
  ['weapon_minigun'] = 'Minigun',
  ['weapon_railgun'] = 'Railgun',
  ['weapon_rpg'] = 'Lanciarazzi',
  ['weapon_rayminigun'] = 'Widowmaker',

  -- Thrown
  ['weapon_ball'] = 'Palla da baseball',
  ['weapon_bzgas'] = 'Granata a gas',
  ['weapon_flare'] = 'Flare',
  ['weapon_grenade'] = 'Granata',
  ['weapon_petrolcan'] = 'Tanica',
  ['weapon_hazardcan'] = 'Tanica Speciale',
  ['weapon_molotov'] = 'Molotov',
  ['weapon_proxmine'] = 'Mina di prossimità',
  ['weapon_pipebomb'] = 'Bomba a tubo',
  ['weapon_snowball'] = 'Palla di neve',
  ['weapon_stickybomb'] = 'Bomba appiccicosa',
  ['weapon_smokegrenade'] = 'Granata lacrimogena',

  -- Special
  ['weapon_fireextinguisher'] = 'Estintore',
  ['weapon_digiscanner'] = 'Scanner digitale',
  ['weapon_garbagebag'] = 'Busta della spazzatura',
  ['weapon_handcuffs'] = 'Manette',
  ['gadget_nightvision'] = 'Visore notturno',
  ['gadget_parachute'] = 'paracadute',

  -- Weapon Components
  ['component_knuckle_base'] = 'modello base',
  ['component_knuckle_pimp'] = 'Pimp',
  ['component_knuckle_ballas'] = 'Ballas',
  ['component_knuckle_dollar'] = 'Hustler',
  ['component_knuckle_diamond'] = 'Rock',
  ['component_knuckle_hate'] = 'Hater',
  ['component_knuckle_love'] = 'Lover',
  ['component_knuckle_player'] = 'Player',
  ['component_knuckle_king'] = 'King',
  ['component_knuckle_vagos'] = 'Vagos',

  ['component_luxary_finish'] = 'Finitura lussuosa',

  ['component_handle_default'] = 'default Handle',
  ['component_handle_vip'] = 'vIP Handle',
  ['component_handle_bodyguard'] = 'bodyguard Handle',

  ['component_vip_finish'] = 'vIP Finish',
  ['component_bodyguard_finish'] = 'bodyguard Finish',

  ['component_camo_finish'] = 'digital Camo',
  ['component_camo_finish2'] = 'brushstroke Camo',
  ['component_camo_finish3'] = 'woodland Camo',
  ['component_camo_finish4'] = 'skull Camo',
  ['component_camo_finish5'] = 'sessanta Nove Camo',
  ['component_camo_finish6'] = 'perseus Camo',
  ['component_camo_finish7'] = 'leopard Camo',
  ['component_camo_finish8'] = 'zebra Camo',
  ['component_camo_finish9'] = 'geometric Camo',
  ['component_camo_finish10'] = 'boom Camo',
  ['component_camo_finish11'] = 'patriotic Camo',

  ['component_camo_slide_finish'] = 'digital Slide Camo',
  ['component_camo_slide_finish2'] = 'brushstroke Slide Camo',
  ['component_camo_slide_finish3'] = 'woodland Slide Camo',
  ['component_camo_slide_finish4'] = 'skull Slide Camo',
  ['component_camo_slide_finish5'] = 'sessanta Nove Slide Camo',
  ['component_camo_slide_finish6'] = 'perseus Slide Camo',
  ['component_camo_slide_finish7'] = 'leopard Slide Camo',
  ['component_camo_slide_finish8'] = 'zebra Slide Camo',
  ['component_camo_slide_finish9'] = 'geometric Slide Camo',
  ['component_camo_slide_finish10'] = 'boom Slide Camo',
  ['component_camo_slide_finish11'] = 'patriotic Slide Camo',

  ['component_clip_default'] = 'default Magazine',
  ['component_clip_extended'] = 'extended Magazine',
  ['component_clip_drum'] = 'drum Magazine',
  ['component_clip_box'] = 'box Magazine',

  ['component_scope_holo'] = 'holographic Scope',
  ['component_scope_small'] = 'small Scope',
  ['component_scope_medium'] = 'medium Scope',
  ['component_scope_large'] = 'large Scope',
  ['component_scope'] = 'mounted Scope',
  ['component_scope_advanced'] = 'advanced Scope',
  ['component_ironsights'] = 'ironsights',

  ['component_suppressor'] = 'silenziatore',
  ['component_compensator'] = 'compensatore',

  ['component_muzzle_flat'] = 'flat Muzzle Brake',
  ['component_muzzle_tactical'] = 'tactical Muzzle Brake',
  ['component_muzzle_fat'] = 'fat-End Muzzle Brake',
  ['component_muzzle_precision'] = 'precision Muzzle Brake',
  ['component_muzzle_heavy'] = 'heavy Duty Muzzle Brake',
  ['component_muzzle_slanted'] = 'slanted Muzzle Brake',
  ['component_muzzle_split'] = 'split-End Muzzle Brake',
  ['component_muzzle_squared'] = 'squared Muzzle Brake',

  ['component_flashlight'] = 'torcia',
  ['component_grip'] = 'grip',

  ['component_barrel_default'] = 'default Barrel',
  ['component_barrel_heavy'] = 'heavy Barrel',

  ['component_ammo_tracer'] = 'tracer Ammo',
  ['component_ammo_incendiary'] = 'incendiary Ammo',
  ['component_ammo_hollowpoint'] = 'hollowpoint Ammo',
  ['component_ammo_fmj'] = 'fMJ Ammo',
  ['component_ammo_armor'] = 'armor Piercing Ammo',
  ['component_ammo_explosive'] = 'armor Piercing Incendiary Ammo',

  ['component_shells_default'] = 'default Shells',
  ['component_shells_incendiary'] = 'dragons Breath Shells',
  ['component_shells_armor'] = 'steel Buckshot Shells',
  ['component_shells_hollowpoint'] = 'flechette Shells',
  ['component_shells_explosive'] = 'explosive Slug Shells',

  -- Weapon Ammo
  ['ammo_rounds'] = 'proiettile/i',
  ['ammo_shells'] = 'cartuccia/e',
  ['ammo_charge'] = 'carica',
  ['ammo_petrol'] = 'carburante',
  ['ammo_firework'] = 'fucoo d\'artificio',
  ['ammo_rockets'] = 'razzo/i',
  ['ammo_grenadelauncher'] = 'granata/e',
  ['ammo_grenade'] = 'granata/e',
  ['ammo_stickybomb'] = 'bomba/e',
  ['ammo_pipebomb'] = 'bomba/e',
  ['ammo_smokebomb'] = 'bomba/e',
  ['ammo_molotov'] = 'cocktail',
  ['ammo_proxmine'] = 'mina/e',
  ['ammo_bzgas'] = 'bomboletta/e',
  ['ammo_ball'] = 'palla/e',
  ['ammo_snowball'] = 'palla di neve',
  ['ammo_flare'] = 'flare',
  ['ammo_flaregun'] = 'flare',

  -- Weapon Tints
  ['tint_default'] = 'skin base',
  ['tint_green'] = 'skin verde',
  ['tint_gold'] = 'skin oro',
  ['tint_pink'] = 'skin rosa',
  ['tint_army'] = 'skin militare',
  ['tint_lspd'] = 'skin blu',
  ['tint_orange'] = 'skin arancione',
  ['tint_platinum'] = 'skin platino',
}
