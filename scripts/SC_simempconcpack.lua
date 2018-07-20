local util = include( "modules/util" )
local simunit = include( "sim/simunit" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simfactory = include( "sim/simfactory" )

local SC_emp_conc = { ClassType = "simemppackconcussive" }

function SC_emp_conc:detonate( sim )
	local x0, y0 = self:getLocation()
	local sim, player = self:getSim(), self:getPlayerOwner()
	sim:startTrackerQueue( true )
	sim:startDaemonQueue()
	sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
	local units = self:getTargets( x0, y0 )
	sim:dispatchEvent( simdefs.EV_SCRIPT_EXIT_MAINFRAME )
	sim:dispatchEvent( simdefs.EV_FLASH_VIZ, { x = x0, y = y0, units = nil, range = self:getTraits().range })
	sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, { x = x0, y = y0, units = units, range = self:getTraits().range })
	for i, unit in ipairs( units ) do
		if unit:getTraits().mainframe_status or unit:getTraits().heartMonitor then
		unit:processEMP( self:getTraits().emp_duration, true )
		end
		if self:getTraits().baseDamage and simquery.isEnemyAgent( player, unit ) and not unit:getTraits().isDrone then
			if self:getTraits().canSleep then
				local damage = self:getTraits().baseDamage
				damage = unit:processKOresist( damage )
				unit:setKO( sim, damage )
			else
				sim:damageUnit( unit, self:getTraits().baseDamage )
			end
		end
	end
	sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
	sim:startTrackerQueue( false )
	sim:processDaemonQueue()
	-- Destroy the DEVICE.
	sim:emitSound( simdefs.SOUND_SMALL, x0, y0, nil )
	sim:processReactions( self )
	sim:warpUnit( self, nil )
	sim:despawnUnit( self )
end

function SC_emp_conc:getTargets( x0, y0 )
	local cells = {}
	cells = simquery.rasterCircle( self._sim, x0, y0, self:getTraits().range )
	local units = {}
	for i, x, y in util.xypairs( cells ) do
		local cell = self._sim:getCell( x, y )
		if cell then
			for _, cellUnit in ipairs( cell.units ) do
				local player = self:getPlayerOwner()
				if cellUnit ~= self and ( cellUnit:getTraits().mainframe_status or cellUnit:getTraits().heartMonitor or ( simquery.isEnemyAgent( player, cellUnit ) and not cellUnit:getTraits().isDrone )) and not cellUnit:getTraits().concussive then
					table.insert( units, cellUnit )
				end
			end
		end
	end
	return units
end

function SC_emp_conc:toggle( sim )
	self:detonate( sim )
end

-- Interface functions
local function SC_createEMPConcPack( unitData, sim )
	return simunit.createUnit( unitData, sim, SC_emp_conc )
end

simfactory.register( SC_createEMPConcPack )
return { SC_createEMPConcPack = SC_createEMPConcPack }