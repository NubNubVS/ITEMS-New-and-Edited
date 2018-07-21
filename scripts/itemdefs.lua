local commondefs = include( "sim/unitdefs/commondefs" )
local util = include( "modules/util" )

local function editItems()

	local array = include( "modules/array" )
	local itemdefs = include( "sim/unitdefs/itemdefs" )
	local id
	local shop = include( "sim/units/store" )

	itemdefs.item_bio_dartgun.traits.armorPiercing = nil
	itemdefs.item_bio_dartgun.value = 700
	itemdefs.item_bio_dartgun.floorWeight = nil
	itemdefs.item_bio_dartgun.notSoldAfter = 48
	shop.STORE_ITEM.weaponList[7] = itemdefs.item_bio_dartgun

	itemdefs.item_defiblance.name = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_1
	itemdefs.item_defiblance.desc = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_1_TOOLTIP
	itemdefs.item_defiblance.traits = { cooldown = 0, cooldownMax = 6, genericPiercing = 1, combatRestored = true }
	itemdefs.item_defiblance.requirements = { inventory = 2 }
	itemdefs.item_defiblance.abilities[2] = "SC_use_aggression"
	itemdefs.item_defiblance.value = 600
	itemdefs.item_defiblance.floorWeight = 1
	itemdefs.item_defiblance.notSoldAfter = 24
	shop.STORE_ITEM.itemList[31] = itemdefs.item_defiblance

	itemdefs.item_prototype_drive.traits.maxIcebreak = 15
	itemdefs.item_prototype_drive.requirements = { hacking = 2, anarchy = 2 }
	itemdefs.item_prototype_drive.value = 900
	table.insert( shop.STORE_ITEM.itemList, itemdefs.item_prototype_drive )

	itemdefs.item_tazer_2.traits.cooldownMax = 4
	shop.STORE_ITEM.weaponList[10] = itemdefs.item_tazer_2

	itemdefs.item_tazer_3.traits.cooldownMax = 5
	shop.STORE_ITEM.weaponList[11] = itemdefs.item_tazer_3

	id = array.find( shop.STORE_ITEM.weaponList, itemdefs.item_armor_tazer_1 )
	itemdefs.item_armor_tazer_1.traits.armorPiercing = 1
	shop.STORE_ITEM.weaponList[id] = itemdefs.item_armor_tazer_1

	id = array.find( shop.STORE_ITEM.weaponList, itemdefs.item_armor_tazer_2 )
	itemdefs.item_armor_tazer_2.traits.cooldownMax = 4
	shop.STORE_ITEM.weaponList[id] = itemdefs.item_armor_tazer_2

	id = array.find( shop.STORE_ITEM.weaponList, itemdefs.item_armor_tazer_3 )
	itemdefs.item_armor_tazer_3.traits.armorPWRcost = 1
	itemdefs.item_armor_tazer_3.traits.cooldownMax = 5
	shop.STORE_ITEM.weaponList[id] = itemdefs.item_armor_tazer_3

	id = array.find( shop.STORE_ITEM.weaponList, itemdefs.item_armor_tazer_4 )
	itemdefs.item_armor_tazer_4.traits.damage = 3
	itemdefs.item_armor_tazer_4.traits.cooldownMax = 5
	itemdefs.item_armor_tazer_4.soldAfter = 48
	shop.STORE_ITEM.weaponList[id] = itemdefs.item_armor_tazer_4

	id = array.find( shop.STORE_ITEM.weaponList, itemdefs.item_power_tazer_4 )
	itemdefs.item_power_tazer_4.traits.pwrCost = 5
	itemdefs.item_power_tazer_4.traits.armorPiercing = 2
	itemdefs.item_power_tazer_4.soldAfter = 48
	shop.STORE_ITEM.weaponList[id] = itemdefs.item_power_tazer_4

	id = array.find( shop.STORE_ITEM.weaponList, itemdefs.item_tazer_4 )
	itemdefs.item_tazer_4.traits.armorPiercing = 2
	itemdefs.item_tazer_4.traits.cooldownMax = 5
	itemdefs.item_tazer_4.soldAfter = 48
	shop.STORE_ITEM.weaponList[id] = itemdefs.item_tazer_4

end

local newItems =
{
	SC_augment_combat_stimulator = util.extend( commondefs.augment_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.COMBAT_STIMULATOR,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.COMBAT_STIMULATOR_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.COMBAT_STIMULATOR_FLAVOR,
		AUGMENT_LIST = true,
		value = 400,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS )
		{
			addTrait = {{ "actionAP", true }},
			grafterWeight = 10,
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/SC_augment_combat_stimulator_small.png",
		profile_icon_100 = "gui/icons/item_icons/SC_augment_combat_stimulator.png",
	},
	SC_item_bio_dartgun_pierce = util.extend( commondefs.weapon_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.DART_GUN_BIOPIERCE,
		desc = STRINGS.ITEMS.DART_GUN_BIO_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.DART_GUN_BIOPIERCE_FLAVOR,
		WEAPON_LIST = true,
		icon = "itemrigs/FloorProp_Precision_Pistol.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_gun_dart_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_gun_dart.png",
		equipped_icon = "gui/items/equipped_pistol.png",
		traits = { weaponType = "pistol", baseDamage = 2, armorPiercing = 1, cooldown = 0, cooldownMax = 7, canSleep = true },
		abilities = util.tmerge({ "recharge" }, commondefs.weapon_template.abilities ),
		sounds = { shoot = "SpySociety/Weapons/Precise/shoot_dart", reload = "SpySociety/Weapons/LowBore/reload_handgun", use = "SpySociety/Actions/item_pickup" },
		weapon_anim = "kanim_precise_revolver",
		agent_anim = "anims_1h",
		value = 1000,
		soldAfter = 24,
		floorWeight = 2,
	},
	SC_item_cloakingrig_bubble = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.CLOAK_BUBBLE,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.CLOAK_BUBBLE_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.CLOAK_BUBBLE_FLAVOR,
		ITEM_LIST = true,
		icon = "itemrigs/FloorProp_InvisiCloakTimed.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_invisicloak_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_invisi_cloak.png",
		traits = { duration = 4, cooldown = 0, cooldownMax = 7, cloakInVision = false, range = 4, cloakDistanceMax = 1 },
		requirements = { stealth = 4, anarchy = 4 },
		abilities = { "carryable", "recharge", "useInvisiCloak" },
		value = 1100,
		floorWeight = 4,
		soldAfter = 48,
	},
	SC_item_econchip_2 = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.ECON_CHIP_2,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.ECON_CHIP_2_TOOLTIP,
		flavor = STRINGS.ITEMS.ECON_CHIP_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_chip_econ_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_chip_econ.png",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 3, PWR_conversion = 50 },
		requirements = { hacking = 2 },
		abilities = { "carryable", "recharge", "jackin" },
		value = 1000,
		floorWeight = 3,
		soldAfter = 24,
	},
	SC_item_emp_concussive = util.extend( commondefs.item_template )
	{
		type = "simemppackconcussive",
		name = STRINGS.SCMODS_ITEMS.ITEMS.EMP_CONCUSSIVE,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.EMP_CONCUSSIVE_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.EMP_CONCUSSIVE_FLAVOR,
		ITEM_LIST = true,
		icon = "itemrigs/FloorProp_emp.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/SC_item_emp_concussive_small.png",
		profile_icon_100 = "gui/icons/item_icons/SC_item_emp_concussive.png",
		abilities = { "carryable", "recharge", "SC_prime_emp_conc" },
		requirements = { hacking = 4, anarchy = 4 },
		uses_mainframe =
		{
			toggle =
			{
				name = STRINGS.SCMODS_ITEMS.ABILITIES.EMP_CONC_USE,
				tooltip = STRINGS.SCMODS_ITEMS.ABILITIES.EMP_CONC_USE_DESC,
				fn = "toggle" -- global script function
			}
		},
		traits = { cooldown = 0, cooldownMax = 8, range = 6, emp_duration = 2, canSleep = true, baseDamage = 2, trigger_mainframe = true, concussive = true, usesCharges = true, charges = 2, chargesMax = 2 },
		value = 1500,
		floorWeight = 4,
		soldAfter = 48,
	},
	SC_item_hunterchip = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.HUNTER_CHIP,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.HUNTER_CHIP_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.HUNTER_CHIP_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/SC_item_hunterchip_small.png",
		profile_icon_100 = "gui/icons/item_icons/SC_item_hunterchip.png",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 4, usesCharges = true, charges = 2, chargesMax = 2 },
		requirements = { hacking = 4 },
		abilities = { "carryable", "recharge", "SC_huntdevice" },
		value = 700,
		floorWeight = 3,
		soldAfter = 24,
	},
	SC_item_router_icemelter = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.ROUTER_ICEMELTER,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.ROUTER_ICEMELTER_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.ROUTER_ICEMELTER_FLAVOR,
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_laptop1_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_laptop1.png",
		kanim = "kanim_laptop",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 2, laptop = true, mainframe_icon_on_deploy = true, sightable = true, hidesInCover = true, cpus = 0, cpuTurn = 1, cpuTurnMax = 1, meltvalue = -1 },
		requirements = { hacking = 4 },
		abilities = { "carryable", "deployable", "SC_router_icemelt" },
		sounds = { deploy = "SpySociety/Objects/SuitcaseComputer_open", pickUp = "SpySociety/Objects/SuitcaseComputer_close" },
		rig = "consolerig",
		value = 1500,
		floorWeight = 3,
		soldAfter = 24,
		locator = true,
	},
	SC_item_velocitydrive = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.VELOCITYDRIVE,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.VELOCITYDRIVE_TOOLTIP,
		flavor = STRINGS.SCMODS_ITEMS.ITEMS.VELOCITYDRIVE_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/SC_item_velocitydrive_small.png",
		profile_icon_100 = "gui/icons/item_icons/SC_item_velocitydrive.png",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 2, AP_conversion = true },
		requirements = { stealth = 2, hacking = 2 },
		abilities = { "carryable", "recharge", "SC_jackin_velocity" },
		value = 700,
		floorWeight = 3,
	},
	SC_item_ventricular_lance_2 = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_2,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_2_TOOLTIP,
		flavor = STRINGS.ITEMS.DEFIBRILLATOR_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_defibulator_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_defibulator.png",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 8, genericPiercing = 1, ap = 1 },
		requirements = { inventory = 3 },
		abilities = { "carryable", "SC_use_aggression" },
		value = 800,
		floorWeight = 2,
	},
	SC_item_ventricular_lance_3 = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_3,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_3_TOOLTIP,
		flavor = STRINGS.ITEMS.DEFIBRILLATOR_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_defibulator_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_defibulator.png",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 10, genericPiercing = 2, ap = 1 },
		requirements = { inventory = 4 },
		abilities = { "carryable", "SC_use_aggression" },
		value = 1000,
		floorWeight = 3,
		soldAfter = 24,
	},
	SC_item_ventricular_lance_4 = util.extend( commondefs.item_template )
	{
		name = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_4,
		desc = STRINGS.SCMODS_ITEMS.ITEMS.VENTRICULAR_LANCE_4_TOOLTIP,
		flavor = STRINGS.ITEMS.DEFIBRILLATOR_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_defibulator_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_defibulator.png",
		ITEM_LIST = true,
		traits = { cooldown = 0, cooldownMax = 12, genericPiercing = 2, unlimitedAttacks = true, usesCharges = true, charges = 2, chargesMax = 2 },
		requirements = { inventory = 5 },
		abilities = { "carryable", "SC_use_aggression" },
		value = 1200,
		floorWeight = 4,
		soldAfter = 48,
	}
}

return
{
	editItems = editItems,
	newItems = newItems
}
