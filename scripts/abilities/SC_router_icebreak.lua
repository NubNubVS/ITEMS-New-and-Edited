local simdefs = include( "sim/simdefs" )

local SC_router_icebreak =
{
	automatic = true,

	executeAbility = function( self, sim, abilityOwner, unit )
		unit:getTraits().cpuTurn = unit:getTraits().cpuTurn - 1
		if unit:getTraits().cpuTurn <= 0 then
			local pool = {}
			for i, unit in pairs( sim:getAllUnits() ) do
				if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 1 and ( unit:getTraits().mainframe_status == "active" and not ( unit:getTraits().isDrone and unit:isKO() ) or unit:getTraits().mainframe_camera and unit:getTraits().mainframe_booting ) then
					table.insert( pool, unit )
				end
			end
			if #pool > 0 then
				local icebreak = unit:getTraits().icebreak
				local target = pool[ math.floor( sim:nextRand() * #pool ) + 1 ]
				sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_ICE, { unit = target, ice = target:getTraits().mainframe_ice, delta = -icebreak })
				target:getTraits().mainframe_ice = target:getTraits().mainframe_ice - icebreak
				sim:triggerEvent( simdefs.TRG_ICE_BROKEN, { unit = target }) -- Nub: For Mainframe Attunement
				sim:dispatchEvent( simdefs.EV_UNIT_ADD_FX, { unit = unit, kanim = "gui/hud_fx", symbol = "wireless_console_takeover", above = true })
				sim:dispatchEvent( simdefs.EV_UNIT_ADD_FX, { unit = target, kanim = "gui/hud_fx", symbol = "wireless_console_takeover", above = true })
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )
				sim:dispatchEvent( simdefs.EV_SCRIPT_EXIT_MAINFRAME )
			end
			unit:getTraits().cpuTurn = unit:getTraits().cpuTurnMax
		end
	end
}
return SC_router_icebreak