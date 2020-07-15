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

module.categories = {
	{name = 'cc',                     label = 'Compacts/Coupes'               },
	{name = 'cs',                     label = 'Coupes/Sedans'                 },
	{name = 'sports',                 label = 'Sports'                        },
	{name = 'sports2',                label = 'Sports 2'                      },
	{name = 'sports3',                label = 'Sports 3'                      },
	{name = 'sportsclassics',         label = 'Sports Classics'               },
	{name = 'sportsclassics2',        label = 'Sports Classics 2'             },
	{name = 'super',                  label = 'Super'                         },
	{name = 'super2',                 label = 'Super 2'                       },
	{name = 'muscle',                 label = 'Muscle'                        },
	{name = 'muscle2',                label = 'Muscle 2'                      },
	{name = 'offroad',                label = 'Off-road'                      },
	{name = 'suvs',                   label = 'SUVs'                          },
	{name = 'vans',                   label = 'Vans'                          },
	{name = 'motorcycles',            label = 'Motorcycles'                   },
	{name = 'motorcycles2',           label = 'Motorcycles 2'                 },
	{name = 'motorcycles3',           label = 'Motorcycles 3'                 }
}

module.cc = {
	{name = 'Blista',                 model = 'blista',       price = 8000    },
	{name = 'Brioso R/A',             model = 'brioso',       price = 18000   },
	{name = 'Issi',                   model = 'issi2',        price = 10000   },
	{name = 'Panto',                  model = 'panto',        price = 10000   },
	{name = 'Prairie',                model = 'prairie',      price = 12000   },
	{name = 'Cognoscenti Cabrio',     model = 'cogcabrio',    price = 55000   },
	{name = 'Exemplar',               model = 'exemplar',     price = 32000   },
	{name = 'F620',                   model = 'f620',         price = 40000   },
	{name = 'Felon',                  model = 'felon',        price = 42000   },
	{name = 'Felon GT',               model = 'felon2',       price = 55000   },
	{name = 'Jackal',                 model = 'jackal',       price = 38000   },
	{name = 'Oracle XS',              model = 'oracle2',      price = 35000   },
	{name = 'Sentinel',               model = 'sentinel',     price = 32000   },
	{name = 'Sentinel XS',            model = 'sentinel2',    price = 40000   },
	{name = 'Windsor',                model = 'windsor',      price = 95000   },
	{name = 'Windsor Drop',           model = 'windsor2',     price = 125000  },
	{name = 'Zion',                   model = 'zion',         price = 36000   },
}

module.cs = {
	{name = 'Zion Cabrio',            model = 'zion2',        price = 45000   },
	{name = 'Asea',                   model = 'asea',         price = 5500    },
	{name = 'Cognoscenti',            model = 'cognoscenti',  price = 55000   },
	{name = 'Emperor',                model = 'emperor',      price = 8500    },
	{name = 'Fugitive',               model = 'fugitive',     price = 12000   },
	{name = 'Glendale',               model = 'glendale',     price = 6500    },
	{name = 'Intruder',               model = 'intruder',     price = 7500    },
	{name = 'Premier',                model = 'premier',      price = 8000    },
	{name = 'Primo Custom',           model = 'primo2',       price = 14000   },
	{name = 'Regina',                 model = 'regina',       price = 5000    },
	{name = 'Schafter',               model = 'schafter2',    price = 25000   },
	{name = 'Stretch',                model = 'stretch',      price = 90000   },
	{name = 'Super Diamond',          model = 'superd',       price = 130000  },
	{name = 'Tailgater',              model = 'tailgater',    price = 30000   },
	{name = 'Warrener',               model = 'warrener',     price = 4000    },
	{name = 'Washington',             model = 'washington',   price = 9000    }
}

module.sports = {
	{name = '9F',                     model = 'ninef',        price = 65000   },
	{name = '9F Cabrio',              model = 'ninef2',       price = 80000   },
	{name = 'Alpha',                  model = 'alpha',        price = 60000   },
	{name = 'Banshee',                model = 'banshee',      price = 70000   },
	{name = 'Bestia GTS',             model = 'bestiagts',    price = 55000   },
	{name = 'Buffalo',                model = 'buffalo',      price = 12000   },
	{name = 'Buffalo S',              model = 'buffalo2',     price = 20000   },
	{name = 'Carbonizzare',           model = 'carbonizzare', price = 75000   },
	{name = 'Comet',                  model = 'comet2',       price = 65000   },
	{name = 'Coquette',               model = 'coquette',     price = 65000   },
	{name = 'Drift Tampa',            model = 'tampa2',       price = 80000   },
	{name = 'Elegy',                  model = 'elegy2',       price = 38500   },
	{name = 'Feltzer',                model = 'feltzer2',     price = 55000   },
	{name = 'Furore GT',              model = 'furoregt',     price = 45000   },
	{name = 'Fusilade',               model = 'fusilade',     price = 40000   },
	{name = 'Jester',                 model = 'jester',       price = 65000   },
	{name = 'Jester(Racecar)',        model = 'jester2',      price = 135000  }
}

module.sports2 = {
	{name = 'Khamelion',              model = 'khamelion',    price = 38000   },
	{name = 'Kuruma',                 model = 'kuruma',       price = 30000   },
	{name = 'Lynx',                   model = 'lynx',         price = 40000   },
	{name = 'Mamba',                  model = 'mamba',        price = 70000   },
	{name = 'Massacro',               model = 'massacro',     price = 65000   },
	{name = 'Massacro(Racecar)',      model = 'massacro2',    price = 130000  },
	{name = 'Omnis',                  model = 'omnis',        price = 35000   },
	{name = 'Penumbra',               model = 'penumbra',     price = 28000   },
	{name = 'Rapid GT',               model = 'rapidgt',      price = 35000   },
	{name = 'Rapid GT Convertible',   model = 'rapidgt2',     price = 45000   },
	{name = 'Schafter V12',           model = 'schafter3',    price = 50000   },
	{name = 'Seven 70',               model = 'seven70',      price = 39500   },
	{name = 'Sultan',                 model = 'sultan',       price = 15000   },
	{name = 'Surano',                 model = 'surano',       price = 50000   },
	{name = 'Tropos',                 model = 'tropos',       price = 40000   },
	{name = 'Verlierer',              model = 'verlierer2',   price = 70000   },
	{name = 'raiden',                 model = 'raiden',       price = 1375000 }
}

module.sports3 = {
	{name = 'Pariah',                 model = 'pariah',       price = 1420000 },
	{name = 'Stromberg',              model = 'stromberg',    price = 3185350 },
	{name = 'Streiter',               model = 'streiter',     price = 500000  },
	{name = 'Comet 5',                model = 'comet5',       price = 1145000 }, 
	{name = 'Neon',                   model = 'neon',         price = 1500000 },
	{name = 'Revolter',               model = 'revolter',     price = 1610000 },
	{name = 'Sentinel 3',              model = 'sentinel3',   price = 650000  }
}

module.sportsclassics = {
	{name = 'Btype',                  model = 'btype',        price = 62000   },
	{name = 'Btype Luxe',             model = 'btype3',       price = 85000   },
	{name = 'Btype Hotroad',          model = 'btype2',       price = 155000  },
	{name = 'Casco',                  model = 'casco',        price = 30000   },
	{name = 'Coquette Classic',       model = 'coquette2',    price = 40000   },
	{name = 'Manana',                 model = 'manana',       price = 12800   },
	{name = 'Monroe',                 model = 'monroe',       price = 55000   },
	{name = 'Pigalle',                model = 'pigalle',      price = 20000   },
	{name = 'Stinger',                model = 'stinger',      price = 80000   },
	{name = 'Stinger GT',             model = 'stingergt',    price = 75000   },
	{name = 'Stirling GT',            model = 'feltzer3',     price = 65000   },
	{name = 'Z-Type',                 model = 'ztype',        price = 220000  },
	{name = 'Ardent',                 model = 'ardent',       price = 1150000 },
	{name = 'Retinue',                model = 'retinue',      price = 615000  },
	{name = 'Rapid GT3',              model = 'rapidgt3',     price = 885000  },
	{name = 'Deluxo',                 model = 'deluxo',       price = 4721500 },
	{name = 'Savestra',               model = 'savestra',     price = 990000  }
}

module.sportsclassics2 = {
	{name = 'GT 500',                 model = 'gt500',        price = 785000  },
	{name = 'Z190',                   model = 'z190',         price = 900000  },
	{name = 'Viseris',                model = 'viseris',      price = 875000  },
	{name = 'Senna',                  model = 'senna',        price = 0       }
}

module.super = {
	{name = 'Adder',                  model = 'adder',        price = 900000  },
	{name = 'Banshee 900R',           model = 'banshee2',     price = 255000  },
	{name = 'Bullet',                 model = 'bullet',       price = 90000   },
	{name = 'Cheetah',                model = 'cheetah',      price = 375000  },
	{name = 'Entity XF',              model = 'entityxf',     price = 425000  },
	{name = 'ETR1',                   model = 'sheava',       price = 220000  },
	{name = 'FMJ',                    model = 'fmj',          price = 185000  },
	{name = 'Infernus',               model = 'infernus',     price = 180000  },
	{name = 'Osiris',                 model = 'osiris',       price = 160000  },
	{name = 'Pfister',                model = 'pfister811',   price = 85000   },
	{name = 'RE-7B',                  model = 'le7b',         price = 325000  },
	{name = 'Reaper',                 model = 'reaper',       price = 150000  },
	{name = 'Sultan RS',              model = 'sultanrs',     price = 65000   },
	{name = 'T20',                    model = 't20',          price = 300000  },
	{name = 'Turismo R',              model = 'turismor',     price = 350000  },
	{name = 'Tyrus',                  model = 'tyrus',        price = 600000  },
	{name = 'Vacca',                  model = 'vacca',        price = 120000  }
}

module.super2 = {
	{name = 'Voltic',                 model = 'voltic',       price = 90000   },
	{name = 'X80 Proto',              model = 'prototipo',    price = 2500000 },
	{name = 'Zentorno',               model = 'zentorno',     price = 1500000 },
	{name = 'Voltic 2',               model = 'voltic2',      price = 3830400 },
	{name = 'Oppressor',              model = 'oppressor',    price = 3524500 },
	{name = 'Visione',                model = 'visione',      price = 2250000 },
	{name = 'Cyclone',                model = 'cyclone',      price = 1890000 },
	{name = 'SC 1',                   model = 'sc1',          price = 1603000 },
	{name = 'Autarch',                model = 'autarch',      price = 1955000 }
}

module.muscle = {
	{name = 'Blade',                  model = 'blade',        price = 15000   },
	{name = 'Buccaneer',              model = 'buccaneer',    price = 18000   },
	{name = 'Buccaneer Rider',        model = 'buccaneer2',   price = 24000   },
	{name = 'Chino',                  model = 'chino',        price = 15000   },
	{name = 'Chino Luxe',             model = 'chino2',       price = 19000   },
	{name = 'Coquette BlackFin',      model = 'coquette3',    price = 55000   },
	{name = 'Dominator',              model = 'dominator',    price = 35000   },
	{name = 'Dukes',                  model = 'dukes',        price = 28000   },
	{name = 'Gauntlet',               model = 'gauntlet',     price = 30000   },
	{name = 'Hotknife',               model = 'hotknife',     price = 125000  },
	{name = 'Faction',                model = 'faction',      price = 20000   },
	{name = 'Faction Rider',          model = 'faction2',     price = 30000   },
	{name = 'Faction XL',             model = 'faction3',     price = 40000   },
	{name = 'Nightshade',             model = 'nightshade',   price = 65000   },
	{name = 'Phoenix',                model = 'phoenix',      price = 12500   },
	{name = 'Picador',                model = 'picador',      price = 18000   },
	{name = 'Sabre Turbo',            model = 'sabregt',      price = 20000   }
}

module.muscle2 = {
	{name = 'Sabre GT',               model = 'sabregt2',     price = 25000   },
	{name = 'Slam Van',               model = 'slamvan3',     price = 11500   },
	{name = 'Tampa',                  model = 'tampa',        price = 16000   },
	{name = 'Virgo',                  model = 'virgo',        price = 14000   },
	{name = 'Vigero',                 model = 'vigero',       price = 12500   },
	{name = 'Voodoo',                 model = 'voodoo',       price = 7200    },
	{name = 'Ruiner 2',               model = 'ruiner2',      price = 5745600 },
	{name = 'Yosemite',               model = 'yosemite',     price = 485000  },
	{name = 'Hermes',                 model = 'hermes',       price = 535000  },
	{name = 'Hustler',                model = 'hustler',      price = 625000  }
}

module.offroad = {
	{name = 'Bifta',                  model = 'bifta',        price = 12000   },
	{name = 'Bf Injection',           model = 'bfinjection',  price = 16000   },
	{name = 'Blazer',                 model = 'blazer',       price = 6500    },
	{name = 'Blazer Sport',           model = 'blazer4',      price = 8500    },
	{name = 'Brawler',                model = 'brawler',      price = 45000   },
	{name = 'Bubsta 6x6',             model = 'dubsta3',      price = 120000  },
	{name = 'Dune Buggy',             model = 'dune',         price = 8000    },
	{name = 'Guardian',               model = 'guardian',     price = 45000   },
	{name = 'Rebel',                  model = 'rebel2',       price = 35000   },
	{name = 'Sandking',               model = 'sandking',     price = 55000   },
	{name = 'The Liberator',          model = 'monster',      price = 210000  },
	{name = 'Trophy Truck',           model = 'trophytruck',  price = 60000   },
	{name = 'Trophy Truck Limited',   model = 'trophytruck2', price = 80000   },
	{name = 'Blazer 5',               model = 'blazer5',      price = 1755600 },
	{name = 'Riata',                  model = 'riata',        price = 380000  },
	{name = 'Kamacho',                model = 'kamacho',      price = 345000  }
}

module.suvs = {
	{name = 'Baller',                 model = 'baller2',      price = 40000   },
	{name = 'Baller Sport',           model = 'baller3',      price = 60000   },
	{name = 'Cavalcade',              model = 'cavalcade2',   price = 55000   },
	{name = 'Contender',              model = 'contender',    price = 70000   },
	{name = 'Dubsta',                 model = 'dubsta',       price = 45000   },
	{name = 'Dubsta Luxuary',         model = 'dubsta2',      price = 60000   },
	{name = 'Fhantom',                model = 'fq2',          price = 17000   },
	{name = 'Grabger',                model = 'granger',      price = 50000   },
	{name = 'Gresley',                model = 'gresley',      price = 47500   },
	{name = 'Huntley S',              model = 'huntley',      price = 40000   },
	{name = 'Landstalker',            model = 'landstalker',  price = 35000   },
	{name = 'Mesa',                   model = 'mesa',         price = 16000   },
	{name = 'Mesa Trail',             model = 'mesa3',        price = 40000   },
	{name = 'Patriot',                model = 'patriot',      price = 55000   },
	{name = 'Radius',                 model = 'radi',         price = 29000   },
	{name = 'Rocoto',                 model = 'rocoto',       price = 45000   },
	{name = 'Seminole',               model = 'seminole',     price = 25000   },
	{name = 'XLS',                    model = 'xls',          price = 32000   }
}

module.vans = {
	{name = 'Bison',                  model = 'bison',        price = 45000   },
	{name = 'Bobcat XL',              model = 'bobcatxl',     price = 32000   },
	{name = 'Burrito',                model = 'burrito3',     price = 19000   },
	{name = 'Burrito',                model = 'gburrito2',    price = 29000   },
	{name = 'Camper',                 model = 'camper',       price = 42000   },
	{name = 'Gang Burrito',           model = 'gburrito',     price = 45000   },
	{name = 'Journey',                model = 'journey',      price = 6500    },
	{name = 'Minivan',                model = 'minivan',      price = 13000   },
	{name = 'Moonbeam',               model = 'moonbeam',     price = 18000   },
	{name = 'Moonbeam Rider',         model = 'moonbeam2',    price = 35000   },
	{name = 'Paradise',               model = 'paradise',     price = 19000   },
	{name = 'Rumpo',                  model = 'rumpo',        price = 15000   },
	{name = 'Rumpo Trail',            model = 'rumpo3',       price = 19500   },
	{name = 'Surfer',                 model = 'surfer',       price = 12000   },
	{name = 'Youga',                  model = 'youga',        price = 10800   },
	{name = 'Youga Luxuary',          model = 'youga2',       price = 14500   }
}

module.motorcycles = {
	{name = 'Akuma',                  model = 'AKUMA',        price = 7500    },
	{name = 'Avarus',                 model = 'avarus',       price = 18000   },
	{name = 'Bagger',                 model = 'bagger',       price = 13500   },
	{name = 'Bati 801',               model = 'bati',         price = 12000   },
	{name = 'Bati 801RR',             model = 'bati2',        price = 19000   },
	{name = 'BF400',                  model = 'bf400',        price = 6500    },
	{name = 'BMX (Velo)',             model = 'bmx',          price = 160     },
	{name = 'Carbon RS',              model = 'carbonrs',     price = 18000   },
	{name = 'Chimera',                model = 'chimera',      price = 38000   },
	{name = 'Cliffhanger',            model = 'cliffhanger',  price = 9500    },
	{name = 'Cruiser (Velo)',         model = 'cruiser',      price = 510     },
	{name = 'Daemon',                 model = 'daemon',       price = 11500   },
	{name = 'Daemon High',            model = 'daemon2',      price = 13500   },
	{name = 'Defiler',                model = 'defiler',      price = 9800    },
	{name = 'Double T',               model = 'double',       price = 28000   },
	{name = 'Enduro',                 model = 'enduro',       price = 5500    },
	{name = 'Esskey',                 model = 'esskey',       price = 4200    }
}

module.motorcycles2 = {
	{name = 'Faggio',                 model = 'faggio',       price = 1900    },
	{name = 'Vespa',                  model = 'faggio2',      price = 2800    },
	{name = 'Fixter (Velo)',          model = 'fixter',       price = 225     },
	{name = 'Gargoyle',               model = 'gargoyle',     price = 16500   },
	{name = 'Hakuchou',               model = 'hakuchou',     price = 31000   },
	{name = 'Hakuchou Sport',         model = 'hakuchou2',    price = 55000   },
	{name = 'Hexer',                  model = 'hexer',        price = 12000   },
	{name = 'Innovation',             model = 'innovation',   price = 23500   },
	{name = 'Manchez',                model = 'manchez',      price = 5300    },
	{name = 'Nemesis',                model = 'nemesis',      price = 5800    },
	{name = 'Nightblade',             model = 'nightblade',   price = 35000   },
	{name = 'PCJ-600',                model = 'pcj',          price = 6200    },
	{name = 'Ruffian',                model = 'ruffian',      price = 6800    },
	{name = 'Sanchez',                model = 'sanchez',      price = 5300    },
	{name = 'Sanchez Sport',          model = 'sanchez2',     price = 5300    },
	{name = 'Sanctus',                model = 'sanctus',      price = 25000   },
	{name = 'Scorcher (Velo)',        model = 'scorcher',     price = 280     }
}

module.motorcycles3 = {
	{name = 'Sovereign',              model = 'sovereign',    price = 22000   },
	{name = 'Shotaro Concept',        model = 'shotaro',      price = 320000  },
	{name = 'Thrust',                 model = 'thrust',       price = 24000   },
	{name = 'Tri bike (Velo)',        model = 'tribike3',     price = 520     },
	{name = 'Vader',                  model = 'vader',        price = 7200    },
	{name = 'Vortex',                 model = 'vortex',       price = 9800    },
	{name = 'Woflsbane',              model = 'wolfsbane',    price = 9000    },
	{name = 'Zombie',                 model = 'zombiea',      price = 9500    },
	{name = 'Zombie Luxuary',         model = 'zombieb',      price = 12000   }
}

module.sellableVehicles = {
	{name = 'Blade',                  model = 'blade',        price = 15000,   category = 'muscle'},
	{name = 'Buccaneer',              model = 'buccaneer',    price = 18000,   category = 'muscle'},
	{name = 'Buccaneer Rider',        model = 'buccaneer2',   price = 24000,   category = 'muscle'},
	{name = 'Chino',                  model = 'chino',        price = 15000,   category = 'muscle'},
	{name = 'Chino Luxe',             model = 'chino2',       price = 19000,   category = 'muscle'},
	{name = 'Coquette BlackFin',      model = 'coquette3',    price = 55000,   category = 'muscle'},
	{name = 'Dominator',              model = 'dominator',    price = 35000,   category = 'muscle'},
	{name = 'Dukes',                  model = 'dukes',        price = 28000,   category = 'muscle'},
	{name = 'Gauntlet',               model = 'gauntlet',     price = 30000,   category = 'muscle'},
	{name = 'Hotknife',               model = 'hotknife',     price = 125000,  category = 'muscle'},
	{name = 'Faction',                model = 'faction',      price = 20000,   category = 'muscle'},
	{name = 'Faction Rider',          model = 'faction2',     price = 30000,   category = 'muscle'},
	{name = 'Faction XL',             model = 'faction3',     price = 40000,   category = 'muscle'},
	{name = 'Nightshade',             model = 'nightshade',   price = 65000,   category = 'muscle'},
	{name = 'Phoenix',                model = 'phoenix',      price = 12500,   category = 'muscle'},
	{name = 'Picador',                model = 'picador',      price = 18000,   category = 'muscle'},
	{name = 'Sabre Turbo',            model = 'sabregt',      price = 20000,   category = 'muscle'},
	{name = 'Sabre GT',               model = 'sabregt2',     price = 25000,   category = 'muscle'},
	{name = 'Slam Van',               model = 'slamvan3',     price = 11500,   category = 'muscle'},
	{name = 'Tampa',                  model = 'tampa',        price = 16000,   category = 'muscle'},
	{name = 'Virgo',                  model = 'virgo',        price = 14000,   category = 'muscle'},
	{name = 'Vigero',                 model = 'vigero',       price = 12500,   category = 'muscle'},
	{name = 'Voodoo',                 model = 'voodoo',       price = 7200,    category = 'muscle'},
	{name = 'Blista',                 model = 'blista',       price = 8000,    category = 'compacts'},
	{name = 'Brioso R/A',             model = 'brioso',       price = 18000,   category = 'compacts'},
	{name = 'Issi',                   model = 'issi2',        price = 10000,   category = 'compacts'},
	{name = 'Panto',                  model = 'panto',        price = 10000,   category = 'compacts'},
	{name = 'Prairie',                model = 'prairie',      price = 12000,   category = 'compacts'},
	{name = 'Bison',                  model = 'bison',        price = 45000,   category = 'vans'},
	{name = 'Bobcat XL',              model = 'bobcatxl',     price = 32000,   category = 'vans'},
	{name = 'Burrito',                model = 'burrito3',     price = 19000,   category = 'vans'},
	{name = 'Burrito',                model = 'gburrito2',    price = 29000,   category = 'vans'},
	{name = 'Camper',                 model = 'camper',       price = 42000,   category = 'vans'},
	{name = 'Gang Burrito',           model = 'gburrito',     price = 45000,   category = 'vans'},
	{name = 'Journey',                model = 'journey',      price = 6500,    category = 'vans'},
	{name = 'Minivan',                model = 'minivan',      price = 13000,   category = 'vans'},
	{name = 'Moonbeam',               model = 'moonbeam',     price = 18000,   category = 'vans'},
	{name = 'Moonbeam Rider',         model = 'moonbeam2',    price = 35000,   category = 'vans'},
	{name = 'Paradise',               model = 'paradise',     price = 19000,   category = 'vans'},
	{name = 'Rumpo',                  model = 'rumpo',        price = 15000,   category = 'vans'},
	{name = 'Rumpo Trail',            model = 'rumpo3',       price = 19500,   category = 'vans'},
	{name = 'Surfer',                 model = 'surfer',       price = 12000,   category = 'vans'},
	{name = 'Youga',                  model = 'youga',        price = 10800,   category = 'vans'},
	{name = 'Youga Luxuary',          model = 'youga2',       price = 14500,   category = 'vans'},
	{name = 'Asea',                   model = 'asea',         price = 5500,    category = 'sedans'},
	{name = 'Cognoscenti',            model = 'cognoscenti',  price = 55000,   category = 'sedans'},
	{name = 'Emperor',                model = 'emperor',      price = 8500,    category = 'sedans'},
	{name = 'Fugitive',               model = 'fugitive',     price = 12000,   category = 'sedans'},
	{name = 'Glendale',               model = 'glendale',     price = 6500,    category = 'sedans'},
	{name = 'Intruder',               model = 'intruder',     price = 7500,    category = 'sedans'},
	{name = 'Premier',                model = 'premier',      price = 8000,    category = 'sedans'},
	{name = 'Primo Custom',           model = 'primo2',       price = 14000,   category = 'sedans'},
	{name = 'Regina',                 model = 'regina',       price = 5000,    category = 'sedans'},
	{name = 'Schafter',               model = 'schafter2',    price = 25000,   category = 'sedans'},
	{name = 'Stretch',                model = 'stretch',      price = 90000,   category = 'sedans'},
	{name = 'Super Diamond',          model = 'superd',       price = 130000,  category = 'sedans'},
	{name = 'Tailgater',              model = 'tailgater',    price = 30000,   category = 'sedans'},
	{name = 'Warrener',               model = 'warrener',     price = 4000,    category = 'sedans'},
	{name = 'Washington',             model = 'washington',   price = 9000,    category = 'sedans'},
	{name = 'Baller',                 model = 'baller2',      price = 40000,   category = 'suvs'},
	{name = 'Baller Sport',           model = 'baller3',      price = 60000,   category = 'suvs'},
	{name = 'Cavalcade',              model = 'cavalcade2',   price = 55000,   category = 'suvs'},
	{name = 'Contender',              model = 'contender',    price = 70000,   category = 'suvs'},
	{name = 'Dubsta',                 model = 'dubsta',       price = 45000,   category = 'suvs'},
	{name = 'Dubsta Luxuary',         model = 'dubsta2',      price = 60000,   category = 'suvs'},
	{name = 'Fhantom',                model = 'fq2',          price = 17000,   category = 'suvs'},
	{name = 'Grabger',                model = 'granger',      price = 50000,   category = 'suvs'},
	{name = 'Gresley',                model = 'gresley',      price = 47500,   category = 'suvs'},
	{name = 'Huntley S',              model = 'huntley',      price = 40000,   category = 'suvs'},
	{name = 'Landstalker',            model = 'landstalker',  price = 35000,   category = 'suvs'},
	{name = 'Mesa',                   model = 'mesa',         price = 16000,   category = 'suvs'},
	{name = 'Mesa Trail',             model = 'mesa3',        price = 40000,   category = 'suvs'},
	{name = 'Patriot',                model = 'patriot',      price = 55000,   category = 'suvs'},
	{name = 'Radius',                 model = 'radi',         price = 29000,   category = 'suvs'},
	{name = 'Rocoto',                 model = 'rocoto',       price = 45000,   category = 'suvs'},
	{name = 'Seminole',               model = 'seminole',     price = 25000,   category = 'suvs'},
	{name = 'XLS',                    model = 'xls',          price = 32000,   category = 'suvs'},
	{name = 'Btype',                  model = 'btype',        price = 62000,   category = 'sportsclassics'},
	{name = 'Btype Luxe',             model = 'btype3',       price = 85000,   category = 'sportsclassics'},
	{name = 'Btype Hotroad',          model = 'btype2',       price = 155000,  category = 'sportsclassics'},
	{name = 'Casco',                  model = 'casco',        price = 30000,   category = 'sportsclassics'},
	{name = 'Coquette Classic',       model = 'coquette2',    price = 40000,   category = 'sportsclassics'},
	{name = 'Manana',                 model = 'manana',       price = 12800,   category = 'sportsclassics'},
	{name = 'Monroe',                 model = 'monroe',       price = 55000,   category = 'sportsclassics'},
	{name = 'Pigalle',                model = 'pigalle',      price = 20000,   category = 'sportsclassics'},
	{name = 'Stinger',                model = 'stinger',      price = 80000,   category = 'sportsclassics'},
	{name = 'Stinger GT',             model = 'stingergt',    price = 75000,   category = 'sportsclassics'},
	{name = 'Stirling GT',            model = 'feltzer3',     price = 65000,   category = 'sportsclassics'},
	{name = 'Z-Type',                 model = 'ztype',        price = 220000,  category = 'sportsclassics'},
	{name = 'Bifta',                  model = 'bifta',        price = 12000,   category = 'offroad'},
	{name = 'Bf Injection',           model = 'bfinjection',  price = 16000,   category = 'offroad'},
	{name = 'Blazer',                 model = 'blazer',       price = 6500,    category = 'offroad'},
	{name = 'Blazer Sport',           model = 'blazer4',      price = 8500,    category = 'offroad'},
	{name = 'Brawler',                model = 'brawler',      price = 45000,   category = 'offroad'},
	{name = 'Bubsta 6x6',             model = 'dubsta3',      price = 120000,  category = 'offroad'},
	{name = 'Dune Buggy',             model = 'dune',         price = 8000,    category = 'offroad'},
	{name = 'Guardian',               model = 'guardian',     price = 45000,   category = 'offroad'},
	{name = 'Rebel',                  model = 'rebel2',       price = 35000,   category = 'offroad'},
	{name = 'Sandking',               model = 'sandking',     price = 55000,   category = 'offroad'},
	{name = 'The Liberator',          model = 'monster',      price = 210000,  category = 'offroad'},
	{name = 'Trophy Truck',           model = 'trophytruck',  price = 60000,   category = 'offroad'},
	{name = 'Trophy Truck Limited',   model = 'trophytruck2', price = 80000,   category = 'offroad'},
	{name = 'Cognoscenti Cabrio',     model = 'cogcabrio',    price = 55000,   category = 'coupes'},
	{name = 'Exemplar',               model = 'exemplar',     price = 32000,   category = 'coupes'},
	{name = 'F620',                   model = 'f620',         price = 40000,   category = 'coupes'},
	{name = 'Felon',                  model = 'felon',        price = 42000,   category = 'coupes'},
	{name = 'Felon GT',               model = 'felon2',       price = 55000,   category = 'coupes'},
	{name = 'Jackal',                 model = 'jackal',       price = 38000,   category = 'coupes'},
	{name = 'Oracle XS',              model = 'oracle2',      price = 35000,   category = 'coupes'},
	{name = 'Sentinel',               model = 'sentinel',     price = 32000,   category = 'coupes'},
	{name = 'Sentinel XS',            model = 'sentinel2',    price = 40000,   category = 'coupes'},
	{name = 'Windsor',                model = 'windsor',      price = 95000,   category = 'coupes'},
	{name = 'Windsor Drop',           model = 'windsor2',     price = 125000,  category = 'coupes'},
	{name = 'Zion',                   model = 'zion',         price = 36000,   category = 'coupes'},
	{name = 'Zion Cabrio',            model = 'zion2',        price = 45000,   category = 'coupes'},
	{name = '9F',                     model = 'ninef',        price = 65000,   category = 'sports'},
	{name = '9F Cabrio',              model = 'ninef2',       price = 80000,   category = 'sports'},
	{name = 'Alpha',                  model = 'alpha',        price = 60000,   category = 'sports'},
	{name = 'Banshee',                model = 'banshee',      price = 70000,   category = 'sports'},
	{name = 'Bestia GTS',             model = 'bestiagts',    price = 55000,   category = 'sports'},
	{name = 'Buffalo',                model = 'buffalo',      price = 12000,   category = 'sports'},
	{name = 'Buffalo S',              model = 'buffalo2',     price = 20000,   category = 'sports'},
	{name = 'Carbonizzare',           model = 'carbonizzare', price = 75000,   category = 'sports'},
	{name = 'Comet',                  model = 'comet2',       price = 65000,   category = 'sports'},
	{name = 'Coquette',               model = 'coquette',     price = 65000,   category = 'sports'},
	{name = 'Drift Tampa',            model = 'tampa2',       price = 80000,   category = 'sports'},
	{name = 'Elegy',                  model = 'elegy2',       price = 38500,   category = 'sports'},
	{name = 'Feltzer',                model = 'feltzer2',     price = 55000,   category = 'sports'},
	{name = 'Furore GT',              model = 'furoregt',     price = 45000,   category = 'sports'},
	{name = 'Fusilade',               model = 'fusilade',     price = 40000,   category = 'sports'},
	{name = 'Jester',                 model = 'jester',       price = 65000,   category = 'sports'},
	{name = 'Jester(Racecar)',        model = 'jester2',      price = 135000,  category = 'sports'},
	{name = 'Khamelion',              model = 'khamelion',    price = 38000,   category = 'sports'},
	{name = 'Kuruma',                 model = 'kuruma',       price = 30000,   category = 'sports'},
	{name = 'Lynx',                   model = 'lynx',         price = 40000,   category = 'sports'},
	{name = 'Mamba',                  model = 'mamba',        price = 70000,   category = 'sports'},
	{name = 'Massacro',               model = 'massacro',     price = 65000,   category = 'sports'},
	{name = 'Massacro(Racecar)',      model = 'massacro2',    price = 130000,  category = 'sports'},
	{name = 'Omnis',                  model = 'omnis',        price = 35000,   category = 'sports'},
	{name = 'Penumbra',               model = 'penumbra',     price = 28000,   category = 'sports'},
	{name = 'Rapid GT',               model = 'rapidgt',      price = 35000,   category = 'sports'},
	{name = 'Rapid GT Convertible',   model = 'rapidgt2',     price = 45000,   category = 'sports'},
	{name = 'Schafter V12',           model = 'schafter3',    price = 50000,   category = 'sports'},
	{name = 'Seven 70',               model = 'seven70',      price = 39500,   category = 'sports'},
	{name = 'Sultan',                 model = 'sultan',       price = 15000,   category = 'sports'},
	{name = 'Surano',                 model = 'surano',       price = 50000,   category = 'sports'},
	{name = 'Tropos',                 model = 'tropos',       price = 40000,   category = 'sports'},
	{name = 'Verlierer',              model = 'verlierer2',   price = 70000,   category = 'sports'},
	{name = 'Adder',                  model = 'adder',        price = 900000,  category = 'super'},
	{name = 'Banshee 900R',           model = 'banshee2',     price = 255000,  category = 'super'},
	{name = 'Bullet',                 model = 'bullet',       price = 90000,   category = 'super'},
	{name = 'Cheetah',                model = 'cheetah',      price = 375000,  category = 'super'},
	{name = 'Entity XF',              model = 'entityxf',     price = 425000,  category = 'super'},
	{name = 'ETR1',                   model = 'sheava',       price = 220000,  category = 'super'},
	{name = 'FMJ',                    model = 'fmj',          price = 185000,  category = 'super'},
	{name = 'Infernus',               model = 'infernus',     price = 180000,  category = 'super'},
	{name = 'Osiris',                 model = 'osiris',       price = 160000,  category = 'super'},
	{name = 'Pfister',                model = 'pfister811',   price = 85000,   category = 'super'},
	{name = 'RE-7B',                  model = 'le7b',         price = 325000,  category = 'super'},
	{name = 'Reaper',                 model = 'reaper',       price = 150000,  category = 'super'},
	{name = 'Sultan RS',              model = 'sultanrs',     price = 65000,   category = 'super'},
	{name = 'T20',                    model = 't20',          price = 300000,  category = 'super'},
	{name = 'Turismo R',              model = 'turismor',     price = 350000,  category = 'super'},
	{name = 'Tyrus',                  model = 'tyrus',        price = 600000,  category = 'super'},
	{name = 'Vacca',                  model = 'vacca',        price = 120000,  category = 'super'},
	{name = 'Voltic',                 model = 'voltic',       price = 90000,   category = 'super'},
	{name = 'X80 Proto',              model = 'prototipo',    price = 2500000, category = 'super'},
	{name = 'Zentorno',               model = 'zentorno',     price = 1500000, category = 'super'},
	{name = 'Akuma',                  model = 'AKUMA',        price = 7500,    category = 'motorcycles'},
	{name = 'Avarus',                 model = 'avarus',       price = 18000,   category = 'motorcycles'},
	{name = 'Bagger',                 model = 'bagger',       price = 13500,   category = 'motorcycles'},
	{name = 'Bati 801',               model = 'bati',         price = 12000,   category = 'motorcycles'},
	{name = 'Bati 801RR',             model = 'bati2',        price = 19000,   category = 'motorcycles'},
	{name = 'BF400',                  model = 'bf400',        price = 6500,    category = 'motorcycles'},
	{name = 'BMX (Velo)',             model = 'bmx',          price = 160,     category = 'motorcycles'},
	{name = 'Carbon RS',              model = 'carbonrs',     price = 18000,   category = 'motorcycles'},
	{name = 'Chimera',                model = 'chimera',      price = 38000,   category = 'motorcycles'},
	{name = 'Cliffhanger',            model = 'cliffhanger',  price = 9500,    category = 'motorcycles'},
	{name = 'Cruiser (Velo)',         model = 'cruiser',      price = 510,     category = 'motorcycles'},
	{name = 'Daemon',                 model = 'daemon',       price = 11500,   category = 'motorcycles'},
	{name = 'Daemon High',            model = 'daemon2',      price = 13500,   category = 'motorcycles'},
	{name = 'Defiler',                model = 'defiler',      price = 9800,    category = 'motorcycles'},
	{name = 'Double T',               model = 'double',       price = 28000,   category = 'motorcycles'},
	{name = 'Enduro',                 model = 'enduro',       price = 5500,    category = 'motorcycles'},
	{name = 'Esskey',                 model = 'esskey',       price = 4200,    category = 'motorcycles'},
	{name = 'Faggio',                 model = 'faggio',       price = 1900,    category = 'motorcycles'},
	{name = 'Vespa',                  model = 'faggio2',      price = 2800,    category = 'motorcycles'},
	{name = 'Fixter (Velo)',          model = 'fixter',       price = 225,     category = 'motorcycles'},
	{name = 'Gargoyle',               model = 'gargoyle',     price = 16500,   category = 'motorcycles'},
	{name = 'Hakuchou',               model = 'hakuchou',     price = 31000,   category = 'motorcycles'},
	{name = 'Hakuchou Sport',         model = 'hakuchou2',    price = 55000,   category = 'motorcycles'},
	{name = 'Hexer',                  model = 'hexer',        price = 12000,   category = 'motorcycles'},
	{name = 'Innovation',             model = 'innovation',   price = 23500,   category = 'motorcycles'},
	{name = 'Manchez',                model = 'manchez',      price = 5300,    category = 'motorcycles'},
	{name = 'Nemesis',                model = 'nemesis',      price = 5800,    category = 'motorcycles'},
	{name = 'Nightblade',             model = 'nightblade',   price = 35000,   category = 'motorcycles'},
	{name = 'PCJ-600',                model = 'pcj',          price = 6200,    category = 'motorcycles'},
	{name = 'Ruffian',                model = 'ruffian',      price = 6800,    category = 'motorcycles'},
	{name = 'Sanchez',                model = 'sanchez',      price = 5300,    category = 'motorcycles'},
	{name = 'Sanchez Sport',          model = 'sanchez2',     price = 5300,    category = 'motorcycles'},
	{name = 'Sanctus',                model = 'sanctus',      price = 25000,   category = 'motorcycles'},
	{name = 'Scorcher (Velo)',        model = 'scorcher',     price = 280,     category = 'motorcycles'},
	{name = 'Sovereign',              model = 'sovereign',    price = 22000,   category = 'motorcycles'},
	{name = 'Shotaro Concept',        model = 'shotaro',      price = 320000,  category = 'motorcycles'},
	{name = 'Thrust',                 model = 'thrust',       price = 24000,   category = 'motorcycles'},
	{name = 'Tri bike (Velo)',        model = 'tribike3',     price = 520,     category = 'motorcycles'},
	{name = 'Vader',                  model = 'vader',        price = 7200,    category = 'motorcycles'},
	{name = 'Vortex',                 model = 'vortex',       price = 9800,    category = 'motorcycles'},
	{name = 'Woflsbane',              model = 'wolfsbane',    price = 9000,    category = 'motorcycles'},
	{name = 'Zombie',                 model = 'zombiea',      price = 9500,    category = 'motorcycles'},
	{name = 'Zombie Luxuary',         model = 'zombieb',      price = 12000,   category = 'motorcycles'},
	{name = 'blazer5',                model = 'blazer5',      price = 1755600, category = 'offroad'},
	{name = 'Ruiner 2',               model = 'ruiner2',      price = 5745600, category = 'muscle'},
	{name = 'Voltic 2',               model = 'voltic2',      price = 3830400, category = 'super'},
	{name = 'Ardent',                 model = 'ardent',       price = 1150000, category = 'sportsclassics'},
	{name = 'Oppressor',              model = 'oppressor',    price = 3524500, category = 'super'},
	{name = 'Visione',                model = 'visione',      price = 2250000, category = 'super'},
	{name = 'Retinue',                model = 'retinue',      price = 615000,  category = 'sportsclassics'},
	{name = 'Cyclone',                model = 'cyclone',      price = 1890000, category = 'super'}, 
	{name = 'Rapid GT3',              model = 'rapidgt3',     price = 885000,  category = 'sportsclassics'},
	{name = 'raiden',                 model = 'raiden',       price = 1375000, category = 'sports'},
	{name = 'Yosemite',               model = 'yosemite',     price = 485000,  category = 'muscle'},
	{name = 'Deluxo',                 model = 'deluxo',       price = 4721500, category = 'sportsclassics'},
	{name = 'Pariah',                 model = 'pariah',       price = 1420000, category = 'sports'},
	{name = 'Stromberg',              model = 'stromberg',    price = 3185350, category = 'sports'},
	{name = 'SC 1',                   model = 'sc1',          price = 1603000, category = 'super'},
	{name = 'riata',                  model = 'riata',        price = 380000,  category = 'offroad'},
	{name = 'Hermes',                 model = 'hermes',       price = 535000,  category = 'muscle'},
	{name = 'Savestra',               model = 'savestra',     price = 990000,  category = 'sportsclassics'},
	{name = 'Streiter',               model = 'streiter',     price = 500000,  category = 'sports'},
	{name = 'Kamacho',                model = 'kamacho',      price = 345000,  category = 'offroad'},
	{name = 'GT 500',                 model = 'gt500',        price = 785000,  category = 'sportsclassics'},
	{name = 'Z190',                   model = 'z190',         price = 900000,  category = 'sportsclassics'},
	{name = 'Viseris',                model = 'viseris',      price = 875000,  category = 'sportsclassics'},
	{name = 'Autarch',                model = 'autarch',      price = 1955000, category = 'super'},
	{name = 'Comet 5',                model = 'comet5',       price = 1145000, category = 'sports'}, 
	{name = 'Neon',                   model = 'neon',         price = 1500000, category = 'sports'},
	{name = 'Revolter',               model = 'revolter',     price = 1610000, category = 'sports'},
	{name = 'Sentinel3',              model = 'sentinel3',    price = 650000,  category = 'sports'},
	{name = 'Hustler',                model = 'hustler',      price = 625000,  category = 'muscle'}
}

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
	pos     = vector3(-28.6, -1085.6, 25.5),
	heading = 330.0
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

	-- Citizen.CreateThread(function()
	-- 	local blip2 = AddBlipForCoord(module.zones.shopSell.pos)
	
	-- 	SetBlipSprite (blip2, 326)
	-- 	SetBlipDisplay(blip2, 4)
	-- 	SetBlipScale  (blip2, 0.75)
	-- 	SetBlipAsShortRange(blip2, true)
	
	-- 	BeginTextCommandSetBlipName('STRING')
	-- 	AddTextComponentSubstringPlayerName("Car Resell")
	-- 	EndTextCommandSetBlipName(blip2)
	-- 	SetBlipColour (blip2,6)
	-- end)

	request("vehicleshop:storeAllVehicles", function(result)
		if result then
			print("Stored all vehicles.")
		end
	end)

	-- request("vehicleshop:getCompactsCoupes", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getCoupesSedans", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSports", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSports2", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSports3", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSportsClassics", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSportsClassics2", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSuper", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSuper2", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getMuscle", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getMuscle2", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getOffroad", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getSUVs", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getVans", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getMotorcycles", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getMotorcycles2", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)

	-- request("vehicleshop:getMotorcycles3", function(result)
	-- 	if result then
	-- 		print("Stored all vehicles.")
	-- 	end
	-- end)
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
			module.ReturnPlayer()
			camera.destroy()
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
