local abilityutil = include( "sim/abilities/abilityutil" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local use_injection = include( "sim/abilities/use_injection" )
local util = include( "modules/util" )

local SC_use_aggression = util.extend( use_injection )
{
	name = STRINGS.ABILITIES.USE_AGGRESSION,
	profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_defibulator_small.png",

	createToolTip = function( self, sim, unit )
		if unit:getTraits().ap then
			return abilityutil.formatToolTip( STRINGS.ABILITIES.USE_AGGRESSION, string.format( STRINGS.SCMODS_ITEMS.ABILITIES.VENTRICULAR_DESC_2, unit:getTraits().genericPiercing ))
		elseif unit:getTraits().unlimitedAttacks then
			return abilityutil.formatToolTip( STRINGS.ABILITIES.USE_AGGRESSION, STRINGS.SCMODS_ITEMS.ABILITIES.VENTRICULAR_DESC_3 )
		else
			return abilityutil.formatToolTip( STRINGS.ABILITIES.USE_AGGRESSION, STRINGS.SCMODS_ITEMS.ABILITIES.VENTRICULAR_DESC_1 )
		end
	end,

	isTarget = function( self, sim, userUnit, targetUnit )
		if targetUnit:getPlayerOwner() == userUnit:getPlayerOwner() and simquery.isAgent( targetUnit ) and not targetUnit:isDead() then
			return true
		end
		return false
	end,

	doInjection = function( self, sim, unit, userUnit, target )
		sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { unit = target, txt = string.format( STRINGS.SCMODS_ITEMS.FLY_TXT.PIERCEUP, unit:getTraits().genericPiercing )})
		if unit:getTraits().ap then
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { unit = target, txt = STRINGS.SCMODS_ITEMS.FLY_TXT.ATKUP })
			target:getTraits().ap = ( target:getTraits().ap or 0 ) + unit:getTraits().ap
		elseif unit:getTraits().unlimitedAttacks then
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { unit = target, txt = STRINGS.UI.FLY_TXT.AMPED })
			target:getTraits().ap = target:getTraits().apMax
			target:getTraits().unlimitedAttacks = true
		else
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { unit = target, txt = STRINGS.SCMODS_ITEMS.FLY_TXT.ATKREF })
			target:getTraits().ap = target:getTraits().apMax
			-- SC: Unless you add attacks or set to unlimited, will always refresh the attack.
		end
		target:getTraits().genericPiercing = ( target:getTraits().genericPiercing or 0 ) + unit:getTraits().genericPiercing
	end
}
return SC_use_aggression
