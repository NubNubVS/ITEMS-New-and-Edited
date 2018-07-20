local sales = include( "sim/simdefs" )

function editMonst3rSales()

	sales.ITEMS_SPECIAL_DAY_1 =
	{
		{ "augment_microslam_apparatus", 10 },
		{ "augment_predictive_brawling", 10 },
		{ "item_defiblance", 10 },
		{ "item_econchip", 10 },
		{ "item_hologrenade", 10 },
		{ "item_light_pistol_ammo", 10 },
		{ "item_tazer_2", 10 },
		{ "vault_passcard", 15 }
	}
	sales.ITEMS_SPECIAL_DAY_2 =
	{
		{ "augment_penetration_scanner", 10 },
		{ "augment_piercing_scanner", 10 },
		{ "augment_torque_injectors", 10 },
		{ "item_bio_dartgun", 10 },
		{ "item_hologrenade", 10 },
		{ "item_icebreaker_2", 10 },
		{ "item_laptop_2", 10 },
		{ "item_light_pistol_dam", 10 },
		{ "item_power_tazer_2", 10 },
		{ "vault_passcard", 15 }
	}
	sales.ITEMS_SPECIAL_DAY_4 =
	{
		{ "augment_holocircuit_overloaders", 10 },
		{ "augment_penetration_scanner", 10 },
		{ "augment_piercing_scanner", 10 },
		{ "item_bio_dartgun", 10 },
		{ "item_hologrenade", 10 },
		{ "item_icebreaker_3", 10 },
		{ "item_laptop_3", 10 },
		{ "item_light_pistol_dam", 10 },
		{ "item_power_tazer_3", 10 },
		{ "item_stim_3", 10 }
	}
	sales.BEGINNER_ITEMS_SPECIAL_DAY_2 =
	{
		{ "augment_distributed_processing", 15 },
		{ "item_emp_pack_2", 10 },
		{ "item_icebreaker_2", 10 },
		{ "item_laptop_2", 10 }
	}
	sales.BEGINNER_ITEMS_SPECIAL_DAY_3 =
	{
		{ "augment_penetration_scanner", 10 },
		{ "augment_piercing_scanner", 10 },
		{ "item_bio_dartgun", 15 },
		{ "item_defiblance", 10 },
		{ "item_tazer_3", 10 }
	}
	sales.BEGINNER_ITEMS_SPECIAL_VARIETY =
	{
		{ "augment_holocircuit_overloaders", 10 },
		{ "augment_net_downlink", 10 },
		{ "augment_predictive_brawling", 10 },
		{ "item_emp_pack", 10 },
		{ "item_tazer_2", 10 }
	}

end

function restoreMonst3rSales()

	sales.ITEMS_SPECIAL_DAY_1 =
	{
		{ "vault_passcard", 15 },
		{ "item_defiblance", 10 },
		{ "item_lockdecoder", 10 },
		{ "augment_distributed_processing", 10 },
		{ "item_icebreaker", 10 },
		{ "augment_predictive_brawling", 10 },
		{ "item_hologrenade", 10 },
		{ "item_stickycam", 10 },
		{ "augment_microslam_apparatus", 10 },
		{ "item_light_pistol_ammo", 10 },
		{ "item_smokegrenade", 10 }
	}
	sales.ITEMS_SPECIAL_DAY_2 =
	{
		{ "vault_passcard", 15 },
		{ "item_defiblance", 10 },
		{ "item_lockdecoder", 10 },
		{ "augment_distributed_processing", 10 },
		{ "item_icebreaker_2", 10 },
		{ "item_bio_dartgun", 10 },
		{ "item_power_tazer_2", 10 },
		{ "item_light_pistol_dam", 10 },
		{ "augment_penetration_scanner", 10 },
		{ "item_hologrenade", 10 },
		{ "item_stickycam", 10 }
	}
	sales.ITEMS_SPECIAL_DAY_4 =
	{
		{ "item_defiblance", 10 },
		{ "item_lockdecoder", 10 },
		{ "augment_distributed_processing", 10 },
		{ "item_icebreaker_2", 10 },
		{ "item_bio_dartgun", 10 },
		{ "item_power_tazer_2", 10 },
		{ "item_light_pistol_dam", 10 },
		{ "augment_penetration_scanner", 10 },
		{ "item_hologrenade", 10 },
		{ "item_stickycam", 10 }
	}
	sales.BEGINNER_ITEMS_SPECIAL_DAY_2 =
	{
		{ "augment_distributed_processing", 15 },
		{ "item_emp_pack_2", 10 },
		{ "item_icebreaker_2", 10 },
		{ "item_laptop_2", 10 }
	}
	sales.BEGINNER_ITEMS_SPECIAL_DAY_3 =
	{
		{ "item_defiblance", 10 },
		{ "augment_penetration_scanner", 10 },
		{ "augment_piercing_scanner", 10 },
		{ "item_tazer_3", 10 },
		{ "item_bio_dartgun", 15 }
	}
	sales.BEGINNER_ITEMS_SPECIAL_VARIETY =
	{
		{ "augment_net_downlink", 10 },
		{ "augment_predictive_brawling", 10 },
		{ "augment_holocircuit_overloaders", 10 },
		{ "item_emp_pack", 10 },
		{ "item_tazer_2", 10 }
	}

end
