local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local inventory = include( "sim/inventory" )
local abilityutil = include( "sim/abilities/abilityutil" )
local speechdefs = include( "sim/speechdefs" )
local mathutil = include( "modules/mathutil" )

local SC_jackin_velocity =
{
	proxy = true,

	onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
		local tooltip = util.tooltip( hud._screen )
		local section = tooltip:addSection()
		local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )
		local targetUnit = sim:getUnit( targetUnitID )
		section:addLine( targetUnit:getName() )
		section:addAbility( self:getName( sim, abilityOwner, abilityUser, targetUnitID ), STRINGS.SCMODS_ITEMS.ABILITIES.VELOCITY_DESC, "gui/items/icon-action_hack-console.png" )
		if reason then
			section:addRequirement( reason )
		end
		return tooltip
	end,

	getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
		local targetUnit = sim:getUnit( targetUnitID )
		local cpus, bonus = self:calculateCPUs( abilityOwner, abilityUser, targetUnit )
		if bonus > 0 then
			return util.sformat( STRINGS.SCMODS_ITEMS.ABILITIES.VELOCITY_TIP_BONUS, cpus, bonus, ( cpus + bonus ) * 2 )
		else
			return util.sformat( STRINGS.SCMODS_ITEMS.ABILITIES.VELOCITY_TIP, cpus, cpus * 2 )
		end
	end,

	profile_icon = "gui/icons/item_icons/items_icon_small/SC_item_velocitydrive_small.png",

	calculateCPUs = function( self, abilityOwner, unit, targetUnit )
		local bonus = unit:getTraits().hacking_bonus or 0
		return math.ceil( targetUnit:getTraits().cpus ), bonus
	end,

	isTarget = function( self, abilityOwner, unit, targetUnit )
		if not targetUnit:getTraits().mainframe_console then
			return false
		end
		if targetUnit:getTraits().mainframe_status ~= "active" then
			return false
		end
		if ( targetUnit:getTraits().cpus or 0 ) == 0 then
			return false
		end
		return true
	end,

	acquireTargets = function( self, targets, game, sim, abilityOwner, unit )
		local x0, y0 = unit:getLocation()
		local units = {}
		for _, targetUnit in pairs( sim:getAllUnits() ) do
			local x1, y1 = targetUnit:getLocation()
			if x1 and self:isTarget( abilityOwner, unit, targetUnit ) then
				local range = mathutil.dist2d( x0, y0, x1, y1 )
				if range <= 1 and simquery.isConnected( sim, sim:getCell( x0, y0 ), sim:getCell( x1, y1 )) then
					table.insert( units, targetUnit )
				end
			end
		end
		return targets.unitTarget( game, units, self, abilityOwner, unit )
	end,

	canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		-- This is a proxy ability, but only usable if the proxy is in the inventory of the user.
		if abilityOwner ~= unit and abilityOwner:getUnitOwner() ~= unit then
			return false
		end
		local targetUnit = sim:getUnit( targetUnitID )
		if targetUnit then
			if targetUnit:getTraits().mainframe_console_lock > 0 then -- Nub: Unutilized, retained for future.
				return false, STRINGS.UI.REASON.CONSOLE_LOCKED
			end
		end
		if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
			return false, util.sformat( STRINGS.UI.REASON.COOLDOWN,abilityOwner:getTraits().cooldown )
		end
		return abilityutil.checkRequirements( abilityOwner, unit )
	end,

	executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		sim:emitSpeech( unit, speechdefs.EVENT_HIJACK ) -- Nub: Unutilized, retained for future.
		sim._resultTable.consoles_hacked = sim._resultTable.consoles_hacked and sim._resultTable.consoles_hacked + 1 or 1
		local targetUnit = sim:getUnit( targetUnitID )
		local x1, y1 = targetUnit:getLocation()
		local x0, y0 = unit:getLocation()
		local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
		sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID = targetUnit:getID(), facing = facing, sound = simdefs.SOUNDPATH_USE_CONSOLE, soundFrame = 10 })
		local triggerData = sim:triggerEvent( simdefs.TRG_UNIT_HIJACKED, { unit = targetUnit, sourceUnit = unit }) -- Unutilized, retained for future.
		if not triggerData.abort then
			local cpus, bonus = self:calculateCPUs( abilityOwner, unit, targetUnit )
			local jackinAPbonus = ( cpus + bonus ) * 2
			sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = unit })
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { unit = unit, txt = util.sformat( STRINGS.SCMODS_ITEMS.FLY_TXT.VELOCITY, jackinAPbonus )})
			unit:addMP( jackinAPbonus )
			unit:getPlayerOwner():addCPUs( cpus + bonus, sim, x1, y1 )
			inventory.useItem( sim, unit, abilityOwner )
			targetUnit:getTraits().hijacked = true -- Nub: Unutilized, retained for future.
			targetUnit:getTraits().mainframe_suppress_range = nil -- Nub: Redundant, retained for future.
			targetUnit:setPlayerOwner( abilityOwner:getPlayerOwner() )
			targetUnit:getTraits().cpus = 0
		end
		sim:processReactions( unit )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit })
	end,
}
return SC_jackin_velocity