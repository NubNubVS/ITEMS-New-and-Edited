local abilityutil = include( "sim/abilities/abilityutil" )
local inventory = include( "sim/inventory" )
local mathutil = include( "modules/mathutil" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local speechdefs = include( "sim/speechdefs" )
local util = include( "modules/util" )

local SC_jackin_velocity =
{
	profile_icon = "gui/icons/item_icons/items_icon_small/SC_item_velocitydrive_small.png",
	proxy = true,

	calculateCPUs = function( self, abilityOwner, unit, targetUnit )
		return math.ceil( targetUnit:getTraits().cpus ), unit:getTraits().hacking_bonus or 0 -- Nub: CPUs is always an integer, math.ceil kept for compatibility.
	end,

	getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
		local cpus, bonus = self:calculateCPUs( abilityOwner, abilityUser, sim:getUnit( targetUnitID ))
		if bonus > 0 then
			return util.sformat( STRINGS.SCMODS_ITEMS.ABILITIES.VELOCITY_TIP_BONUS, cpus, bonus, ( cpus + bonus ) * 2 )
		else
			return util.sformat( STRINGS.SCMODS_ITEMS.ABILITIES.VELOCITY_TIP, cpus, cpus * 2 )
		end
	end,

	onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
		local tooltip = util.tooltip( hud._screen )
		local section = tooltip:addSection()
		local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )
		section:addLine( sim:getUnit( targetUnitID ):getName() )
		section:addAbility( self:getName( sim, abilityOwner, abilityUser, targetUnitID ), STRINGS.SCMODS_ITEMS.ABILITIES.VELOCITY_DESC, "gui/items/icon-action_hack-console.png" )
		if reason then
			section:addRequirement( reason )
		end
		return tooltip
	end,

	isTarget = function( self, abilityOwner, unit, targetUnit )
		if not targetUnit:getTraits().mainframe_console then
			return false
		end
		if targetUnit:getTraits().mainframe_status ~= "active" then
			return false
		end
		if not targetUnit:getTraits().cpus or targetUnit:getTraits().cpus == 0 then -- Nub: CPUs is never nil, check kept for compatibility.
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
				if mathutil.dist2d( x0, y0, x1, y1 ) <= 1 and simquery.isConnected( sim, sim:getCell( x0, y0 ), sim:getCell( x1, y1 )) then
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
			return false, util.sformat( STRINGS.UI.REASON.COOLDOWN, abilityOwner:getTraits().cooldown )
		end
		return abilityutil.checkRequirements( abilityOwner, unit )
	end,

	executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		sim:emitSpeech( unit, speechdefs.EVENT_HIJACK ) -- Nub: Unutilized, retained for future.
		sim._resultTable.consoles_hacked = sim._resultTable.consoles_hacked and sim._resultTable.consoles_hacked + 1 or 1
		local targetUnit = sim:getUnit( targetUnitID )
		local x0, y0 = unit:getLocation()
		local x1, y1 = targetUnit:getLocation()
		sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID = targetUnit:getID(), facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 ), sound = simdefs.SOUNDPATH_USE_CONSOLE, soundFrame = 10 })
		local triggerData = sim:triggerEvent( simdefs.TRG_UNIT_HIJACKED, { unit = targetUnit, sourceUnit = unit }) -- Unutilized, retained for future.
		if not triggerData.abort then
			local cpus, bonus = self:calculateCPUs( abilityOwner, unit, targetUnit )
			local APbonus = ( cpus + bonus ) * 2
			sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = unit })
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { txt = util.sformat( STRINGS.SCMODS_ITEMS.FLY_TXT.VELOCITY, APbonus ), x = x0, y = y0 })
			unit:addMP( APbonus )
			unit:getPlayerOwner():addCPUs( cpus + bonus, sim, x1, y1 )
			inventory.useItem( sim, unit, abilityOwner )
			targetUnit:getTraits().hijacked = true -- Nub: Unutilized, retained for future.
			targetUnit:getTraits().mainframe_suppress_range = nil -- Nub: Redundant, retained for future.
			targetUnit:setPlayerOwner( abilityOwner:getPlayerOwner() )
			targetUnit:getTraits().cpus = 0
		end
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit })
		sim:processReactions( unit )
	end
}
return SC_jackin_velocity