StartDebug()
local mk = require("multikey")
local get, put = mk.get, mk.put

--TODO : Aplicar el efecto a los projectiles enemigos, quitándoles atributos
--			como homing, disminuyendo su tamaño y velocidad.
--TODO : Que funcione con bosses, pero si lo usas con un boss
--			la carga pasa a ser 6 hasta que lo uses de nuevo, entonces vuelve a 2.
--			Se podría hacer algo parecido al Glass Cannon (cambiar al activo que simboliza el mismo item roto).
--TODO : Aplicar God's Flesh a enemigos que sean imposibles de reducir más.
--TODO : Cambiar Dark Esau a Evil Twin pero asegurarse de que funciona bien y de que
--			Dark Esau respawnea en la siguiente habitación.
--TODO : Efecto Flat file (no spikes) en la habitación al usarla. No se guarda.
--TODO : Efecto Retro Vision si se usa en habitación vacía
--TODO : Al transformar un boss en un enemigo normal con mucha vida, ponerle la barra de spider mod
local mod = RegisterMod( "Downgrader", 1);
local CenterV = Vector(640, 580)

local DG_t1stEnemy = {
			EntityType.ENTITY_BOMBDROP,
			EntityType.ENTITY_BOMBDROP,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_RING_OF_FLIES,
			EntityType.ENTITY_DART_FLY,
			EntityType.ENTITY_SWARM,
			EntityType.ENTITY_HUSH_FLY,
			EntityType.ENTITY_MOTER,
			EntityType.ENTITY_FLY_L2,
			EntityType.ENTITY_FULL_FLY,
			EntityType.ENTITY_SUCKER,
			EntityType.ENTITY_POOTER,
			EntityType.ENTITY_BOOMFLY,
			EntityType.ENTITY_BOOMFLY,
			
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_SQUIRT,
			EntityType.ENTITY_SQUIRT,
			EntityType.ENTITY_DINGA,
			
			EntityType.ENTITY_BIGSPIDER,
			EntityType.ENTITY_HOPPER, -- Trite
			EntityType.ENTITY_SPIDER_L2,
			EntityType.ENTITY_RAGLING,
			EntityType.ENTITY_RAGLING, --De Ragman
			EntityType.ENTITY_BLISTER,
			EntityType.ENTITY_TICKING_SPIDER,
			EntityType.ENTITY_BABY_LONG_LEGS,
			EntityType.ENTITY_CRAZY_LONG_LEGS,
			EntityType.ENTITY_BLIND_CREEP,
			EntityType.ENTITY_THE_THING,
			EntityType.ENTITY_RAGE_CREEP,
			
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_HUSH_BOIL,
			EntityType.ENTITY_WALKINGBOIL,
			EntityType.ENTITY_WALKINGBOIL,
			EntityType.ENTITY_NIGHT_CRAWLER,
			EntityType.ENTITY_ROUNDY,
			EntityType.ENTITY_PARA_BITE,
			
			EntityType.ENTITY_MULLIGAN,
			EntityType.ENTITY_HIVE,
			EntityType.ENTITY_HIVE,
			EntityType.ENTITY_SWARMER,
			EntityType.ENTITY_NEST,
			
			EntityType.ENTITY_FLAMINGHOPPER,
			EntityType.ENTITY_LEAPER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_BLACK_GLOBIN_BODY,
			EntityType.ENTITY_SPLASHER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_CYCLOPIA,
			EntityType.ENTITY_HUSH_GAPER,
			EntityType.ENTITY_GREED_GAPER,
			EntityType.ENTITY_GURGLE,
			EntityType.ENTITY_NULLS,
			EntityType.ENTITY_SKINNY,
			
			EntityType.ENTITY_MRMAW, 
			EntityType.ENTITY_MAW, -- Psy Maw
			EntityType.ENTITY_PSY_HORF,
			EntityType.ENTITY_MAW, -- Maw
			EntityType.ENTITY_MAW, -- Red Maw
			
			EntityType.ENTITY_BLACK_BONY,
			EntityType.ENTITY_FLESH_DEATHS_HEAD,
			
			EntityType.ENTITY_FAT_BAT,
			
			EntityType.ENTITY_WIZOOB,
			EntityType.ENTITY_RED_GHOST,
			
			EntityType.ENTITY_CONJOINED_FATTY,
			EntityType.ENTITY_FATTY,
			EntityType.ENTITY_BLUBBER,
			EntityType.ENTITY_CONJOINED_FATTY,
			EntityType.ENTITY_FAT_SACK,
			
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_BLACK_GLOBIN,
			
			EntityType.ENTITY_KNIGHT,
			EntityType.ENTITY_FLOATING_KNIGHT,
			EntityType.ENTITY_BONE_KNIGHT,
			
			EntityType.ENTITY_CLOTTY,
			EntityType.ENTITY_MEGA_CLOTTY,
			
			EntityType.ENTITY_MOMS_DEAD_HAND,
			
			EntityType.ENTITY_SPITY,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_CONJOINED_SPITTY,
			EntityType.ENTITY_GRUB,
			
			EntityType.ENTITY_CAMILLO_JR,
			EntityType.ENTITY_PSY_TUMOR,
			EntityType.ENTITY_MEMBRAIN,
			EntityType.ENTITY_MEMBRAIN,
			EntityType.ENTITY_GUTS,
			
			EntityType.ENTITY_PARA_BITE,
			EntityType.ENTITY_COD_WORM,
			EntityType.ENTITY_LEECH,
			EntityType.ENTITY_LEECH,
			
			EntityType.ENTITY_MOBILE_HOST,
			EntityType.ENTITY_HOST,
			EntityType.ENTITY_FLESH_MOBILE_HOST,
			EntityType.ENTITY_MEATBALL,
			
			EntityType.ENTITY_NERVE_ENDING,
			
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			
			EntityType.ENTITY_EYE,
			
			EntityType.ENTITY_DOPLE,
			
			EntityType.ENTITY_BABY,
			
			EntityType.ENTITY_BEGOTTEN,
			
			EntityType.ENTITY_HANGER,
			
			EntityType.ENTITY_STONEHEAD,
			EntityType.ENTITY_BRIMSTONE_HEAD,
			EntityType.ENTITY_STONE_EYE,
			EntityType.ENTITY_GAPING_MAW,
			
			EntityType.ENTITY_BLACK_MAW,
			
			EntityType.ENTITY_BLASTOCYST_MEDIUM,
			EntityType.ENTITY_BLASTOCYST_SMALL,
			EntityType.ENTITY_FISTULA_MEDIUM,
			EntityType.ENTITY_FISTULA_SMALL,
			EntityType.ENTITY_FISTULA_MEDIUM,
			EntityType.ENTITY_FISTULA_SMALL,
			
			EntityType.ENTITY_FIREPLACE,
			EntityType.ENTITY_FIREPLACE
			
			EntityType.ENTITY_POOTER
			
			}

local DG_t2ndEnemy = {
			EntityType.ENTITY_PICKUP,
			EntityType.ENTITY_BOMBDROP,
			EntityType.ENTITY_FLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_FLY_L2,
			EntityType.ENTITY_SUCKER,
			EntityType.ENTITY_POOTER,
			EntityType.ENTITY_BOOMFLY,
			EntityType.ENTITY_BOOMFLY,
			
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_SQUIRT,
			EntityType.ENTITY_SQUIRT,
			
			EntityType.ENTITY_SPIDER,
			EntityType.ENTITY_SPIDER,
			EntityType.ENTITY_SPIDER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_SPIDER_L2,
			EntityType.ENTITY_BABY_LONG_LEGS,
			EntityType.ENTITY_CRAZY_LONG_LEGS,
			EntityType.ENTITY_WALL_CREEP,
			EntityType.ENTITY_WALL_CREEP,
			EntityType.ENTITY_BLIND_CREEP,
			
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			
			EntityType.ENTITY_ROUND_WORM,
			EntityType.ENTITY_ROUND_WORM,
			EntityType.ENTITY_ROUND_WORM,
			
			EntityType.ENTITY_MULLIGAN,
			EntityType.ENTITY_MULLIGAN,
			817, --Prey
			EntityType.ENTITY_DUKIE,
			EntityType.ENTITY_MULLIGAN,
			
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_CYCLOPIA,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_SKINNY,
			
			EntityType.ENTITY_MAW,
			EntityType.ENTITY_MAW,
			EntityType.ENTITY_HORF,
			EntityType.ENTITY_HORF,
			EntityType.ENTITY_HORF,
			
			EntityType.ENTITY_BONY,
			EntityType.ENTITY_DEATHS_HEAD,
			
			EntityType.ENTITY_ONE_TOOTH,
			
			EntityType.ENTITY_ROUND_WORM,
			EntityType.ENTITY_WIZOOB,
			
			EntityType.ENTITY_FATTY,
			EntityType.ENTITY_FATTY,
			EntityType.ENTITY_HALF_SACK,
			EntityType.ENTITY_CONJOINED_FATTY,
			EntityType.ENTITY_FATTY,
			
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_GLOBIN,
			
			EntityType.ENTITY_KNIGHT,
			EntityType.ENTITY_KNIGHT,
			EntityType.ENTITY_KNIGHT,
			
			EntityType.ENTITY_CLOTTY,
			EntityType.ENTITY_CLOTTY,
			
			EntityType.ENTITY_MOMS_HAND,
			
			EntityType.ENTITY_MAGGOT,
			EntityType.ENTITY_MAGGOT,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_SPITY,
			EntityType.ENTITY_CHARGER,
			
			EntityType.ENTITY_PSY_TUMOR,
			EntityType.ENTITY_TUMOR,
			EntityType.ENTITY_BRAIN,
			EntityType.ENTITY_GUTS,
			EntityType.ENTITY_GUTS,
			
			EntityType.ENTITY_PARA_BITE,
			EntityType.ENTITY_PARA_BITE,
			EntityType.ENTITY_LEECH,
			EntityType.ENTITY_LEECH,
			
			EntityType.ENTITY_HOST,
			EntityType.ENTITY_HOST,
			EntityType.ENTITY_MOBILE_HOST,
			EntityType.ENTITY_HOST,
			
			EntityType.ENTITY_NERVE_ENDING,
			
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			
			EntityType.ENTITY_EYE,
			
			EntityType.ENTITY_DOPLE,
			
			EntityType.ENTITY_BABY,
			
			EntityType.ENTITY_HOMUNCULUS,
			
			EntityType.ENTITY_KEEPER,
			
			EntityType.ENTITY_STONEHEAD,
			EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
			EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
			EntityType.ENTITY_BROKEN_GAPING_MAW,
			
			EntityType.ENTITY_OOB,
			
			EntityType.ENTITY_BLASTOCYST_SMALL,
			EntityType.ENTITY_EMBRYO,
			EntityType.ENTITY_FISTULA_SMALL,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_FISTULA_SMALL,
			EntityType.ENTITY_SPIDER,
			
			EntityType.ENTITY_FIREPLACE,
			EntityType.ENTITY_FIREPLACE
			}

local DG_t1stVar = {
			3, -- Troll Bomb
			4, -- Super Troll Bomb
			0, -- Attack Fly
			0, -- Ring Fly
			0, -- Dart Fly
			0, -- Swarm Fly
			0, -- Hush Fly
			0, -- Moter
			0, -- Lvl2 Fly
			0, -- Full Fly
			1, -- Spit
			1, -- Super Pooter
			1, -- Red Boom Fly
			2, -- Drowned Boom Fly
			
			1, -- Corn Dip
			2, -- Brownie Dip
			0, -- Squirt
			1, -- Dank Squirt
			0, -- Dinga
			
			0, -- Big Spider
			1, -- Trite
			0, -- Lvl 2 Spider
			0, -- Ragling
			1, -- Ragman's Ragling
			0, -- Blister
			0, -- Ticking Spider
			0, -- Baby Long Legs
			0, -- Crazy Long Legs
			0, -- Blind Creep
			0, -- The Thing
			0, -- Rage Creep
			
			1, -- Gut
			2, -- Sack
			0, -- Hush Boil
			1, -- Walking Gut
			2, -- Walking Sack
			
			0, -- Night Crawler
			0, -- Roundy
			0, -- Para-Bite
			
			2, -- Mulliboom
			0, -- Hive
			1, -- Drowned Hive
			0, -- Swarmer
			0, -- Nest
			
			0, -- Flaming Hopper
			0, -- Leaper
			0, -- Gusher
			0, -- Black Globin's Body
			0, -- Splasher
			0, -- Frowning Gaper
			0, -- Cyclopia
			0, -- Hush Gaper
			0, -- Greed Gaper
			0, -- Gurgle
			0, -- Nulls
			1, -- Rotty
			
			0, -- Mr Maw
			2, -- Psychic Maw
			0, -- Psychic Horf
			0, -- Maw
			1, -- Red Maw
			
			0, -- Black Bony
			0, -- Flesh Death's Head
			
			0, -- Fat Bat
			
			0, -- Wizoob
			0, -- Red Ghost
			
			0, -- Conjoined Fatty
			1, -- Pale Fatty
			0, -- Blubber
			1, -- Blue Conjoined Fatty
			0, -- Fat Sack
			
			1, -- Gazing Globin
			2, -- Dank Globin
			0, -- Black Globin
			
			1, -- Selfless Knight
			0, -- Floating Knight
			0, -- Bone Knight
			
			2, -- I. Blob
			0, -- Mega Clotty
			
			0, -- Mom's Dead Hand
			
			0, -- Spitty
			0, -- Charger
			1, -- Drowned Charger
			0, -- Conjoined Spitty
			0, -- Grub
			
			0, -- Camillo Jr
			0, -- Psy Tumor
			0, -- MemBrain
			1, -- Mama Guts
			1, -- Scarred Guts
			
			1, -- Scarred Para-Bite
			0, -- Cod Worm
			1, -- Kamikaze Leech
			2, -- Holy Leech
			
			0, -- Mobile Host
			1, -- Red Host
			0, -- Red Mobile Host
			0, -- Meatball
			
			1, -- Nerve Ending 2
			
			0, -- Vis
			1, -- Double Vis
			3, -- Scarred Double Vis
			
			1, -- BloodShot Eye
			
			1, -- Evil Twin
			
			1, -- Angelic Baby
			
			0, -- Begotten
			
			0, -- Hanger
			
			1, -- Vomit Grimace
			0, -- Brimstone Head
			0, -- Stone Eye
			0, -- Gaping Maw
			
			0, -- Black Maw
			
			0, -- Blastocyst Medium
			0, -- Blastocyst Small
			0, -- Fistula Medium
			0, -- Fistula Small
			1, -- Teratoma Medium
			1, -- Teratoma Small
			
			1, -- Red Fire Place
			3 -- Purple Fire Place
			}

local DG_t2ndVar = {
			40, -- Bomb Pickup
			3, -- Troll Bomb
			0, -- Black Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Lvl2 Fly
			0, -- Sucker
			0, -- Pooter
			0, -- Boom Fly
			0, -- Boom Fly
			
			0, -- Dip
			0, -- Dip
			0, -- Dip
			0, -- Squirt
			0, -- Squirt
			
			0, -- Spider
			0, -- Spider
			0, -- Spider
			1, -- Trite
			1, -- Trite
			1, -- Trite
			0, -- Lvl2 Spider
			1, -- Small Baby Long Legs
			1, -- Small Crazy Long Legs
			0, -- Wall Creep
			0, -- Wall Creep
			0, -- Blind Creep
			
			0, -- Boil
			0, -- Boil
			0, -- Boil
			1, -- Gut
			2, -- Sack
			
			0, -- Round Worm
			0, -- Round Worm
			0, -- Round Worm
			
			1, -- Mulligoon
			0, -- Mulligan
			0, -- Prey
			0, -- Dukie
			0, -- Mulligan
			
			0, -- Hopper
			0, -- Hopper
			1, -- Pacer
			0, -- Gusher
			0, -- Gusher
			1, -- Gaper
			1, -- Gaper
			0, -- Frowning Gaper
			1, -- Gaper
			0, -- Cyclopia
			0, -- Frowning Gaper
			0, -- Skinny
			
			0, -- Maw
			0, -- Maw
			0, -- Horf
			0, -- Horf
			0, -- Horf
			
			0, -- Bony
			0, -- Death's Head
			
			0, -- One Tooth
			
			0, -- Round Worm
			0, -- Wizoob
			
			0, -- Fatty
			0, -- Fatty
			0, -- Half Sack 
			0, -- Conjoined Fatty
			1, -- Pale Fatty
			
			0, -- Globin
			0, -- Globin
			0, -- Globin
			
			0, -- Knight
			0, -- Knight
			1, -- Selfless Knight
			
			0, -- Clotty
			0, -- Clotty
			
			0, -- Mom's Hand
			
			0, -- Maggot
			0, -- Maggot
			0, -- Charger
			0, -- Spitty
			0, -- Charger
			
			0, -- Psy Tumor
			0, -- Tumor
			0, -- Brain
			0, -- Guts
			0, -- Guts
			
			0, -- Para-Bite
			0, -- Para-Bite
			0, -- Leech
			0, -- Leech
			
			0, -- Host
			0, -- Host
			0, -- Mobile Host
			0, -- Host
			
			0, -- Nerve Ending
			
			2, -- Chubber
			0, -- Vis
			1, -- Double Vis
			
			0, -- Eye
			
			0, -- Dople
			
			0, -- Baby
			
			0, -- Homunculus
			
			0, -- Keeper
			
			0, -- Stone Grimace
			0, -- Turret Grimace
			0, -- Turret Grimace
			1, -- Broken Gaping Maw
			
			0, -- Oob
			
			0, -- Blastocyst Small
			0, -- Embryo
			0, -- Fistula Small
			0, -- Charger
			1, -- Teratoma Small
			0, -- Spider
			
			0, -- Fire Place
			2 -- Blue Fire Place
			}

local DG_t1stSType = {
			0, -- Troll Bomb
			0, -- Super Troll Bomb
			0, -- Attack Fly
			0, -- Ring Fly
			0, -- Dart Fly
			0, -- Swarm Fly
			0, -- Hush Fly
			0, -- Moter
			0, -- Lvl2 Fly
			0, -- Full Fly
			0, -- Spit
			0, -- Super Pooter
			0, -- Red Boom Fly
			0, -- Drowned Boom Fly
			
			0, -- Corn Dip
			0, -- Brownie Dip
			0, -- Squirt
			0, -- Dank Squirt
			0, -- Dinga
			
			0, -- Big Spider
			0, -- Trite
			0, -- Lvl 2 Spider
			0, -- Ragling
			0, -- Ragman's Ragling
			0, -- Blister
			0, -- Ticking Spider
			0, -- Baby Long Legs
			0, -- Crazy Long Legs
			0, -- Blind Creep
			0, -- The Thing
			0, -- Rage Creep
			
			0, -- Gut
			0, -- Sack
			0, -- Hush Boil
			0, -- Walking Gut
			0, -- Walking Sack
			
			0, -- Night Crawler
			0, -- Roundy
			0, -- Para-Bite
			
			0, -- Mulliboom
			0, -- Hive
			0, -- Drowned Hive
			0, -- Swarmer
			0, -- Nest
			
			0, -- Flaming Hopper
			0, -- Leaper
			0, -- Gusher
			0, -- Black Globin's Body
			0, -- Splasher
			0, -- Frowning Gaper
			0, -- Cyclopia
			0, -- Hush Gaper
			0, -- Greed Gaper
			0, -- Gurgle
			0, -- Nulls
			0, -- Rotty
			
			0, -- Mr Maw's Body
			0, -- Psychic Maw
			0, -- Psychic Horf
			0, -- Maw
			0, -- Red Maw
			
			0, -- Black Bony
			0, -- Flesh Death's Head
			
			0, -- Fat Bat
			
			0, -- Wizoob
			0, -- Red Ghost
			
			0, -- Conjoined Fatty
			0, -- Pale Fatty
			0, -- Blubber
			0, -- Blue Conjoined Fatty
			0, -- Fat Sack
			
			0, -- Gazing Globin
			0, -- Dank Globin
			0, -- Black Globin
			
			0, -- Selfless Knight
			0, -- Floating Knight
			0, -- Bone Knight
			
			0, -- I. Blob
			0, -- Mega Clotty
			
			0, -- Mom's Dead Hand
			
			0, -- Spitty
			0, -- Charger
			0, -- Drowned Charger
			0, -- Conjoined Spitty
			0, -- Grub
			
			0, -- Camillo Jr
			0, -- Psy Tumor
			0, -- MemBrain
			0, -- Mama Guts
			0, -- Scarred Guts
			
			0, -- Scarred Para-Bite
			0, -- Cod Worm
			0, -- Kamikaze Leech
			0, -- Holy Leech
			
			0, -- Host
			0, -- Mobile Host
			0, -- Red Mobile Host
			0, -- Meatball
			
			0, -- Nerve Ending 2
			
			0, -- Vis
			0, -- Double Vis
			0, -- Scarred Double Vis
			
			0, -- BloodShot Eye
			
			0, -- Evil Twin
			
			0, -- Angelic Baby
			
			0, -- Begotten
			
			0, -- Hanger
			
			0, -- Vomit Grimace
			0, -- Brimstone Head
			0, -- Stone Eye
			0, -- Gaping Maw
			
			0, -- Black Maw
			
			0, -- Blastocyst Medium
			0, -- Blastocyst Small
			0, -- Fistula Medium
			0, -- Fistula Small
			0, -- Teratoma Medium
			0, -- Teratoma Small
			
			0, -- Red Fire Place
			0 -- Purple Fire Place
}

local DG_t2ndSType = {
			1, -- Bomb Pickup
			0, -- Troll Bomb
			0, -- Black Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Lvl2 Fly
			0, -- Sucker
			0, -- Pooter
			0, -- Boom Fly
			0, -- Boom Fly
			
			0, -- Dip
			0, -- Dip
			0, -- Dip
			0, -- Squirt
			0, -- Squirt
			
			0, -- Spider
			0, -- Spider
			0, -- Spider
			0, -- Trite
			0, -- Trite
			0, -- Trite
			0, -- Lvl2 Spider
			0, -- Small Baby Long Legs
			0, -- Small Crazy Long Legs
			0, -- Wall Creep
			0, -- Wall Creep
			0, -- Blind Creep
			
			0, -- Boil
			0, -- Boil
			0, -- Boil
			0, -- Walking Boil
			0, -- Walking Boil
			
			0, -- Round Worm
			0, -- Round Worm
			0, -- Round Worm
			
			0, -- Mulligoon
			0, -- Mulligan
			0, -- Hive
			0, -- Hive
			0, -- Mulligan
			
			0, -- Hopper
			0, -- Hopper
			0, -- Pacer
			0, -- Gusher
			0, -- Gusher
			0, -- Gaper
			0, -- Gaper
			0, -- Gaper
			0, -- Gaper
			0, -- Gaper
			0, -- Gaper
			0, -- Skinny
			
			0, -- Maw
			0, -- Maw
			0, -- Horf
			0, -- Horf
			0, -- Horf
			
			0, -- Bony
			0, -- Death's Head
			
			0, -- One Tooth
			
			0, -- Lil' Haunt
			0, -- Wizoob
			
			0, -- Fatty
			0, -- Fatty
			0, -- Half Sack 
			0, -- Conjoined Fatty
			0, -- Fale Fatty
			
			0, -- Globin
			0, -- Globin
			0, -- Globin
			
			0, -- Knight
			0, -- Knight
			0, -- Knight
			
			0, -- Clotty
			0, -- Clotty
			
			0, -- Mom's Hand
			
			0, -- Maggot
			0, -- Maggot
			0, -- Charger
			0, -- Spitty
			0, -- Charger
			
			0, -- Psy Tumor
			0, -- Tumor
			0, -- Brain
			0, -- Guts
			0, -- Guts
			
			0, -- Para-Bite
			0, -- Para-Bite
			0, -- Leech
			0, -- Leech
			
			0, -- Red Host
			0, -- Flesh Mobile Host
			0, -- Red Host
			0, -- Red Host
			
			0, -- Nerve Ending
			
			0, -- Chubber
			0, -- Vis
			0, -- Double Vis
			
			0, -- Eye
			
			0, -- Dople
			
			0, -- Baby
			
			0, -- Homunculus
			
			0, -- Keeper
			
			0, -- Stone Grimace
			0, -- Turret Grimace
			0, -- Turret Grimace
			0, -- Broken Gaping Maw
			
			0, -- Oob
			
			0, -- Blastocyst Small
			0, -- Embryo
			0, -- Fistula Small
			0, -- Charger
			0, -- Teratoma Small
			0, -- Spider
			
			0, -- Fire Place
			0 -- Blue Fire Place
}

--[[local DG_dictEnemies = {
	[EntityType.ENTITY_BOMBDROP] = EntityType.ENTITY_PICKUP,
	[EntityType.ENTITY_BOMBDROP] = EntityType.ENTITY_BOMBDROP,
	[EntityType.ENTITY_ATTACKFLY] = EntityType.ENTITY_FLY,
	[EntityType.ENTITY_RING_OF_FLIES] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_DART_FLY] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_SWARM] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_HUSH_FLY] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_MOTER] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_FLY_L2] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_FULL_FLY] = EntityType.ENTITY_FLY_L2,
	[EntityType.ENTITY_SUCKER] = EntityType.ENTITY_SUCKER,
	[EntityType.ENTITY_POOTER] = EntityType.ENTITY_POOTER,
	[EntityType.ENTITY_BOOMFLY] = EntityType.ENTITY_BOOMFLY,
	[EntityType.ENTITY_BOOMFLY] = EntityType.ENTITY_BOOMFLY,
	
	[EntityType.ENTITY_DIP] = EntityType.ENTITY_DIP,
	[EntityType.ENTITY_DIP] = EntityType.ENTITY_DIP,
	[EntityType.ENTITY_SQUIRT] = EntityType.ENTITY_DIP,
	[EntityType.ENTITY_SQUIRT] = EntityType.ENTITY_SQUIRT,
	[EntityType.ENTITY_DINGA] = EntityType.ENTITY_SQUIRT,
	
	[EntityType.ENTITY_BIGSPIDER] = EntityType.ENTITY_SPIDER,
	[EntityType.ENTITY_HOPPER] = EntityType.ENTITY_SPIDER, -- Trite
	[EntityType.ENTITY_SPIDER_L2] = EntityType.ENTITY_SPIDER,
	[EntityType.ENTITY_RAGLING] = EntityType.ENTITY_HOPPER,
	[EntityType.ENTITY_RAGLING] = EntityType.ENTITY_HOPPER, --De Ragman
	[EntityType.ENTITY_BLISTER] = EntityType.ENTITY_HOPPER,
	[EntityType.ENTITY_TICKING_SPIDER] = EntityType.ENTITY_SPIDER_L2,
	[EntityType.ENTITY_BABY_LONG_LEGS] = EntityType.ENTITY_BABY_LONG_LEGS,
	[EntityType.ENTITY_CRAZY_LONG_LEGS] = EntityType.ENTITY_CRAZY_LONG_LEGS,
	[EntityType.ENTITY_BLIND_CREEP] = EntityType.ENTITY_WALL_CREEP,
	[EntityType.ENTITY_THE_THING] = EntityType.ENTITY_WALL_CREEP,
	[EntityType.ENTITY_RAGE_CREEP] = EntityType.ENTITY_BLIND_CREEP,
	
	[EntityType.ENTITY_BOIL] = EntityType.ENTITY_BOIL,
	[EntityType.ENTITY_BOIL] = EntityType.ENTITY_BOIL,
	[EntityType.ENTITY_HUSH_BOIL] = EntityType.ENTITY_BOIL,
	[EntityType.ENTITY_WALKINGBOIL] = EntityType.ENTITY_WALKINGBOIL,
	[EntityType.ENTITY_WALKINGBOIL] = EntityType.ENTITY_WALKINGBOIL,
	[EntityType.ENTITY_NIGHT_CRAWLER] = EntityType.ENTITY_ROUND_WORM,
	[EntityType.ENTITY_ROUNDY] = EntityType.ENTITY_ROUND_WORM,
	[EntityType.ENTITY_PARA_BITE] = EntityType.ENTITY_ROUND_WORM,
	
	[EntityType.ENTITY_MULLIGAN] = EntityType.ENTITY_MULLIGAN,
	[EntityType.ENTITY_HIVE] = EntityType.ENTITY_MULLIGAN,
	[EntityType.ENTITY_HIVE] = EntityType.ENTITY_HIVE,
	[EntityType.ENTITY_SWARMER] = EntityType.ENTITY_HIVE,
	[EntityType.ENTITY_NEST] = EntityType.ENTITY_MULLIGAN,
	
	[EntityType.ENTITY_FLAMINGHOPPER] = EntityType.ENTITY_HOPPER,
	[EntityType.ENTITY_LEAPER] = EntityType.ENTITY_HOPPER,
	[EntityType.ENTITY_GUSHER] = EntityType.ENTITY_GUSHER,
	[EntityType.ENTITY_BLACK_GLOBIN_BODY] = EntityType.ENTITY_GUSHER,
	[EntityType.ENTITY_SPLASHER] = EntityType.ENTITY_GUSHER,
	[EntityType.ENTITY_GAPER] = EntityType.ENTITY_GAPER,
	[EntityType.ENTITY_CYCLOPIA] = EntityType.ENTITY_GAPER,
	[EntityType.ENTITY_HUSH_GAPER] = EntityType.ENTITY_GAPER,
	[EntityType.ENTITY_GREED_GAPER] = EntityType.ENTITY_GAPER,
	[EntityType.ENTITY_GURGLE] = EntityType.ENTITY_GAPER,
	[EntityType.ENTITY_NULLS] = EntityType.ENTITY_GAPER,
	[EntityType.ENTITY_SKINNY] = EntityType.ENTITY_SKINNY,
	
	[EntityType.ENTITY_MRMAW] = EntityType.ENTITY_MAW,
	[EntityType.ENTITY_MAW] = EntityType.ENTITY_MAW, -- Psy Maw
	[EntityType.ENTITY_PSY_HORF] = EntityType.ENTITY_HORF,
	[EntityType.ENTITY_MAW] = EntityType.ENTITY_HORF, -- Maw
	[EntityType.ENTITY_MAW] = EntityType.ENTITY_HORF, -- Red Maw
	
	[EntityType.ENTITY_BLACK_BONY] = EntityType.ENTITY_BONY,
	[EntityType.ENTITY_FLESH_DEATHS_HEAD] = EntityType.ENTITY_DEATHS_HEAD,
	
	[EntityType.ENTITY_FAT_BAT] = EntityType.ENTITY_ONE_TOOTH,
	
	[EntityType.ENTITY_WIZOOB] = EntityType.ENTITY_THE_HAUNT,
	[EntityType.ENTITY_RED_GHOST] = EntityType.ENTITY_WIZOOB,
	
	[EntityType.ENTITY_CONJOINED_FATTY] = EntityType.ENTITY_FATTY,
	[EntityType.ENTITY_FATTY] = EntityType.ENTITY_FATTY,
	[EntityType.ENTITY_BLUBBER] = EntityType.ENTITY_HALF_SACK,
	[EntityType.ENTITY_CONJOINED_FATTY] = EntityType.ENTITY_CONJOINED_FATTY,
	[EntityType.ENTITY_FAT_SACK] = EntityType.ENTITY_FATTY,
	
	[EntityType.ENTITY_GLOBIN] = EntityType.ENTITY_GLOBIN,
	[EntityType.ENTITY_GLOBIN] = EntityType.ENTITY_GLOBIN,
	[EntityType.ENTITY_BLACK_GLOBIN] = EntityType.ENTITY_GLOBIN,
	
	[EntityType.ENTITY_KNIGHT] = EntityType.ENTITY_KNIGHT,
	[EntityType.ENTITY_FLOATING_KNIGHT] = EntityType.ENTITY_KNIGHT,
	[EntityType.ENTITY_BONE_KNIGHT] = EntityType.ENTITY_KNIGHT,
	
	[EntityType.ENTITY_CLOTTY] = EntityType.ENTITY_CLOTTY,
	[EntityType.ENTITY_MEGA_CLOTTY] = EntityType.ENTITY_CLOTTY,
	
	[EntityType.ENTITY_MOMS_DEAD_HAND] = EntityType.ENTITY_MOMS_HAND,
	
	[EntityType.ENTITY_SPITY] = EntityType.ENTITY_MAGGOT,
	[EntityType.ENTITY_CHARGER] = EntityType.ENTITY_MAGGOT,
	[EntityType.ENTITY_CHARGER] = EntityType.ENTITY_CHARGER,
	[EntityType.ENTITY_CONJOINED_SPITTY] = EntityType.ENTITY_SPITY,
	[EntityType.ENTITY_GRUB] = EntityType.ENTITY_CHARGER,
	
	[EntityType.ENTITY_CAMILLO_JR] = EntityType.ENTITY_PSY_TUMOR,
	[EntityType.ENTITY_PSY_TUMOR] = EntityType.ENTITY_TUMOR,
	[EntityType.ENTITY_MEMBRAIN] = EntityType.ENTITY_BRAIN,
	[EntityType.ENTITY_MEMBRAIN] = EntityType.ENTITY_GUTS,
	[EntityType.ENTITY_GUTS] = EntityType.ENTITY_GUTS,
	
	[EntityType.ENTITY_PARA_BITE] = EntityType.ENTITY_PARA_BITE,
	[EntityType.ENTITY_COD_WORM] = EntityType.ENTITY_PARA_BITE,
	[EntityType.ENTITY_LEECH] = EntityType.ENTITY_LEECH,
	[EntityType.ENTITY_LEECH] = EntityType.ENTITY_LEECH,
	
	[EntityType.ENTITY_HOST] = EntityType.ENTITY_HOST,
	[EntityType.ENTITY_MOBILE_HOST] = EntityType.ENTITY_FLESH_MOBILE_HOST,
	[EntityType.ENTITY_FLESH_MOBILE_HOST] = EntityType.ENTITY_HOST,
	[EntityType.ENTITY_MEATBALL] = EntityType.ENTITY_HOST,
	
	[EntityType.ENTITY_NERVE_ENDING] = EntityType.ENTITY_NERVE_ENDING,
	
	[EntityType.ENTITY_VIS] = EntityType.ENTITY_VIS,
	[EntityType.ENTITY_VIS] = EntityType.ENTITY_VIS,
	[EntityType.ENTITY_VIS] = EntityType.ENTITY_VIS,
	
	[EntityType.ENTITY_EYE] = EntityType.ENTITY_EYE,
	
	[EntityType.ENTITY_DOPLE] = EntityType.ENTITY_DOPLE,
	
	[EntityType.ENTITY_BABY] = EntityType.ENTITY_BABY,
	
	[EntityType.ENTITY_BEGOTTEN] = EntityType.ENTITY_HOMUNCULUS,
	
	[EntityType.ENTITY_HANGER] = EntityType.ENTITY_KEEPER,
	
	[EntityType.ENTITY_STONEHEAD] = EntityType.ENTITY_STONEHEAD,
	[EntityType.ENTITY_BRIMSTONE_HEAD] = EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
	[EntityType.ENTITY_STONE_EYE] = EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
	[EntityType.ENTITY_GAPING_MAW] = EntityType.ENTITY_BROKEN_GAPING_MAW,
	
	[EntityType.ENTITY_BLACK_MAW] = EntityType.ENTITY_OOB,
	
	[EntityType.ENTITY_BLASTOCYST_MEDIUM] = EntityType.ENTITY_BLASTOCYST_SMALL,
	[EntityType.ENTITY_BLASTOCYST_SMALL] = EntityType.ENTITY_EMBRYO,
	[EntityType.ENTITY_FISTULA_MEDIUM] = EntityType.ENTITY_FISTULA_SMALL,
	[EntityType.ENTITY_FISTULA_SMALL] = EntityType.ENTITY_CHARGER,
	[EntityType.ENTITY_FISTULA_MEDIUM] = EntityType.ENTITY_FISTULA_SMALL,
	[EntityType.ENTITY_FISTULA_SMALL] = EntityType.ENTITY_SPIDER,
	
	[EntityType.ENTITY_FIREPLACE] = EntityType.ENTITY_FIREPLACE,
	[EntityType.ENTITY_FIREPLACE] = EntityType.ENTITY_FIREPLACE
}]]

local DG_FinalDict = {}

function mod:FillTable()
	for i,v in ipairs(DG_t1stEnemy) do
		v2 = DG_t1stVar[i]
		v3 = DG_t1stSType[i]
		t = {["Enemy"] = DG_t2ndEnemy[i],["Variant"] = DG_t2ndVar[i],["SubType"] = DG_t2ndSType[i]}
		put(DG_FinalDict,v,v2,v3,t) --Ponemos en el diccionario multillave el dato que está en la tabla
	end
end

function mod:DGrader()
	for _, v in
		ipairs(Isaac.FindInRadius(CenterV, 875, EntityPartition.ENEMY)) do
		
		if v:ToNPC() ~= nil and v:ToNPC():IsChampion() then
			new=Isaac.Spawn(v.Type,v.Variant,0,v.Position,v.Velocity,v)
			v:Remove()
		else
			--[[for i,v2 in ipairs(DG_t1stEnemy) do
				if v.Type == v2 then
					if v.Variant == DG_t1stVar[i] then
						if type(DG_t2ndVar[i]) == "table" then --Si hay una tabla entonces es variante + SubTipo
							new=Isaac.Spawn(DG_t2ndEnemy[i],DG_t2ndVar[i][1],DG_t2ndVar[i][2],v.Position,v.Velocity,v)
						else
							new=Isaac.Spawn(DG_t2ndEnemy[i],DG_t2ndVar[i],0,v.Position,v.Velocity,v)
						end
						new:GetData().Done = true
						v:GetData().Done = true
						v:Remove()
					end
				end
			end]]
			newEnemy = get(DG_FinalDict,v.Type,v.Variant,v.SubType)
			if newEnemy ~= nil then
				Isaac.Spawn(newEnemy["Enemy"],newEnemy["Variant"],newEnemy["SubType"],v.Position,v.Velocity,v)
			end
		end
	end
	return true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.DGrader, CollectibleType.Downgrader)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.FillTable)