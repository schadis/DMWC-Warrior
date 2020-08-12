local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, Enemy5Y, Enemy5YC, Enemy10Y, Enemy10YC, Enemy30Y,
      Enemy30YC, Enemy8Y, Enemy8YC, rageLost, dumpEnabled, castTime, syncSS, combatLeftCheck, stanceChangedSkill,
      stanceChangedSkillTimer, stanceChangedSkillUnit, targetChange, whatIsQueued, oldTarget, rageLeftAfterStance, firstCheck,
      secondCheck, thirdCheck, SwingMH, SwingOH, MHSpeed
local base, posBuff, negBuff = UnitAttackPower("player")
local effectiveAP = base + posBuff + negBuff  
local UseCDsTime = 0
local SunderStacks = 0
local SunderedMobStacks = {}
local ReadyCooldownCountValue

	  
local stanceNumber = {[1] = "Battle", [2] = "Defensive", [3] = "Berserk"}	  
-- if stanceChangedSkillTimer == nil then stanceChangedSkillTimer = DMW.Time end


-- some display things of procs
-- hooksecurefunc(DMW.Functions.AuraCache, "Event", function(...)
    -- local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
          -- spellID, spellName, spellSchool, auraType = ...
    -- -- if event == "SPELL_EXTRA_ATTACKS" then print("swing extra") end
    -- -- 15601,"Hand of Justice"
    -- if event == "SPELL_EXTRA_ATTACKS" and sourceGUID == DMW.Player.GUID then
        -- -- RunMacro("aastop")
        -- print("proc hoj")
    -- end
-- end)

-- Debug Print Thing
-- local debugItem
-- local function Debug(item, value)
    -- if Setting("Debug") then
        -- if debugItem ~= arg then
            -- print(arg)
            -- debugItem = arg
        -- end
    -- end
-- end

local stanceCheck = {
    Battle = {
        ["Bloodthirst"] = true,
		["MortalStrike"] = true,
        ["Bloodrage"] = true,
        ["Overpower"] = true,
        ["Hamstring"] = true,
        ["MockingBLow"] = true,
        ["Rend"] = true,
        ["Retaliation"] = true,
        ["SweepStrikes"] = true,
        ["ThunderClap"] = true,
        ["Charge"] = true,
        ["Execute"] = true,
        ["SunderArmor"] = true,
        ["ShieldBash"] = true
    },
    Defensive = {
        ["Bloodthirst"] = true,
		["MortalStrike"] = true,
        ["Bloodrage"] = true,
        ["Rend"] = true,
        ["Disarm"] = true,
        ["Revenge"] = true,
        ["ShieldBlock"] = true,
        ["ShieldBash"] = true,
        ["ShieldWall"] = true,
        ["ShieldSlam"] = true,
        ["SunderArmor"] = true,
        ["Taunt"] = true
    },
    Berserk = {
        ["BersRage"] = true,
		["MortalStrike"] = true,
        ["Bloodthirst"] = true,
        ["Bloodrage"] = true,
        ["Hamstring"] = true,
        ["Intercept"] = true,
        ["Pummel"] = true,
        ["SunderArmor"] = true,
        ["Recklessness"] = true,
        ["Whirlwind"] = true,
        ["Execute"] = true
    }
}
local interruptList = {
    ["Heal"] = true,
    ["Polymorph"] = true,
    ["Chain Heal"] = true,
    ["Venom Spit"] = true,
    ["Bansheee Curse"] = true,
    ["Polymorph"] = true,
    ["Holy Light"] = true,
    ["Fear"] = true,
    ["Flame Cannon"] = true,
    ["Renew"] = true
}
local SunderImmune = {["Totem"] = true, ["Mechanical"] = true}

-- Getting SunderStacks
local function GetSunderStacks()
	--local timeStamp, subEvent, _, sourceID, sourceName, _, _, targetID = ...;
	
		if DMW.Player.Target ~= nil 
		and DMW.Player.Target.Distance < 50 then
			for i = 1, 16 do
				if UnitGUID("target") == nil then
					break		
				elseif DMW.Player.Target.ValidEnemy and UnitDebuff("target", i) == "Sunder Armor" then
					SunderedMobStacks[UnitGUID("target")] = select(3, UnitDebuff("target", i))
					break
				elseif DMW.Player.Target.ValidEnemy and UnitDebuff("target", i) ~= "Sunder Armor" then
					SunderedMobStacks[UnitGUID("target")] = 0
				end
			end
		end
		if DMW.Player.Target ~= nil 
		and DMW.Player.Target.Distance < 50 then
			for k, v in pairs(SunderedMobStacks) do
				if k == UnitGUID("target")
				and v == (0 or 1 or 2 or 3 or 4 or 5) 
					then
					SunderStacks = v
					break
				elseif k == UnitGUID("target")
				and v ~= (0 or 1 or 2 or 3 or 4 or 5)
					then
					SunderStacks = 5
					break
				elseif k ~= UnitGUID("target") then
				SunderStacks = 5
				end
			end	
		end
end

local function Buffsniper()
local worldbufffound = false
	
	if (Setting("WCB") or Setting("Ony_Nef") or Setting("ZG"))
		then
		if Setting("WCB") 
		and not Setting("Ony_Nef")
		and not Setting("ZG")
		then
			
			for i = 1, 32 do
				if select(10, UnitAura("player", i)) == 16609 then
				worldbufffound = true
				break end
			end	
		elseif Setting("Ony_Nef")
		and not Setting("WCB") 
		and not Setting("ZG")
		then
			
			for i = 1, 32 do
				if select(10, UnitAura("player", i)) == 22888 then
				worldbufffound = true
				break end
			end	
		elseif Setting("ZG") 
		and not Setting("WCB") 
		and not Setting("Ony_Nef")		
		then
			
			for i = 1, 32 do
				if select(10, UnitAura("player", i)) == 24425 then
				worldbufffound = true
				break end
			end			
		end
		
		if worldbufffound then		
		DMW.Settings.profile.Rotation.WCB = false
		DMW.Settings.profile.Rotation.Ony_Nef = false
		DMW.Settings.profile.Rotation.ZG = false
		Logout()
		end
	end	
end


-- cancel Yellow hit when the mod is called
local function cancelAAmod()
    if IsCurrentSpell(Spell.Cleave.SpellID) 
	or IsCurrentSpell(Spell.HeroicStrike.SpellID) 
		then SpellStopCasting() end
end

-- Calculation of Units Armor
local function GetUnitArmor(unit, dmg, calc)
    local reduction
    local enemy = unit.Level
    local reduction = dmg / calc
    -- Armor = Reduction * ((85 * enemy) + 400) / (100 -  reduction)
    -- Reduction / 100 * ([467.5 * Enemy_Level] + Armor - 22167.5) = Armor
    -- 1 to 59	DR% = Armour / (Armour + 400 + (85*attacker level))
    -- 60+	DR% = Armour / (Armour + 400 + 85*(attacker level + 4.5*(attacker level-59)))
end

-- Not used
-- local function dumpStart() return Player.Power >= Setting("Rage Dump") or dumpEnabled end

local function dumpRage(value)

	-- Dumps Rage in first place with HS or Cleave -- if there is still rage it dumps it with the next part
    if whatIsQueued == "NA" 
		then
        if Setting("RotationType") == 1 
		and Enemy5YC >= 2 
		and Player.Power >= 30 
		then 
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 3
				then
				RunMacroText("/cast Cleave")
				value = value - 20
				DMW.Player.SwingDump = true
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 3
				then
				RunMacroText("/cast Cleave")
				value = value - 20
				DMW.Player.SwingDump = true
			end
			
        elseif Setting("RotationType") == 1
		and Player.Power >= 30
		and threatPercent >= 88	
		then
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 3
				then
				RunMacroText("/cast Cleave")
				value = value - 20
				DMW.Player.SwingDump = true
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 3
				then
				RunMacroText("/cast Cleave")
				value = value - 20
				DMW.Player.SwingDump = true
			end
			
		elseif Player.Power >= 30
		and HUD.Dump_HS_OnOff == 1 
		then		
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 3
				then
				RunMacroText("/cast Heroic Strike")
				value = value - 13
				DMW.Player.SwingDump = true
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 3
				then
				RunMacroText("/cast Heroic Strike")
				value = value - 13
				DMW.Player.SwingDump = true
			end

        end
    else
        -- if DMW.Player.SwingDump == nil then
            if whatIsQueued == "HS" then
                value = value - 13
            elseif whatIsQueued == "CLEAVE" then
                value = value - 20
            end
        -- end
    end

	-- if there is still rage left dump it with BT OR WW or Harmstring 

    if value > 0 then
        if Setting("RotationType") == 1 or Setting("RotationType") == 2
		and Target 
			then
            if Setting("BT/MS")
			and Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() == 0
			and Player.Power >= 30
			then
                Spell.Bloodthirst:Cast(Target)
            elseif Setting("BT/MS")
			and Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() == 0
			and Player.Power >= 30
			then
                Spell.MortalStrike:Cast(Target)			
			elseif Setting("Whirlwind") 
			and Spell.Whirlwind:Known()
			and Spell.Whirlwind:CD() == 0
			and Player.Power >= 25
			then
                Spell.Whirlwind:Cast(Player)
			elseif Setting("Hamstring Dump") 
			and Player.Power >= Setting("Hamstring dump above # rage") 
			and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE") 
			and Spell.Hamstring:Known()
			and GCD == 0 
			then
                Spell.Hamstring:Cast(Target)
            end
			
        elseif Setting("Hamstring Dump") 
		and Player.Power >= Setting("Hamstring dump above # rage") 
		and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE") 
		and Spell.Hamstring:Known()
		and GCD == 0 
		then
            for k, v in pairs(Enemy5Y) 
			do Spell.Hamstring:Cast(v) 
			end
        end

        return true
    end

end

local function stanceDanceCast(spell, dest, stance)
    if rageLost <= Setting("Rage Lost on stance change") then
        if GetShapeshiftFormCooldown(1) == 0 and not stanceChangedSkill and Player.Power >= Spell[spell]:Cost() and Spell[spell]:CD() <= 0.3 then
            if stance == "Battle" then
                if Spell.StanceBattle:Cast() then
                    stanceChangedSkill = spell
                    stanceChangedSkillTimer = DMW.Time
                    stanceChangedSkillUnit = dest
                end
            elseif stance == "Defensive" then
                if Spell.StanceDefense:Cast() then
                    stanceChangedSkill = spell
                    stanceChangedSkillTimer = DMW.Time
                    stanceChangedSkillUnit = dest
                end
            elseif stance == "Berserk" then
                if Spell.StanceBers:Cast() then
                    stanceChangedSkill = spell
                    stanceChangedSkillTimer = DMW.Time
                    stanceChangedSkillUnit = dest
                end
            end
        end
    else
	-- if not stance dance dump the rage thats too much
        dumpRage(rageLost)
    end
    return true
end



-- average AutoAttack DPS
function dpsAA()
    local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage = UnitDamage("player")
    local speed, offhandSpeed = UnitAttackSpeed("player")
    local apGain, be, ze = UnitAttackPower("player")
    -- return ((maxDamage + minDamage) / 2 / speed) + apGain
    return (maxDamage + minDamage) / 2 - 3.4 * (apGain + be + ze)/ 14
end

-- Time to Rage Cost Ratio
local function timeToCost(value)
    -- return Spell[spell].Cost()
    local deficit = value <= Player.Power and 0 or (value - Player.Power)
    local damageForOneRage = Player.Level * 0.5 -- = 1 rage
    local realGain = dpsAA() / damageForOneRage
    return math.floor(deficit, realGain)
    -- every UnitAttackSpeed("player") u get 1
end

-- Regular Spellcast
local function regularCast(spell, Unit, pool)
    if pool and Spell[spell]:Cost() > Player.Power then return true end
    if Spell[spell]:Cast(Unit) then return true end
end


-- Smartcast Spell with Stance Check
local function smartCast(spell, Unit, pool)

    if Spell[spell] ~= nil then

        if (Setting("RotationType") == 1 or Setting("RotationType") == 10 or Setting("RotationType") == 2) then
            if stanceCheck[firstCheck][spell] then
                if Stance == firstCheck then
					if Spell[spell]:Cast(Unit) then return true end
                else
                    if stanceDanceCast(spell, Unit, firstCheck) then return true end
                end
            elseif stanceCheck[secondCheck][spell] then
                if Stance == secondCheck then
                    if Spell[spell]:Cast(Unit) then return true end
                else
                    if stanceDanceCast(spell, Unit, secondCheck) then return true end
                end
            elseif stanceCheck[thirdCheck][spell] then
                if Stance == thirdCheck then
                    if Spell[spell]:Cast(Unit) then return true end
                else
                    if stanceDanceCast(spell, Unit, thirdCheck) then return true end
                end
            else
                if Spell[spell]:Cast(Unit) then return true end
            end
		

        end
        if pool and Spell[spell]:CD() <= 1.5 then return true end
    end
end






-- Auto EXECUTE
----------- EXECUTE HUD SETTINGS-----------
-- Execute 360++,
-- Execute If <= 3 units,
-- Execute |cffffffffTarget",
-- Execute |Mixed Execute,
-- Execute |cFFFFFF00Disabled"
----------- EXECUTE HUD SETTINGS-----------

local function AutoExecute()
	--Getting Executable Tagets in 5yards Range
    -- if Player.Power >= 10 then
    local exeCount = 0
    if HUD.Execute == 1 or HUD.Execute == 2 or HUD.Execute == 3
		then
        for _, Unit in ipairs(Enemy5Y) do
            if Unit.HP <= 20 then
                exeCount = exeCount + 1
            end
        end
    end
    if HUD.Execute == 1 
		then
        if Spell.Execute:Known() 
		and GCD == 0 
			then
            for _, Unit in ipairs(Enemy5Y) do
                if Unit.HP <= 20
				and Unit.Health >= 500 then
                    smartCast("Execute", Unit) 
                end
            end
			return true
        end
    elseif HUD.Execute == 2 
		then
        if Enemy5YC <= 3 then -- <= 3 then
            if Spell.Execute:Known() 
			and GCD == 0 
			then
                for _, Unit in ipairs(Enemy5Y) do
                    if Unit.HP <= 20 
					and Unit.Health >= 500 then
                        smartCast("Execute", Unit) 
                    end
                end
                return true
            end
        end
    elseif HUD.Execute == 3 
		then
        if Target 
			and Target.HP <= 20
			and not Target.Dead 
			and Target.Distance <= 2 
			and Target.Attackable 
			and Target.Facing
			and Spell.Execute:Known()
			and GCD == 0 
				then
					if Spell.Bloodthirste:Known()
						and Spell.Bloodthirst:CD() == 0
						and effectiveAP >= 2000
							then smartCast("Bloodthirst", Target)
							return true		
					elseif Spell.MortalStrike:Known()
						and Spell.MortalStrike:CD() == 0 
						and effectiveAP >= 2000
							then smartCast("MortalStrike", Target)
							return true
					else
						smartCast("Execute", Target) 
						return true
					end
					
		end
	elseif HUD.Execute == 4
        then
		if Enemy5YC <= 6 
			and Enemy5YC >= 2
			and exeCount >= 1
			and Target.HP > 20
			then 
				if Spell.Execute:Known() 
				and GCD == 0 
				then
					for _, Unit in ipairs(Enemy5Y) do
						if Unit.HP < 20 
						and Unit.Health >= 500 then
							smartCast("Execute", Unit) 
						end
					end
					return true
				end
		
		
		elseif Enemy5YC <=1
			and Target 
			and Target.HP <= 20
			and not Target.Dead 
			and Target.Distance <= 2 
			and Target.Attackable 
			and Target.Facing
			and Spell.Execute:Known()
			and GCD == 0 
				then
					if Spell.Bloodthirste:Known()
						and Spell.Bloodthirst:CD() == 0
						and effectiveAP >= 2000
							then smartCast("Bloodthirst", Target)
							return true		
					elseif Spell.MortalStrike:Known()
						and Spell.MortalStrike:CD() == 0 
						and effectiveAP >= 2000
							then smartCast("MortalStrike", Target)
							return true
					else
						smartCast("Execute", Target) 
						return true
					end
					
		end

	
	end
end




-- Auto Overpower
local function AutoOverpower()
    if Setting("Overpower") 
	and Spell.Overpower:Known()
	then
        for _, Unit in ipairs(Enemy5Y) do
            if Player.OverpowerUnit[Unit.Pointer] ~= nil
			and Player.Power <= 25 
			and Unit.HP > 20 
			and Player.SwingMH >= 1
			and Spell.Overpower:CD() < Player.OverpowerUnit[Unit.Pointer].time - 0.3 
			then
				if Spell.Bloodthirste:Known()
				and Spell.Bloodthirst:CD() >= 2 
				then                 
					if smartCast("Overpower", Unit, nil) 
					then return true end
				elseif Spell.MortalStrike:Known()
				and Spell.MortalStrike:CD() >= 2 
				then                 
					if smartCast("Overpower", Unit, nil) 
					then return true end
				end
            end
        end
    end
end

--Auto Revenge
local function AutoRevenge()
    if (Setting("Revenge") or DMW.Settings.profile.Rotation.RotationType == 10)
	and Spell.Revenge:Known()
	then for _, Unit in ipairs(Enemy5Y) do if Spell.Revenge:Cast(Unit) then return true end end end
end

local function AutoBuff()
    if Setting("BattleShout")
	and Spell.BattleShout:Known()
	and not Buff.BattleShout:Exist(Player) 
		then 
			if Spell.BattleShout:Cast(Player) 
				then return true 
			end 
	end
end


--Checks what spell is in Q
local function checkOnHit()
    -- for k,v in ipairs(Spell.HeroicStrike.Ranks) do
    --     if IsCurrentSpell(v) then
    --         return true
    --     end
    -- end
    for k, v in ipairs(Spell.HeroicStrike.Ranks) do if IsCurrentSpell(v) then return "HS" end end
    for k, v in ipairs(Spell.Cleave.Ranks) do if IsCurrentSpell(v) then return "CLEAVE" end end
    return "NA"
end



local function ReadyCooldown()
			ReadyCooldownCountValue = 0
			
			if Item.DiamondFlask:Equipped() 
			and Item.DiamondFlask:CD() == 0
			then 
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			if Spell.DeathWish:Known()
			and Spell.DeathWish:CD() == 0
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			-- if Item.Earthstrike:Equipped()
			-- and Item.Earthstrike:CD() == 0 	
			-- then
				-- ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			-- end	
			
			-- if Item.JomGabbar:Equipped() 
			-- and Item.JomGabbar:CD() == 0 	
			-- then
				-- ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			-- end
			
			if Spell.BloodFury:Known() 
			and Spell.BloodFury:CD() == 0 
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Spell.BerserkingTroll:Known()
			and Spell.BerserkingTroll:CD() == 0 
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Reckl.")
			and Spell.Recklessness:Known()
			and Spell.Recklessness:CD() == 0 
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1	
			end
			
			if Setting("Use Best Rage Potion") and ((GetItemCount(13442) >= 1 and GetItemCooldown(13442) == 0) or (GetItemCount(5633) >= 1 and GetItemCooldown(5633) == 0))
				then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if ReadyCooldownCountValue > 0 
			then return true
			
			elseif ReadyCooldownCountValue == 0
			then return false
			end	


end

local function CoolDowns()		-- none == 1 -- auto == 2 -- keypress == 3
	if Setting("CoolD.") == 2 
		then
		if Item.DiamondFlask:Equipped() 
		and Item.DiamondFlask:CD() == 0
		and Target.TTD <= Setting("TTD for DiamondFlask")
		then 
			if Item.DiamondFlask:Use(Player) then return false end
			
		elseif Spell.DeathWish:Known()
		and Player.Power >= 10
		and Spell.DeathWish:CD() == 0 
		and Player.Target.TTD <= Setting("TTD for DeathWish")
		then
			if smartCast("DeathWish", Player, true) then return true end
			
		-- elseif Item.Earthstrike:Equipped()
		-- and Item.Earthstrike:CD() == 0 	
		-- and Player.Target.TTD <= Setting("TTD for Earthstrike") 
		-- then
			-- if Item.Earthstrike:Use(Player) then return true end
			
		-- elseif Item.JomGabbar:Equipped() 
		-- and Item.JomGabbar:CD() == 0 	
		-- and Player.Target.TTD <= Setting("TTD for JomGabbar") 
		-- then
			-- if Item.JomGabbar:Use(Player) then return true end
			
		elseif Spell.BloodFury:Known() 
		and Spell.BloodFury:CD() == 0 
		and Player.Target.TTD <= Setting("TTD for BloodFury")
		then
			if Spell.BloodFury:Cast(Player) then return true end
			
		elseif Spell.BerserkingTroll:Known()
		and Spell.BerserkingTroll:CD() == 0 
		and Player.Target.TTD <= Setting("TTD for BerserkingTroll") 
		then
			if Spell.BerserkingTroll:Cast(Player) then return true end
		
		elseif Setting("Reckl.")
		and Spell.Recklessness:Known()
		and Spell.Recklessness:CD() == 0 
		and Player.Target.TTD <= Setting("TTD for Recklessness") 
		then
			if smartCast("Recklessness", Player, true) then return true end
			
		elseif Setting("Use Best Rage Potion") and GetItemCount(13442) >= 1 and GetItemCooldown(13442) == 0 and Player.Target.TTD <= Setting("TTD for RagePotion") 
			then
			name = GetItemInfo(13442)
			RunMacroText("/use " .. name)
			return true
		elseif Setting("Use Best Rage Potion") and GetItemCount(5633) >= 1 and GetItemCooldown(5633) == 0 and Player.Target.TTD <= Setting("TTD for RagePotion") 
			then
			name = GetItemInfo(5633)
			RunMacroText("/use " .. name)
			return true 
			
		else return false
		
		end
		
	elseif Setting("CoolD.") == 3
			then
				if Item.DiamondFlask:Equipped() 
				and Item.DiamondFlask:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for DiamondFlask")) <= GetTime()
				then 
					if Item.DiamondFlask:Use(Player) then return true end
			
				elseif Spell.DeathWish:Known()
				and Spell.DeathWish:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for DeathWish")) <= GetTime()
				then
					if smartCast("DeathWish", Player, true) then end
					
				-- elseif Item.Earthstrike:Equipped()
				-- and Item.Earthstrike:CD() == 0
				-- and UseCDsTime ~= 0
				-- and (UseCDsTime + Setting("Seconds after Keypress for Earthstrike")) <= GetTime()			
				-- then
					-- if Item.Earthstrike:Use(Player) then end
					
				-- elseif Item.JomGabbar:Equipped() 
				-- and Item.JomGabbar:CD() == 0
				-- and UseCDsTime ~= 0
				-- and (UseCDsTime + Setting("Seconds after Keypress for JomGabbar")) <= GetTime()			
				-- then
					-- if Item.JomGabbar:Use(Player) then end
					
				elseif Spell.BloodFury:Known() 
				and Spell.BloodFury:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for BloodFury")) <= GetTime()			
				then
					if Spell.BloodFury:Cast(Player) then end
					
				elseif Spell.BerserkingTroll:Known()
				and Spell.BerserkingTroll:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for BerserkingTroll")) <= GetTime()			
				then
					if Spell.BerserkingTroll:Cast(Player) then  end
				
				elseif Setting("Reckl.")
				and Spell.Recklessness:Known()
				and Spell.Recklessness:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for Recklessness")) <= GetTime()				
				then
					if smartCast("Recklessness", Player, true) then end		
				
				elseif Setting("Use Best Rage Potion") and GetItemCount(13442) >= 1 and GetItemCooldown(13442) == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for RagePotion")) <= GetTime()
					then
					name = GetItemInfo(13442)
					RunMacroText("/use " .. name)
				elseif Setting("Use Best Rage Potion") and GetItemCount(5633) >= 1 and GetItemCooldown(5633) == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + Setting("Seconds after Keypress for RagePotion")) <= GetTime()				
					then
					name = GetItemInfo(5633)
					RunMacroText("/use " .. name)
				
				
				else return false
				
				end
	end
end




-- Check for Which spell the stance was Changed
local function StanceChangedSpell()
    if stanceChangedSkill and stanceChangedSkillUnit and stanceChangedSkillTimer then
        Spell[stanceChangedSkill]:Cast(stanceChangedSkillUnit)
        if Spell[stanceChangedSkill]:LastCast(1) then
            -- print(stanceChangedSkill .. " at " .. stanceChangedSkillUnit.Name)
            stanceChangedSkill = nil
            stanceChangedSkillUnit = nil
            stanceChangedSkillTimer = nil
        elseif DMW.Time - stanceChangedSkillTimer >= 0.5 then
            -- print(stanceChangedSkill .. " at " .. stanceChangedSkillUnit.Name .. " failed")
            stanceChangedSkill = nil
            stanceChangedSkillUnit = nil
            stanceChangedSkillTimer = nil
        end
        return true
    end
end


	
	
function UseContainerItemByItemtype(itemtype)
  for bag = 0,4 do
    for slot = 1,GetContainerNumSlots(bag) do
		local item = GetContainerItemID(bag,slot)
		
		if item ~= nil
		and select(7, GetItemInfo(item)) == itemtype
		and select(3, GetItemInfo(item)) >= Setting("Min Q. gear equiped with Lifesaver") --minimum blue
		then
			UseContainerItem(bag,slot)
			
      end
    end
  end
end



local function lifesaver()

	DMW.Settings.profile.Rotation.RotationType = 10

	if not IsEquippedItemType("One-Handed Axes" or "One-Handed Maces" or "One-Handed Swords" or "Daggers")
	and UnitIsEnemy("player", "target")
	and not UnitPlayerControlled("target")
	and UnitInRaid("player") ~= nil
	--and Target:IsBoss()
		then
			UseContainerItemByItemtype("One-Handed Maces")
			UseContainerItemByItemtype("One-Handed Swords")
			UseContainerItemByItemtype("Daggers")
			UseContainerItemByItemtype("One-Handed Axes")
	end
	
	if not IsEquippedItemType("Shields")
	and UnitIsEnemy("player", "target")
	and not UnitPlayerControlled("target")
	and UnitInRaid("player") ~= nil
	--and Target:IsBoss()
		then
			UseContainerItemByItemtype("Shields")
	end

end

-- Slam Function
-- local function CanSlam()
    -- local atkSpeed = UnitAttackSpeed("player")
    -- local latency = (select(4, GetNetStats()) / 1000) or 0
    -- local slamPoints = 0
    -- local slamSpeed = 1.5 - (0.1 * slamPoints)
    -- local tick = (slamSpeed + latency) / atkSpeed
    --print(mai)
    -- return mainSwing <= slamSpeed + latency and mainSwing > 0.9
-- end

local function AutoTargetAndFacing()

-- Auto targets Enemy in Range
    if Setting("AutoTarget") 
	and (not Target or not Target.ValidEnemy or Target.Dead or not ObjectIsFacing("Player", Target.Pointer, 60) 
	or IsSpellInRange("Hamstring", "target") == 0) 
		then 
			if Player:AutoTarget(5, true) 
				then return true 
			end 
	end
	
-- Auto Face the Target
    if Setting("AutoFaceMelee") then
        if Player.Combat 
		and Target 
		and Target.Distance == 1 
		and not Target.Facing then
            FaceDirection(Target.Pointer, true)
            C_Timer.After(0.1, function() FaceDirection(ObjectFacing("player"), true) end)
        end
    end
end


local function SomeDebuffs()

-- Thunderclap when Units in Range without debuff
    if Setting("ThunderClap") and Setting("ThunderClap") > 0 
	and Setting("ThunderClap") <= Enemy5YC 
	and Spell.ThunderClap:Known()
	and Spell.ThunderClap:CD() == 0 
	then
        local clapCount = 0
        for k, Unit in ipairs(Enemy5Y) do 
			if not Debuff.ThunderClap:Exist(Unit) 
				then clapCount = clapCount + 1 
			end 
		end
        if clapCount >= Setting("ThunderClap") 
			then 
				if smartCast("ThunderClap", Player) 
				then return true 
				end 
		end
    end

-- PiercingHowl when Units in Range without debuff
    if Setting("PiercingHowl") 
	and Spell.PiercingHowl:Known()
	and Spell.PiercingHowl:CD() == 0 
	and Setting("PiercingHowl") > 0 
	and Setting("PiercingHowl") <= Enemy10YC 
		then
        local howlCount = 0
        for k, Unit in ipairs(Enemy10Y) do
            if not Debuff.PiercingHowl:Exist(Unit) 
				then howlCount = howlCount + 1 
			end
				if howlCount >= Setting("PiercingHowl") 
					then 
					if smartCast("PiercingHowl", Player) 
						then return true 
					end 
				end
        end
    end


-- DemoShout when Units in Range without debuff
    if Setting("DemoShout")
	and Spell.DemoShout:Known()
	and Spell.DemoShout:CD() == 0 
	and Setting("DemoShout") > 0 
	and Setting("DemoShout") <= Enemy10YC 
		then
        local demoCount = 0
        for k, Unit in pairs(Enemy10Y) do
            if not Debuff.DemoShout:Exist(Unit) 
				then demoCount = demoCount + 1 
			end
				if demoCount >= Setting("DemoShout") 
				then 
					if smartCast("DemoShout", Player) 
						then return true 
					end 
				end
        end
    end

end

local function CDKeyPressed()

			if Setting("CoolD.") == 3
				and Setting("Key for CDs") == 2 --LeftShift
				and IsLeftShiftKeyDown()
					then 
					return true 
			elseif Setting("CoolD.") == 3
				and Setting("Key for CDs") == 3 --LeftControl
				and IsLeftControlKeyDown()
					then 
					return true					
			elseif Setting("CoolD.") == 3
				and Setting("Key for CDs") == 4 --LeftAlt
				and IsLeftAltKeyDown()
					then 
					return true				
			elseif Setting("CoolD.") == 3
				and Setting("Key for CDs") == 5 --RightShift
				and IsRightShiftKeyDown()
					then 
					return true				
			elseif Setting("CoolD.") == 3
				and Setting("Key for CDs") == 6 --RightControl
				and IsRightControlKeyDown()
					then 
					return true				
			elseif Setting("CoolD.") == 3
				and Setting("Key for CDs") == 7 --RightAlt
				and IsRightAltKeyDown()
					then 
					return true			
			end
end

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
    Target = Player.Target or false
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs()
    Enemy5Y, Enemy5YC = Player:GetEnemies(5)
    Enemy8Y, Enemy8YC = Player:GetEnemies(8)
    Enemy10Y, Enemy10YC = Player:GetEnemies(10)
    Enemy30Y, Enemy30YC = Player:GetEnemies(30)

    -- mainSwing, mainSpeed = Player:GetSwing("main")
    GCD = Player:GCDRemain()
    -- firstCheck = stanceNumber[Setting("First check Stance")]
    -- secondCheck = stanceNumber[Setting("Second check Stance")]
    -- thirdCheck = stanceNumber[Setting("Third check Stance")]
    if castTime == nil then castTime = DMW.Time end
    rageLeftAfterStance = Talent.TacticalMastery.Rank * 5
    rageLost = Player.Power - rageLeftAfterStance
    dumpEnabled = false
    syncSS = false
    whatIsQueued = checkOnHit()
    -- print(whatIsQueued)
	
	-- Sets sweeping strikes to of after use
    if Setting("Auto Disable SS") 
	and HUD.Sweeping == 1 
	and Buff.SweepStrikes:Exist(Player) 
		then DMWHUDSWEEPING:Toggle(2) 
	end
	
	
	-- activate Cds on Keypress
    if Setting("CoolD.") == 3
	and CDKeyPressed()
	and ReadyCooldown()
	and HUD.CDs == 3
		then DMWHUDCDS:Toggle(2)
		UseCDsTime = GetTime()
	elseif Setting("CoolD.") == 3
	and not ReadyCooldown()
	and HUD.CDs == 2 or HUD.CDs == 1
		then DMWHUDCDS:Toggle(3)
	end
	
	
	
	
	
	
	if Setting("RotationType") == 1
		then 
		firstCheck = "Berserk"
		secondCheck = "Battle"
		thirdCheck = "Defensive"
	elseif Setting("RotationType") == 2
		then 
		firstCheck = "Defensive"
		secondCheck = "Battle"
		thirdCheck = "Berserk"
	elseif Setting("RotationType") == 10 --deffskillstance for furry
		then 
		firstCheck = "Defensive"
		secondCheck = "Berserk"
		thirdCheck = "Battle"
	end
	
	
	
	
	-- getting actual Stance
	if select(2, GetShapeshiftFormInfo(1)) then
        Stance = "Battle"
    elseif select(2, GetShapeshiftFormInfo(2)) then
        Stance = "Defensive"
    elseif select(2, GetShapeshiftFormInfo(3)) then
        Stance = "Berserk"
    end
	
	if Target and Player.Combat
	then
		threatPercent = select(4, Target:UnitDetailedThreatSituation())
		if threatPercent == nil 
			then
		threatPercent = 0
		end
	end
	
end

local function Consumes()
	-- Use Best HP Pot
	if Setting("Use Best HP Potion") then
		if DMW.Player.HP <= Setting("Use Potion at #% HP") and Player.Combat then
			if GetItemCount(13446) >= 1 and GetItemCooldown(13446) == 0 then
				name = GetItemInfo(13446)
				RunMacroText("/use " .. name)
				return true 
			elseif GetItemCount(3928) >= 1 and GetItemCooldown(3928) == 0 then
				name = GetItemInfo(3928)
				RunMacroText("/use " .. name)
				return true
			elseif GetItemCount(1710) >= 1 and GetItemCooldown(1710) == 0 then
				name = GetItemInfo(1710)
				RunMacroText("/use " .. name)
				return true
			elseif GetItemCount(929) >= 1 and GetItemCooldown(929) == 0 then
				name = GetItemInfo(929)
				RunMacroText("/use " .. name)
				return true
			elseif GetItemCount(858) >= 1 and GetItemCooldown(858) == 0 then
				name = GetItemInfo(858)
				RunMacroText("/use " .. name)
				return true
			elseif GetItemCount(118) >= 1 and GetItemCooldown(118) == 0 then
				name = GetItemInfo(118)
				RunMacroText("/use " .. name)
				return true
			end
		end
	end
end



function Warrior.Rotation()
    Locals()
	Consumes()


	
-- got Battlestance out of Combat
    if Setting("BattleStance NoCombat") and Player.CombatLeft then
        if Stance ~= "Battle" then
            if Spell.StanceBattle:IsReady() then
                Spell.StanceBattle:Cast()
            else
                return true
            end
        end
    end
	
-- Charge	
    if Target 
	and UnitCanAttack("player", Target.Pointer) 
	and not Target.Dead 
	and Target.Distance >= 8 
	and Target.Distance < 25 
	and IsSpellInRange("Charge", "target") == 1 
	and not UnitIsTapDenied(Target.Pointer) 
		then
            if HUD.Charge == 1 
			and not Player.Combat
			and Spell.Charge:Known()
			and Spell.Charge:CD() == 0 
				then
                if smartCast("Charge", Target) 
					then return true 
				end
            elseif (HUD.Charge == 1 or HUD.Charge == 2) 
			and Spell.Intercept:CD() == 0 
			and Player.Power >= 10 
			and Spell.Intercept:Known()
			and not Spell.Charge:LastCast(1) 
				then
                if smartCast("Intercept", Target) 
					then return true 
				end
            end
    end	

	
--	checks the Spell Why Stance was changed
    if StanceChangedSpell() 
		then return true 
	end


	AutoTargetAndFacing()
	SomeDebuffs()

    -----------------FURY DW PART--------------------FURY DW PART--------------------FURY DW PART--------------------FURY DW PART------
    ---FURY DW PART--------------------FURY DW PART--------------------FURY DW PART--------------------FURY DW PART--------------------
    -----------------FURY DW PART--------------------FURY DW PART--------------------FURY DW PART--------------------FURY DW PART------

	
    if Setting("RotationType") == 1 --or (Target and Target.Player) 
		then
		
        if Setting("Lifesaver") 
		and not IsEquippedItemType("Two-Hand")
				then
					UseContainerItemByItemtype("Two-Handed Axes" or "Two-Handed Maces" or "Two-Handed Swords")
		end
		
		
		-- AutoAttack
		if Target 
			and not Target.Dead 
			and Target.Distance <= 5 
			and Target.Attackable 
			and not IsCurrentSpell(Spell.Attack.SpellID) then
				StartAttack()
        end
		
        if Player.Combat 
		and Enemy5YC > 0 
			then

			-----life saver if aggro---------
			if Setting("Lifesaver") 
			and not UnitPlayerControlled("target")
			and UnitName("targettarget") == UnitName("player")
			and Target:IsBoss() 
				then
					lifesaver()
			
			elseif Setting("Lifesaver") 
			and UnitName("targettarget") ~= UnitName("player")
				then
					DMW.Settings.profile.Rotation.RotationType = 1
								
			elseif Setting("Lifesaver") 
			and UnitName("targettarget") ~= UnitName("player")
			and not IsEquippedItemType("Two-Hand")
				then
					UseContainerItemByItemtype("Two-Handed Axes" or "Two-Handed Maces" or "Two-Handed Swords")					
			end
			
			
			
			-- Bers Rage --
			if Setting("Berserker Rage") 
				and Spell.BersRage:CD() == 0 
				and Spell.BersRage:Known() 
				and	smartCast("BersRage", Player)
					then return true
			end
			
			-- Bloodrage --
			if Setting("Bloodrage")
				and Spell.Bloodrage:Known()
				and Spell.Bloodrage:CD() == 0
				and Player.Power <= 50 
				and Player.HP >= 30
				and regularCast("Bloodrage", Player)
					then return true
			end
			
			
			-- When DeathWish_Racial in Hud is 1 it uses cooldowns
            --if HUD.DeathWish_Racial == 1 
			
			--Changed to Auto or Keypress
			if Setting("CoolD.") == 2
				and Target 
				and Target:IsBoss()
				and ReadyCooldown()
				and Target.TTD >= 10 and  Target.TTD <= 80
					then 
					if CoolDowns() then return true end 
			
			elseif Setting("CoolD.") == 3
					and CDs
					and Target 
					and Target:IsBoss()
					and ReadyCooldown()
						then 
						if CoolDowns() then end
					-- if Item.DiamondFlask:Equipped()
					-- and Item.DiamondFlask:CD() == 0
					-- and Target 
					-- and Target:IsBoss()
					-- and Target.TTD <= Setting("TTD for DiamondFlask")
						-- then 
						-- if Item.DiamondFlask:Use(Player) then end
					-- end
			end

			--unqueue HS or Cleave when low rage
			if Player.Power < 20
				and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
				and Player.SwingMH <= 0.3
				and Player.SwingMH > 0
					then				
						cancelAAmod()
			end
			
			-- AutoKICK with Pummel if something in 5Yards casts something
            if Setting("Pummel/ShildBash") 
				and Spell.Pummel:Known()
				and Spell.Pummel:CD() == 0
				then
					for _, Unit in ipairs(Enemy5Y) do
						local castName = Unit:CastingInfo()
						if castName ~= nil 
						and (Unit:Interrupt() or interruptList[castName]) 
							then
							if smartCast("Pummel", Unit, true) 
								then return true end
						end
					end
			end

			
			-- Buffs Battleshout Casts Overpower or EXECUTE
            if AutoExecute() or AutoBuff() or AutoOverpower() 
				then return true 
			end
			
			if Target then
			
				-- more then/or 2 Targets in Range
                if Enemy8YC >= 2 then
					if Setting("Whirlwind")
						and Spell.Whirlwind:Known()
						and Spell.Whirlwind:CD() == 0
						and Player.Power >= 25
						and smartCast("Whirlwind", Player, true) 
							then return true 
					end

					if Setting("BT/MS") 
						and Spell.Bloodthirst:Known()
						and Spell.Bloodthirst:CD() == 0
						and Spell.Whirlwind:CD() >= 2 
						and Player.Power >= 30
						and smartCast("Bloodthirst", Target, true) 
							then return true 
					elseif Setting("BT/MS") 
						and Spell.MortalStrike:Known()
						and Spell.MortalStrike:CD() == 0
						and Spell.Whirlwind:CD() >= 2 
						and Player.Power >= 30
						and smartCast("MortalStrike", Target, true) 
							then return true 
					end
					
				end
					
					
                else				
				
                    if Setting("SunderArmor") 
						and Spell.SunderArmor:Known()
						and Spell.SunderArmor:CD() == 0
						and SunderStacks < Setting("Apply Stacks of Sunder Armor")
						and smartCast("SunderArmor", Target, true)
							then return true 
					end
                        
                    if Setting("BT/MS")
						and Spell.Bloodthirst:Known()
						and Spell.Bloodthirst:CD() == 0
						and Player.Power >= 30
						and smartCast("Bloodthirst", Target, true) 
							then return true 					
					elseif Setting("BT/MS") 
						and Spell.MortalStrike:Known()
						and Spell.MortalStrike:CD() == 0
						and Spell.Whirlwind:CD() >= 2 
						and Player.Power >= 30
						and smartCast("MortalStrike", Target, true) 
							then return true 
					end
                        
                    if Setting("Whirlwind")
						and Spell.Whirlwind:Known()
						and Spell.Whirlwind:CD() == 0
						and Player.Power >= 25
							then
							if Spell.Bloodthirste:Known()
								and Spell.Bloodthirst:CD() >= 3
								then                 
									if smartCast("Whirlwind", Unit, nil) 
									then return true end
								
							elseif Spell.MortalStrike:Known()
								and Spell.MortalStrike:CD() >= 3 
								then                 
									if smartCast("Whirlwind", Unit, nil) 
									then return true end
							end
                    end
				
					-- Hamstring --
					if (Setting("Hamstring < 30% Enemy HP") or Setting("Hamstring PvP"))
						and Spell.Hamstring:Known()
						and GCD == 0 
						and Player.Combat 
						and (Target.HP <= 35 or Setting("Hamstring PvP"))
						and Target.Distance <= 5 
						and not Debuff.Hamstring:Exist(Target) 
						and smartCast("Hamstring", Target, true) 
							then return true
					end
				
                --AbuseHS()
				--Rage dump with HS or Cleave if there is still rage with harmstring if activated
                if Setting("Rage Dump?") 
					and Player.Power >= Setting("Rage Dump") 
						then
							if dumpRage(Player.Power) 
							--if dumpRage(Player.Power - Setting("Rage Dump")) 
							then return true 
							end
                end
				
			end	
        end
		
	--------------------------------------------switch to deff stance with lifesaver rotation---------------------------------------
	elseif Setting("RotationType") == 10 --or (Target and Target.Player) 
			then

			if not Player.Combat and Setting("Lifesaver")
				then
				UseContainerItemByItemtype("Two-Handed Axes" or "Two-Handed Maces" or "Two-Handed Swords")
				DMW.Settings.profile.Rotation.RotationType = 1
			end
			
			
			-- AutoAttack
			if Target 
				and not Target.Dead 
				and Target.Distance <= 5 
				and Target.Attackable 
				and not IsCurrentSpell(Spell.Attack.SpellID) 
					then
					StartAttack()
			end
			
			if Player.Combat 
			and Enemy5YC > 0 
				then


				-----life saver if aggro---------
				if Setting("Lifesaver") 
				and not UnitPlayerControlled("target")
				and UnitName("targettarget") == UnitName("player")
				and Target:IsBoss() 
				and (DMW.Settings.profile.Rotation.RotationType ~= 10 or not IsEquippedItemType("Shields"))
					then
						lifesaver()
				elseif Setting("Lifesaver") 
				and UnitName("targettarget") ~= UnitName("player")
					then
						DMW.Settings.profile.Rotation.RotationType = 1
									
				elseif Setting("Lifesaver") 
				and UnitName("targettarget") ~= UnitName("player")
				and not IsEquippedItemType("Two-Hand")
					then
						UseContainerItemByItemtype("Two-Handed Axes" or "Two-Handed Maces" or "Two-Handed Swords")					
				end


				-- Bloodrage --
				if Setting("Bloodrage")
					and Spell.Bloodrage:Known()
					and Spell.Bloodrage:CD() == 0
					and Player.Power <= 50 
					and Player.HP >= 30
					and regularCast("Bloodrage", Player)
						then return true
				end
				
				-- Buffs Battleshout
				if AutoBuff() or AutoRevenge()
					then return true 
				end

				--wall if low health
				if Player.HP <= 60
					and Spell.ShieldWall:Known()
					and Spell.ShieldWall:CD() == 0
					and IsEquippedItemType("Shields")
					and smartCast("ShieldWall", Player, true)
						then return true 
				end
				
				
				if Target 
					then
					
					--unqueue HS or Cleave when low rage
					if Player.Power < 20
						and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
						and Player.SwingMH <= 0.3
						and Player.SwingMH > 0
							then				
							cancelAAmod()
					end
					
					
					
					-- AutoKICK with Shield Bash if something in 5Yards casts something
					if Setting("Pummel/ShildBash") 
						and IsEquippedItemType("Shields")
						and Spell.ShieldBash:Known()
						and Spell.ShieldBash:CD() == 0
							then
							local castName = Target:CastingInfo()
							if castName ~= nil 
								and (Target:Interrupt() or interruptList[castName]) 
									then
									if smartCast("ShieldBash", Target, true) 
									then return true end
							end
					end

                    if Setting("BT/MS")
						and Spell.Bloodthirst:Known()
						and Spell.Bloodthirst:CD() == 0
						and Player.Power >= 30
						and smartCast("Bloodthirst", Target, true) 
							then return true 
					
					elseif Setting("BT/MS") 
						and Spell.MortalStrike:Known()
						and Spell.MortalStrike:CD() == 0
						and Spell.Whirlwind:CD() >= 2 
						and Player.Power >= 30
						and smartCast("MortalStrike", Target, true) 
							then return true 
					end
						

                    if Spell.Bloodthirst:Known()
						and Spell.Bloodthirst:CD() >= 3
						and Spell.SunderArmor:Known()
						and GCD == 0
						and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
						and SunderStacks < 5
						and smartCast("SunderArmor", Target, true)
							then return true 
					end
					
					if Spell.MortalStrike:Known()
						and Spell.MortalStrike:CD() >= 3
						and Spell.SunderArmor:Known()
						and GCD == 0
						and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
						and SunderStacks < 5
						and smartCast("SunderArmor", Target, true)
							then return true 
					end

					
					for k, v in pairs(Enemy10Y) do
						if v.Target 
						and Spell.ShieldBlock:Known()
						and Spell.ShieldBlock:CD() == 0
						and IsEquippedItemType("Shields") 
						and Player.HP <= 80 
						and UnitIsUnit(v.Target, "player") 
						and (v.SwingMH > 0 or v.SwingMH <= 0.5) 
							then
							smartCast("ShieldBlock", Player)
							break
						end
					end
	
					-- AbuseHS()
					--Rage dump with HS or Cleave if there is still rage with harmstring if activated
					if Setting("Rage Dump?") 
					and Player.Power >= Setting("Rage Dump") 
						then
							if dumpRage(Player.Power - Setting("Rage Dump")) 
								then return true 
							end
					end

					

				end
			end
	end	
end	
		



	
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
eventFrame:RegisterEvent("UNIT_AURA");
eventFrame:RegisterEvent("CHAT_MSG_ADDON");






eventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "UNIT_AURA") and DMW.UI.MinimapIcon then
		GetSunderStacks()
		Buffsniper()		
	-- elseif(event == "CHAT_MSG_ADDON") then
		-- Buffsniper()		
	end
end)












----------------------------------------------------
-- local abuseOH = false
-- local hsQueued

-- local function AbuseHS()
    -- if Setting("abuse") and Player.Combat and Target and not Target.Dead and DMW.Player.SwingDump == nil then
        -- if DMW.Tables.Swing.Player.HasOH then
            -- hsQueued = false
            -- if whatIsQueued == "HS" or whatIsQueued == "CLEAVE" or abuseOH then hsQueued = true end

            -- print(hsQueued)
            -- for k,v in ipairs(Spell.HeroicStrike.Ranks) do
                -- if IsCurrentSpell(v) then
                    -- hsQueued = true
                    -- break
                -- end
            -- end
            -- print(hsQueued)
            -- if Player.SwingOH < 0.15 and Player.SwingOH + 0.2 < Player.SwingMH then
            -- if Player.SwingMH > Setting("abuse range") then
                -- if Player.SwingMH  > Player.SwingOH and Player.SwingMH > 0.3 and Player.SwingOH <= 0.3 then
                -- if not hsQueued then
                    -- if Enemy5YC >= 2 and Player.Power >= 20 then
                        -- RunMacroText("/cast Cleave")
                        -- abuseOH = true
                    -- else
                        -- if Player.Power >= 13 then
                            -- RunMacroText("/cast Heroic Strike")
                            -- abuseOH = true
                        -- end
                        -- print("MH = "..Player.SwingMH..", OH = "..Player.SwingOH)

                    -- end
                    -- print("queued")
                -- end
            -- else
                -- if hsQueued and Player.Power < Setting("Rage Dump") then
                    -- print("off")
                    -- SpellStopCasting()

                -- end
                -- abuseOH = false
            -- end
            -- if Player.SwingMH < 0.2 and abuseOH and IsCurrentSpell(11565) then
                -- SpellStopCasting()
                -- abuseOH = false
                -- print("cancel hs")
            -- else
                -- if Player.Power >= 13 and not IsCurrentSpell(11565) and Player.SwingOH < Player.SwingMH and Player.SwingOH < 0.2 then
                    -- abuseOH = true
                    -- RunMacroText("/cast heroic strike")
                    -- print("queue hs")
                -- else
                    -- if Player.SwingOH > 0.2 and abuseOH then
                        -- SpellStopCasting()
                        -- abuseOH = false
                    -- end
                -- end
            -- end
        -- end
    -- end
-- end
------------------------------------------------------------
















	-- -----------TANKING PART--------------------TANKING PART--------------------TANKING PART--------------------TANKING PART------
    -- -- TANKING PART--------------------TANKING PART--------------------TANKING PART--------------------TANKING PART--------------------
    -- -----------TANKING PART--------------------TANKING PART--------------------TANKING PART--------------------TANKING PART------
    
	-- elseif Setting("RotationType") == 2 
		-- then
        
		-- if Target 
		-- and not Target.Dead 
		-- and Target.Distance <= 5 
		-- and Target.Attackable 
		-- and not IsCurrentSpell(Spell.Attack.SpellID) then
            -- StartAttack()
        -- end
		
        -- if Player.Combat then
            -- -- Enemy5Y Threat Sorting
            
			-- for _, v in ipairs(Enemy30Y) do
                -- v.Threat = v:UnitThreatSituation()
                -- v.SelfThreat = select(5, v:UnitDetailedThreatSituation())
                -- -- v.ThreatTa
                -- -- local highestValue
                -- for k, Friend in pairs(DMW.Friends.Units) do
                    -- if Friend.Name ~= "LocalPlayer" then
                        -- local FriendThreat = select(5, v:UnitDetailedThreatSituation(Friend)) or 0
                        -- if v.highestValue == nil or v.highestValue < FriendThreat then v.highestValue = FriendThreat end
                    -- end
                -- end
                -- if v.highestValue then
                     -- v.threatDelta = v.SelfThreat - v.highestValue
                -- else
                    -- v.threatDelta = 0
                -- end
                -- -- if v.Target and UnitName(v.Target) == "Saaulgoodman" then
                    -- -- v.ForceSort = true
                    -- -- v:CustomTarget()
                -- -- else
                    -- -- v.ForceSort = false
                -- -- end
            -- end
            
			-- for _, v in ipairs(Enemy5Y) do end
            -- -- if Enemy30YC >= 2 then
                -- -- table.sort(Enemy30Y, function(x, y) return x.threatDelta < y.threatDelta end)
                -- table.sort(Enemy30Y, function(x) if x.Classification ~= "Normal" then return true else return false end end)
                -- table.sort(Enemy30Y, function(x) if x.ForceSort then return true else return false end end)
                -- -- if Setting("AutoTreatTarget") then
                    -- if Enemy30Y[1] then Enemy30Y[1]:CustomTarget() end
                    -- -- for i = 1, #Enemy30Y do if Enemy30Y[i].threatDelta <= 500 then Enemy30Y[i]:CustomTarget() end end
                -- -- end
            -- -- end



            -- if Setting("Taunt") 
			-- or Setting("MockingBlow") 
				-- then
                -- for _, Unit in ipairs(Enemy5Y) do
                    -- -- if not Unit:UnitDetailedThreatSituation(Player) then
                    -- if Unit.Threat <= 1 
					-- and Unit.highestValue 
					-- and Unit.highestValue > 0 
						-- then
                        -- -- Taunt -- if there is a sort of taunt debuff do not taunt
                        -- if Setting("Taunt") and Spell.Taunt:Known() and Spell.Taunt:CD() == 0 and not Unit:AuraByID(7922) and
                            -- not Unit:AuraByID(20560) and not Unit:AuraByID(355) then
                            -- if smartCast("Taunt", Unit) then return true end
                        -- end
                        -- -- Mockingblow -- if there is a sort of taunt debuff do not taunt
                        -- if Setting("MockingBlow") and Spell.MockingBlow:Known() and Spell.MockingBlow:CD() == 0 and not Unit:AuraByID(7922) and
                            -- not Unit:AuraByID(355) and not Unit:AuraByID(20560) then
                            -- if smartCast("MockingBlow", Unit) then return true end
                        -- end
                    -- end
                -- end
            -- end

            -- for k, v in pairs(Enemy10Y) do
                -- if v.Target 
				-- and Setting("Use ShieldBlock") 
				-- and IsEquippedItemType("Shields") 
				-- and Player.HP <= Setting("Shieldblock HP") 
				-- and UnitIsUnit(v.Target, "player") 
				-- and (v.SwingMH > 0 or v.SwingMH <= 0.5) 
					-- then
                    -- smartCast("ShieldBlock", Player)
                    -- break
                -- end
            -- end
			
            -- if AutoExecute() 
			-- or AutoRevenge() 
			-- or AutoBuff() 
			-- or AutoOverpower() 
				-- then return true 
			-- end

			-- -- Bloodrage --
			-- if Setting("Bloodrage") 
			-- and Spell.Bloodrage:IsReady() 
			-- and Player.Power <= 50 
			-- and Player.HP >= 50
			-- and regularCast("Bloodrage", Player)
				-- then return true
			-- end

			-- -- AutoKICK with Shield Bash if something in 5Yards casts something
            -- if Setting("Pummel/ShildBash") 
			-- and IsEquippedItemType("Shields") 
				-- then
				-- for _, Unit in ipairs(Enemy5Y) do
					-- local castName = Unit:CastingInfo()
					-- if castName ~= nil 
					-- and (Unit:Interrupt() or interruptList[castName]) 
						-- then
						-- if smartCast("ShieldBash", Unit, true) 
							-- then return true 
						-- end
					-- end
				-- end
			-- end

			-- -- If Prot Spec with ShielSlam
            -- if Spell.ShieldSlam:Known() 
			-- and IsEquippedItemType("Shields") 
				-- then
                -- for k, Unit in ipairs(Enemy5Y) do
                    -- if not Unit.Dead then if smartCast("ShieldSlam", Unit, true) then return true end end
                -- end
            -- end
			
            -- if Enemy5YC >= 1 then
                -- for k, Unit in ipairs(Enemy5Y) do
                    -- if Setting("SunderArmor") 
					-- and Spell.SunderArmor:IsReady() 
					-- and not SunderImmune[Unit.CreatureType] 
						-- then
                        -- if (Debuff.SunderArmor:Stacks(Unit) < Setting("Apply Stacks of Sunder Armor") 
						-- or Debuff.SunderArmor:Refresh(Unit)) 
						-- and Unit.TTD >= 4 
							-- then 
							-- if smartCast("SunderArmor", Unit) 
								-- then return true 
							-- end 
						-- end
                    -- end
                -- end
            -- end
            
			-- if Enemy8YC >= 2 
			-- and Setting("Whirlwind") 
			-- and smartCast("Whirlwind", Player) 
				-- then return true 
			-- end 

            -- if Setting("BT/MS") 
			-- and Spell.Bloodthirst:Known()
				-- then
                -- for k, Unit in ipairs(Enemy5Y) do 
					-- if smartCast("Bloodthirst", Unit, true) 
						-- then return true 
					-- end 
				-- end
            -- end
            
			-- -- bersOnTanking()
			-- if Setting("Rage Dump?") and Player.Power >= Setting("Rage Dump") 
				-- then
					-- if dumpRage(Player.Power - Setting("Rage Dump")) 
						-- then return true 
					-- end
            -- end
        -- end



	
	-------------------Other Rotations -------- I Am Looking only on a Furry Rota ATM--------------------------------------------------	
		
    
	
    -----------------FURY SLAM PART--------------------FURY SLAM PART--------------------FURY SLAM PART--------------------FURY SLAM PART------
    --FURY SLAM PART--------------------FURY SLAM PART--------------------FURY SLAM PART--------------------FURY SLAM PART---------------------
    -----------------FURY SLAM PART--------------------FURY SLAM PART--------------------FURY SLAM PART--------------------FURY SLAM PART------
    -- elseif Setting("RotationType") == 3 then
        -- if Target and not Target.Dead and Target.Distance <= 5 and Target.Attackable and not IsCurrentSpell(Spell.Attack.SpellID) then
            -- StartAttack()
        -- end
        -- if Player.Combat then
            -- if AutoBuff() or AutoOverpower() or AutoExecute() then return true end
            -- if HUD.DeathWish == 1 and Target and Target.TTD >= 7 then if CoolDowns() then return true end end
            -- if Setting("Pummel") then
                -- for _, Unit in ipairs(Enemy5Y) do
                    -- local castName = Unit:CastingInfo()
                    -- if castName ~= nil and (HUD.Interrupts == 1 or interruptList[castName]) and Unit:Interrupt() then
                        -- if smartCast("Pummel", Unit, true) then return true end
                    -- end
                -- end
            -- end
            -- if Target then
                -- -- if Target.ValidEnemy then
                    -- if Enemy8YC >= 2 and Setting("Whirlwind") and Player.Power >= 40 then
                        -- if smartCast("Whirlwind", Player) then return true end
                    -- end
                    -- if Setting("BT/MS") and Player.Power >= 45 then
                        -- if smartCast("Bloodthirst", Target) then return true end
                    -- end
                    -- -- print(mainSpeed.."   ".. mainSwing)
                    -- if Spell.Slam:IsReady() and not Player.Moving and CanSlam() then
                        -- if not Target.Facing then FaceDirection(Target.Pointer, true) end
                        -- -- print(DMW.Time)
                        -- -- print(Player:GetSwing("main"))
                        -- RunMacro("slam")
                        -- -- RunMacroText("/cast slam")
                    -- end
                -- -- end
                -- -- if Player.Power >= 70 then
                -- --     if whatIsQueued == "NA" then
                -- --         if Enemy5YC >= 2 then
                -- --             RunMacroText("/cast Cleave")
                -- --         else
                -- --             RunMacroText("/cast Heroic Strike")
                -- --         end
                -- --     end
                -- -- end
            -- end
            -- -- bersOnTanking()
        -- end -- combat
    -- -----------------FURY PROT PART--------------------FURY PROT PART--------------------FURY PROT PART--------------------FURY PROT PART------
    -- --FURY PROT PART--------------------FURY PROT PART--------------------FURY PROT PART--------------------FURY PROT PART---------------------
    -- -----------------FURY PROT PART--------------------FURY PROT PART--------------------FURY PROT PART--------------------FURY SPROTLPROTAM PART------
    -- elseif Setting("RotationType") == 4 then
        -- if Target and IsSpellInRange("Hamstring", "target") == 1 and Target.Attackable and not IsCurrentSpell(Spell.Attack.SpellID) then
            -- StartAttack()
        -- end

        -- if Player.Combat then

            -- -- if stanceChangedSkill and stanceChangedSkill == "Overpower" then
            -- --     -- print(stanceChangedSkill)
            -- --     Spell.Overpower:Cast(stanceChangedSkillUnit)
            -- --     if not Spell.Overpower:IsReady() then
            -- --         print("op down")
            -- --         stanceChangedSkill = nil
            -- --         stanceChangedSkillUnit = nil
            -- --         stanceChangedSkillTimer = nil
            -- --     end
            -- --     return true
            -- -- end
            -- for _, v in ipairs(Enemy5Y) do
                -- -- print(UnitCanAttack("player", v.Pointer))
                -- v.Threat = v:UnitThreatSituation(Player)

                -- local threat = {}
                -- local highestValue
                -- for i = 1, 4 do
                    -- local unit = "party" .. i
                    -- if UnitExists(unit) then
                        -- for _, k in pairs(DMW.Friends.Units) do
                            -- local unitthreat
                            -- if UnitGUID(unit) == k.GUID then
                                -- unitthreat = select(5, v:UnitDetailedThreatSituation(k)) or 0
                                -- -- tinsert(threat, unitthreat)
                            -- end
                            -- if unitthreat and (highestValue == nil or unitthreat > highestValue) then
                                -- highestValue = unitthreat
                            -- end
                        -- end
                    -- end
                -- end
                -- -- local highest = max(unpack(threat))
                -- if highestValue then v.threatDelta = select(5, v:UnitDetailedThreatSituation()) - highestValue end
            -- end
            -- if Enemy5YC >= 2 then table.sort(Enemy5Y, function(x, y) return x.threatDelta < y.threatDelta end) end
            -- if Enemy5YC >= 2 and Enemy5Y[1] ~= nil then Enemy5Y[1]:CustomTarget() end
            -- if Setting("Taunt") or Setting("MockingBlow") then
                -- for _, Unit in ipairs(Enemy5Y) do
                    -- if Unit.Threat <= 1 then
                        -- if Setting("Taunt") and Spell.Taunt:Known() and Spell.Taunt:CD() == 0 and not Unit:AuraByID(7922) and
                            -- not Unit:AuraByID(20560) and not Unit:AuraByID(355) then
                            -- if smartCast("Taunt", Unit) then return true end
                        -- end
                        -- -- Mockingblow --
                        -- if Setting("MockingBlow") and Spell.MockingBlow:Known() and Spell.MockingBlow:CD() == 0 and not Unit:AuraByID(7922) and
                            -- not Unit:AuraByID(355) and not Unit:AuraByID(20560) then
                            -- if smartCast("MockingBlow", Unit) then return true end
                        -- end
                    -- end
                -- end
            -- end

            -- if Setting("Use ShieldBlock") and IsEquippedItemType("Shields") and Spell.Revenge:IsReady() and Player.HP <
                -- Setting("Shieldblock HP") and Spell.ShieldBlock:Known() and Target and (Target.SwingMH == nil or Target.SwingMH <= 0.5) then
                -- smartCast("ShieldBlock", Player)
            -- end
            -- if AutoExecute() or AutoRevenge() or AutoBuff() or AutoOverpower() then return true end
            -- -- if Setting("Stance") == 2 and Stance ~= "Defense" then
            -- --     if Spell.StanceDefense:IsReady() then
            -- --         Spell.StanceDefense:Cast()
            -- --     else
            -- --         return true
            -- --     end
            -- -- elseif Setting("Stance") == 3 and Stance ~= "Bers" then
            -- --     if Spell.StanceBers:IsReady() then
            -- --         Spell.StanceBers:Cast()
            -- --     else
            -- --         return true
            -- --     end
            -- -- end
            -- -- if AutoBuff() then return true end

            -- -- if Setting("Pummel") then
            -- --     -- and Target and Target:Interrupt()
            -- --     for _, Unit in ipairs(Enemy5Y) do
            -- --         -- if Unit:Interrupt() ~= nil then print("123") end
            -- --         local castName = Unit:CastingInfo()
            -- --         -- print(castName)
            -- --         if castName ~= nil and interruptList[castName] and Unit:Interrupt() then
            -- --             -- print(castName)
            -- --             if smartCast("ShieldBash", Unit, true) then return true end
            -- --         end
            -- --     end
            -- -- end

            -- if Enemy5YC >= 2 then
                -- for k, Unit in ipairs(Enemy5Y) do
                    -- if Setting("SunderArmor") and Spell.SunderArmor:IsReady() and not SunderImmune[Unit.CreatureType] then
                        -- if (Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") or Debuff.SunderArmor:Refresh(Unit)) and
                            -- Unit.TTD >= 4 then if smartCast("SunderArmor", Unit) then return true end end
                    -- end
                -- end
            -- end
            -- -- print("123")
            -- if Enemy8YC >= 2 and Setting("Whirlwind") then if smartCast("Whirlwind", Player) then return true end end

            -- if Setting("BT/MS") and Spell.Bloodthirst:Known() then
                -- for k, Unit in ipairs(Enemy5Y) do if smartCast("Bloodthirst", Unit, true) then return true end end
            -- end
            -- if Setting("Rage Dump?") and Player.Power >= Setting("Rage Dump") then
                -- dumpRage(Player.Power - Setting("Rage Dump")) end
            -- -- bersOnTanking()
        -- end
    -- elseif Setting("RotationType") == 5 then
        -- if Target and not Target.Dead and Target.Distance <= 5 and Target.Attackable and not IsCurrentSpell(Spell.Attack.SpellID) then
            -- StartAttack()
        -- end
        -- if Player.Combat then

        -- end -- combat
    -- -----------------FURY PVP PART--------------------FURY PVP PART--------------------FURY PVP PART--------------------FURY PVP PART------
    -- --FURY PVP PART--------------------FURY PVP PART--------------------FURY PVP PART--------------------FURY PVP PART--------------------
    -- -----------------FURY PVP PART--------------------FURY PVP PART--------------------FURY PVP PART--------------------FURY PVP PART------
    -- elseif DMW.Player.Instance == "pvp" or (Target and Target.Player) then
        -- if Target and not Target.Dead and Target.Distance <= 5 and Target.Attackable and not IsCurrentSpell(Spell.Attack.SpellID) then
            -- StartAttack()
        -- end

    -- end -- rotation setting

-- end
