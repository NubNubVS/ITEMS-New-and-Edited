local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local inventory = include( "sim/inventory" )
local simdefs = include( "sim/simdefs" )
local simfactory = include( "sim/simfactory" )
local simquery = include( "sim/simquery" )
local unitdefs = include( "sim/unitdefs" )
local util = include( "modules/util" )

local SC_emp_conc_tooltip = class( abilityutil.hotkey_tooltip )

function SC_emp_conc_tooltip:init( hud, unit, abilityOwner, ... )
	abilityutil.hotkey_tooltip.init( self, ... )
	self._game = hud._game
	self._unit = unit
	self._emp = abilityOwner
	self._range = abilityOwner:getTraits().range
end

function SC_emp_conc_tooltip:activate( screen )
	abilityutil.hotkey_tooltip.activate( self, screen )
	local x0, y0 = self._unit:getLocation()
	self._hiliteID = self._game.boardRig:hiliteCells( simquery.rasterCircle( self._game.simCore, x0, y0, self._range ), { 0.2, 0.2, 0.2, 0.2 })
	for i, target in ipairs( self._emp:getTargets( x0, y0 )) do
		self._game.boardRig:getUnitRig( target:getID() ):getProp():setRenderFilter( cdefs.RENDER_FILTERS[ "focus_target" ])
	end
end

function SC_emp_conc_tooltip:deactivate()
	abilityutil.hotkey_tooltip.deactivate( self )
	self._game.boardRig:unhiliteCells( self._hiliteID )
	self._hiliteID = nil
	for i, target in ipairs( self._emp:getTargets( self._unit:getLocation() )) do
		self._game.boardRig:getUnitRig( target:getID() ):refreshRenderFilter()
	end
end

local SC_prime_emp_conc =
{
	name = STRINGS.SCMODS_ITEMS.ABILITIES.EMP_CONC_PRIME,
	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
	alwaysShow = true, -- Nub: These two are unutilized, retained for future.
	usesAction = true,

	getName = function()
		return STRINGS.SCMODS_ITEMS.ABILITIES.EMP_CONC_PRIME
	end,

	onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
		return SC_emp_conc_tooltip( hud, abilityUser, abilityOwner, self, sim, abilityOwner, STRINGS.SCMODS_ITEMS.ABILITIES.EMP_CONC_PRIME_DESC )
	end,

	canUseAbility = function( self, sim, abilityOwner )
		if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
			return false, util.sformat( STRINGS.UI.REASON.COOLDOWN, abilityOwner:getTraits().cooldown )
		end
		if abilityOwner:getTraits().usesCharges and abilityOwner:getTraits().charges < 1 then
			return false, util.sformat( STRINGS.UI.REASON.CHARGES )
		end
		local ok, reason = abilityutil.checkRequirements( abilityOwner, abilityOwner:getUnitOwner() )
		if not ok then
			return false, reason
		end
		return true
	end,

	executeAbility = function( self, sim, unit, userUnit )
		local cell = sim:getCell( userUnit:getLocation() )
		local newUnit = simfactory.createUnit( unitdefs.lookupTemplate( unit:getUnitData().id ), sim )
		sim:dispatchEvent( simdefs.EV_UNIT_PICKUP, { unitID = userUnit:getID() })
		sim:spawnUnit( newUnit )
		sim:warpUnit( newUnit, cell )
		newUnit:removeAbility( sim, "carryable" )
		sim:emitSound( simdefs.SOUND_ITEM_PUTDOWN, cell.x, cell.y, userUnit )
		sim:emitSound( simdefs.SOUND_PRIME_EMP, cell.x, cell.y, userUnit )
		newUnit:setPlayerOwner( userUnit:getPlayerOwner() )
		newUnit:getTraits().mainframe_item = true
		newUnit:getTraits().mainframe_status = "on"
		userUnit:resetAllAiming()
		inventory.useItem( sim, userUnit, unit )
	end
}
return SC_prime_emp_conc