local function initStrings( modApi )
	modApi:addStrings( modApi:getDataPath(), "SCMODS_ITEMS", include( modApi:getScriptPath() .. "/strings" ))
end

local function init ( modApi )
	KLEIResourceMgr.MountPackage( modApi:getDataPath() .. "/gui.kwad", "data" )
	modApi:addGenerationOption( "NewItems", STRINGS.SCMODS_ITEMS.GENOPTIONS.NEWITEMS, STRINGS.SCMODS_ITEMS.GENOPTIONS.NEWITEMS_TIP, { noUpdate = true })
	modApi:addGenerationOption( "EditedItems", STRINGS.SCMODS_ITEMS.GENOPTIONS.EDITEDITEMS, STRINGS.SCMODS_ITEMS.GENOPTIONS.EDITEDITEMS_TIP, { noUpdate = true })
	modApi:addGenerationOption( "Monst3rSales", STRINGS.SCMODS_ITEMS.GENOPTIONS.MONST3RSALES, STRINGS.SCMODS_ITEMS.GENOPTIONS.MONST3RSALES_TIP, { noUpdate = true })
end

local function load( modApi, options )
	local scriptPath = modApi:getScriptPath()
	local itemdefs = include( scriptPath .. "/itemdefs" )
	if options[ "NewItems" ] and options[ "NewItems" ].enabled then
		include( scriptPath .. "/SC_simempconcpack" )
		include( scriptPath .. "/simunit" )
		modApi:addAbilityDef( "SC_huntdevice", scriptPath .. "/abilities/SC_huntdevice" )
		modApi:addAbilityDef( "SC_jackin_velocity", scriptPath .. "/abilities/SC_jackin_velocity" )
		modApi:addAbilityDef( "SC_prime_emp_conc", scriptPath .."/abilities/SC_prime_emp_conc" )
		modApi:addAbilityDef( "SC_router_icemelt", scriptPath .. "/abilities/SC_router_icemelt" )
		modApi:addAbilityDef( "SC_use_aggression", scriptPath .."/abilities/SC_use_aggression" )
		modApi:addAbilityDef( "useInvisiCloak", scriptPath .. "/abilities/useInvisiCloak" )
		for name, item in pairs( itemdefs ) do
			modApi:addItemDef( name, item )
		end
	end
	include( scriptPath .. "/Monst3rSales" )
	if options[ "Monst3rSales" ] and options[ "Monst3rSales" ].enabled then
		editMonst3rSales()
	else
		restoreMonst3rSales()
	end
end

local function lateLoad( modApi, options )
	local scriptPath = modApi:getScriptPath()
	include( scriptPath .. "/itemdefs" )
	if options[ "EditedItems" ] and options[ "EditedItems" ].enabled then
		editItems()
	end
end

local function unload( modApi )
	local scriptPath = modApi:getScriptPath()
	include( scriptPath .. "/Monst3rSales" )
	restoreMonst3rSales()
end

return
{
	initStrings = initStrings,
	init = init,
	load = load,
	lateLoad = lateLoad,
	unload = unload
}