local abilityutil = include( "sim/abilities/abilityutil" )
local inventory = include( "sim/inventory" )
local mission_util = include( "sim/missions/mission_util" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local util = include( "modules/util" )

local SC_huntdaemon =
{
	profile_icon = "gui/icons/item_icons/items_icon_small/SC_item_hunterchip_small.png",
	proxy = true,

	createToolTip = function( self, sim, abilityOwner, abilityUser, targetID )
		return abilityutil.formatToolTip( STRINGS.SCMODS_ITEMS.ABILITIES.HUNT, string.format( STRINGS.SCMODS_ITEMS.ABILITIES.HUNT_DESC, sim:getUnit( targetID ):getName() ))
	end,

	getName = function()
		return STRINGS.SCMODS_ITEMS.ABILITIES.HUNT
	end,

	acquireTargets = function( self, targets, game, sim, unit )
		local userUnit = unit:getUnitOwner()
		local cell = sim:getCell( userUnit:getLocation() )
		local units = {}
		for dir, exit in pairs( cell.exits ) do
			for _, cellUnit in ipairs( exit.cell.units ) do
				if cellUnit:getTraits().mainframe_ice and cellUnit:getTraits().mainframe_ice > 0 and ( cellUnit:getTraits().mainframe_program or ( sim:getHideDaemons() and not cellUnit:getTraits().daemon_sniffed )) then
					table.insert( units, cellUnit )
				end
			end
		end
		return targets.unitTarget( game, units, self, unit, userUnit )
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
		return abilityutil.checkRequirements( unit, userUnit )
	end,

	executeAbility = function( self, sim, unit, userUnit, target )
		local userUnit = unit:getUnitOwner()
		local target = sim:getUnit( target )
		local x0, y0 = userUnit:getLocation()
		local x1, y1 = target:getLocation()
		local newFacing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
		sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = userUnit:getID(), facing = newFacing, sound = "SpySociety/Actions/use_scanchip", soundFrame = 10 })
		sim:dispatchEvent( simdefs.EV_SCRIPT_ENTER_MAINFRAME )
		sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )
		if not target:getTraits().mainframe_program then
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HUD_INCIDENT_NEGATIVE.path )
			mission_util.showDialog( sim, STRINGS.UI.DIALOGS.NO_DAEMON_TITLE, STRINGS.UI.DIALOGS.NO_DAEMON_BODY )
		else
			target:getTraits().mainframe_program = nil
			sim:dispatchEvent( simdefs.EV_KILL_DAEMON, { unit = target })
			if target:getTraits().daemonHost then
				sim:getUnit( target:getTraits().daemonHost ):killUnit( sim )
				target:getTraits().daemonHost = nil
			end
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_DAEMON_REVEAL.path )
			inventory.useItem( sim, userUnit, unit )
		end
	end
}
return SC_huntdaemon