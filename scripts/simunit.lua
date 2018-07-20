local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local simunit = include( "sim/simunit" )

function simunit:onStartTurn( sim )

	if sim:isVersion( "0.17.5" ) then
		if self:getPlayerOwner() == sim:getPC() then
			self:tickKO( sim )
		end
	end

	if sim:isVersion( "0.17.9" ) then
		self:getTraits().augment_nika_2_triggered = nil
	end

	if self:getTraits().kinetic_capacitor_bonus_charged then
		self:getTraits().kinetic_capacitor_bonus_charged = nil
	end

	if self:getTraits().unlimitedAttacks then
		self:getTraits().unlimitedAttacks = nil
	end

	if self:getTraits().tempMeleeBoost then
		self:getTraits().tempMeleeBoost = 0
	end

	if self:getBrain() then
		self:getBrain():onStartTurn( sim )
	end

	if self._abilities then
		for i, ability in ipairs( self._abilities ) do
			if ability.automatic then
				ability:executeAbility( sim, self, self )
			end
		end
	end

	local traits = self:getTraits()

	if traits.shieldsMax ~= nil then
		if traits.shields < traits.shieldsMax then
			traits.shields = traits.shields + 1
		end
	end

	if traits.apMax then
		traits.ap = traits.apMax
	end

	if self:getPlayerOwner() ~= nil then
		local power = 0
		for i = 1, self:countAugments( "augment_distributed_processing" ) do
			if sim:getTurnCount() % 2 == 0 then
				power = power + 1
			end
		end
		if power > 0 then
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { txt = util.sformat( STRINGS.UI.FLY_TXT.PLUS_PWR, power ), unit = self, color = { r = 255/255, g = 255/255, b = 51/255 }})
			self:getPlayerOwner():addCPUs( power )
		end
	end

	if traits.invisDuration then
		traits.invisDuration = traits.invisDuration - 1
		if traits.invisDuration <= 0 then
			traits.invisDuration = nil
			self:setInvisible( false )
			if traits.cloakDistance then
				traits.cloakDistance = nil
			end
		else
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { unit = self, txt = util.sformat( STRINGS.SCMODS_ITEMS.FLY_TXT.CLOAKED, self:getTraits().invisDuration ), color = { r = 255/255, g = 255/255, b = 51/255 }})
		end
	end

	if traits.genericPiercing then
		traits.genericPiercing = nil
	end

	for i, childUnit in ipairs( self:getChildren() ) do
		local childTraits = childUnit:getTraits()

		if ( childTraits.cooldown or 0 ) > 0 then
			childTraits.cooldown = childTraits.cooldown - 1
		end

		if childTraits.energyWeapon == "active" then
			childTraits.energyWeapon = "used"
		end

		if childTraits.nopwr_guards then
			childTraits.nopwr_guards = {}
		end

		if childTraits.extraAPMax then
			childTraits.extraAP = childTraits.extraAPMax
		end
	end

	if traits.mainframeRecapture and not self:isKO() then
		self:recaptureMainframeItems( sim, traits.mainframeRecapture )
	end

	traits.temporaryProtect = nil
	self:getTraits().overloadCount = nil
	self:checkOverload( sim )

	if self:getTraits().floatTxtQue then
		for i, floatItem in ipairs( self:getTraits().floatTxtQue ) do
			local x0, y0 = self:getLocation()
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { txt = floatItem.txt, x = x0, y = y0, color = floatItem.color })
			-- jcheng: assuming all floattexts are for gaining AP
			sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = self })
		end
		self:getTraits().floatTxtQue = {}
	end

	if traits.pulseScan and not self:isKO() and self:getPlayerOwner():isNPC() then
		local cells = self:getAreaCells()
		sim:dispatchEvent( simdefs.EV_PULSE_SCAN, { unit = self, cells = cells, range = self:getTraits().range })
		for i, cell in ipairs( cells ) do
			for i, cellUnit in ipairs( cell.units ) do
				sim:scanCell( self, cell, true )
			end
		end
	end

	if traits.data_hacking then
		if self:getPlayerOwner():isPC() then
			local hackUnit = sim:getUnit( traits.data_hacking )
			hackUnit:progressHack()
		end
	end
end

function simunit:setInvisible( state, duration )

	local sim = self._sim

	if ( self:getTraits().invisible == true ) ~= ( state == true ) then
		local cell = self:getSim():getCell( self:getLocation() )
		self._sim:generateSeers( self )
		self:getTraits().invisible = state
		local x2, y2 = self:getLocation()

		if state then
			sim:emitSound( simdefs.SOUND_CLOAK, x2, y2, nil )
		else
			sim:dispatchEvent( simdefs.EV_CLOAK_OUT, { unit = self })
		end

		-- Refresh before notifying seers, so that the unit appears correct if 'stuff' happens.
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self })
		self._sim:notifySeers()

		if self:getTraits().invisible then
			-- Run CLOAK Augments
			sim:dispatchEvent( simdefs.EV_CLOAK_IN, { unit = self })

			if duration == nil then
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { txt = STRINGS.SCMODS_ITEMS.FLY_TXT.CLOAKED_NODURATION, x = x2, y = y2, color = { r = 255/255, g = 255/255, b = 51/255, a = 1 }})
			else
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { txt = util.sformat( STRINGS.SCMODS_ITEMS.FLY_TXT.CLOAKED, duration ), x = x2, y = y2, color = { r = 255/255, g = 255/255, b = 51/255, a = 1 }})
			end

			if self:countAugments( "augment_chameleon_movement" ) > 0 then
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { txt = STRINGS.ITEMS.AUGMENTS.CHAMELEON_MOVEMENT, x = x2, y = y2, color = { r = 255/255, g = 255/255, b = 51/255, a = 1 }})
				self:getTraits().mp = self:getTraits().mp + 6
			end

			if self:countAugments( "augment_holocircuit_overloaders" ) > 0 then
				sim:startTrackerQueue( true )
				sim:startDaemonQueue()

				if sim:isVersion( "0.17.5" ) then
					sim:emitSound( simdefs.SOUND_HOLOCIRCUIT_OVERLOAD, x2, y2, self )
				else
					sim:emitSound( simdefs.SOUND_OVERLOAD, x2, y2, self )
				end

				sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, { x = x2, y = y2, range = simdefs.HOLOCIRCUIT_RANGE })
				sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
				local x2, y2 = self:getLocation()
				local cells = simquery.fillCircle( sim, x2, y2, simdefs.HOLOCIRCUIT_RANGE, 0 )

				for i, cell in ipairs( cells ) do
					for i, cellUnit in ipairs( cell.units ) do
						if simquery.isEnemyAgent( self:getPlayerOwner(), cellUnit ) and not cellUnit:isKO() then
							if cellUnit:getTraits().canKO then
								cellUnit:setKO( sim, simdefs.HOLOCIRCUIT_KO )
							elseif cellUnit:getTraits().isDrone and cellUnit.deactivate then
								cellUnit:deactivate( sim )
							end
						end
					end
				end

				sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
				sim:startTrackerQueue( false )
				sim:processDaemonQueue()
			end
		end
	end

	if self:getTraits().invisible then
		if duration ~= nil then
			self:getTraits().invisDuration = math.max( self:getTraits().invisDuration or 0, duration or 0 )
		end
	else
		self:getTraits().invisDuration = nil
	end
end