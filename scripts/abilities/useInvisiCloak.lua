local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local inventory = include( "sim/inventory" )
local simquery = include( "sim/simquery" )
local util = include( "modules/util" )

local function getCloakDistance( unit )
	local distance = unit:getTraits().cloakDistanceMax or unit:getTraits().cloakDistance
	if distance then
		return distance - 1
	else
		return "unlimited"
	end
end

local function getTargetUnits( sim, userUnit, x0, y0, range )
	local units = {}
	local cells = simquery.fillCircle( sim, x0, y0, range, 0 )
	for i, cell in ipairs( cells ) do
		for i, cellUnit in ipairs( cell.units ) do
			if not simquery.isEnemyAgent( userUnit:getPlayerOwner(), cellUnit ) and simquery.isAgent( cellUnit ) and cellUnit ~= userUnit then
				table.insert( units, cellUnit )
			end
		end
	end
	return units
end

-- Special cloak tooltip for showing range
local cloak_tooltip = class( abilityutil.hotkey_tooltip )

function cloak_tooltip:init( hud, unit, range, ... )
	abilityutil.hotkey_tooltip.init( self, ... )
	self._game = hud._game
	self._unit = unit
	self._range = range
	if range then
		local x0, y0 = unit:getLocation()
		self._targets = getTargetUnits( hud._game.simCore, unit, x0, y0, range )
	end
end

function cloak_tooltip:activate( screen )
	abilityutil.hotkey_tooltip.activate( self, screen )
	if self._range then
		local x0, y0 = self._unit:getLocation()
		local coords = simquery.rasterCircle( self._game.simCore, x0, y0, self._range )
		self._hiliteID = self._game.boardRig:hiliteCells( coords, cdefs.HILITE_TARGET_COLOR )
		for i, target in ipairs( self._targets ) do
			self._game.boardRig:getUnitRig( target:getID() ):getProp():setRenderFilter( cdefs.RENDER_FILTERS[ "focus_target" ])
		end
	end
end

function cloak_tooltip:deactivate()
	abilityutil.hotkey_tooltip.deactivate( self )
	if self._range then
		self._game.boardRig:unhiliteCells( self._hiliteID )
		self._hiliteID = nil
		for i, target in ipairs( self._targets ) do
			self._game.boardRig:getUnitRig( target:getID() ):refreshRenderFilter()
		end
	end
end

local useInvisiCloak =
{
	name = STRINGS.ABILITIES.CLOAK,
	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
	alwaysShow = true, -- Nub: Unutilized, retained for future.

	onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
		if abilityUser:getTraits().invisDuration then
			return cloak_tooltip( hud, abilityUser, abilityOwner:getTraits().range, self, sim, abilityOwner, util.sformat( STRINGS.SCMODS_ITEMS.ABILITIES.CLOAK_DESC .. STRINGS.SCMODS_ITEMS.ABILITIES.CLOAK_REDESC, abilityOwner:getTraits().duration, getCloakDistance( abilityOwner ), abilityUser:getTraits().invisDuration, getCloakDistance( abilityUser )))
		else
			return cloak_tooltip( hud, abilityUser, abilityOwner:getTraits().range, self, sim, abilityOwner, util.sformat( STRINGS.SCMODS_ITEMS.ABILITIES.CLOAK_DESC, abilityOwner:getTraits().duration, getCloakDistance( abilityOwner )))
		end
	end,

	getName = function( self, sim, unit )
		local userUnit = unit:getUnitOwner()
		if userUnit:getTraits().invisDuration then
			return STRINGS.SCMODS_ITEMS.ABILITIES.CLOAK_REUSE
		else
			return STRINGS.ABILITIES.CLOAK_USE
		end
	end,

	canUseAbility = function( self, sim, unit )
		-- Must have a user owner.
		local userUnit = unit:getUnitOwner()
		if not userUnit then
			return false
		end
		if unit:getTraits().cooldown and unit:getTraits().cooldown > 0 then
			return false, util.sformat( STRINGS.UI.REASON.COOLDOWN, unit:getTraits().cooldown )
		end
		if unit:getTraits().usesCharges and unit:getTraits().charges < 1 then
			return false, util.sformat( STRINGS.UI.REASON.CHARGES )
		end
		if unit:getTraits().pwrCost and userUnit:getPlayerOwner():getCpus() < unit:getTraits().pwrCost then -- Nub: Unutilized, retained for future.
			return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
		end
		if not unit:getTraits().cloakInVision then
			if sim:canPlayerSeeUnit( sim:getNPC(), userUnit ) then
				return false, STRINGS.UI.REASON.CANT_CLOAK_IN_VISION
			end
		end
		return abilityutil.checkRequirements( unit, userUnit )
	end,

	executeAbility = function( self, sim, unit )
		local userUnit = unit:getUnitOwner()
		userUnit:setInvisible( true, unit:getTraits().duration, unit:getTraits().cloakDistanceMax )
		userUnit:resetAllAiming()
		if unit:getTraits().range then
			local x0, y0 = userUnit:getLocation()
			local units = getTargetUnits( sim, userUnit, x0, y0, unit:getTraits().range )
			for i, cellUnit in ipairs( units ) do
				if not sim:canPlayerSeeUnit( sim:getNPC(), cellUnit ) or unit:getTraits().cloakInVision then
					cellUnit:setInvisible( true, unit:getTraits().duration, unit:getTraits().cloakDistanceMax )
				end
			end
		end
		inventory.useItem( sim, userUnit, unit )
		sim:processReactions( userUnit )
	end
}
return useInvisiCloak
