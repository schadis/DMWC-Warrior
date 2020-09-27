local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, Enemy5Y, Enemy5YC, Enemy10Y, Enemy10YC, Enemy30Y,
      Enemy30YC, Enemy8Y, Enemy8YC, rageLost, dumpEnabled, castTime, syncSS, combatLeftCheck, stanceChangedSkill,
      stanceChangedSkillTimer, stanceChangedSkillUnit, targetChange, whatIsQueued, oldTarget, rageLeftAfterStance, firstCheck,
      secondCheck, thirdCheck, SwingMH, SwingOH, MHSpeed, PosX, PosY, PosZ
local effectiveAP = 1500  
local UseCDsTime = 0
local SunderStacks = 0
local SunderedMobStacks = {}
local ReadyCooldownCountValue
local ItemUsage = GetTime()
local armorMitigation = 0.5
local TargetArmor = 3500
local DmgModiBuffOrStance = 1
local TargetSundered = nil

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
	  
local stanceNumber = {[1] = "Battle", [2] = "Defensive", [3] = "Berserk"}	  
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
		["Slam"] = true,
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
		["Slam"] = true,
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
		["Slam"] = true,
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

local function EnemiesAroundTarget()
	if Target
		then 
		return Target:GetEnemies(5)
	else
		return nil
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

local function CDKeyPressed()

			if Setting("CoolD Mode") == 3
				and Setting("Key for CDs") == 2 --LeftShift
				and IsLeftShiftKeyDown()
					then 
					return true 
			elseif Setting("CoolD Mode") == 3
				and Setting("Key for CDs") == 3 --LeftControl
				and IsLeftControlKeyDown()
					then 
					return true					
			elseif Setting("CoolD Mode") == 3
				and Setting("Key for CDs") == 4 --LeftAlt
				and IsLeftAltKeyDown()
					then 
					return true				
			elseif Setting("CoolD Mode") == 3
				and Setting("Key for CDs") == 5 --RightShift
				and IsRightShiftKeyDown()
					then 
					return true				
			elseif Setting("CoolD Mode") == 3
				and Setting("Key for CDs") == 6 --RightControl
				and IsRightControlKeyDown()
					then 
					return true				
			elseif Setting("CoolD Mode") == 3
				and Setting("Key for CDs") == 7 --RightAlt
				and IsRightAltKeyDown()
					then 
					return true			
			end
end

local function ReadyCooldown()
			ReadyCooldownCountValue = 0
			
			if Setting("Trinkets")
			and Item.DiamondFlask:Equipped() 
			and Item.DiamondFlask:CD() <= 1.6
			then 
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			if Setting("DeathWish")
			and Spell.DeathWish:Known()
			and Spell.DeathWish:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			if Setting("Trinkets") 
			and Item.Earthstrike:Equipped()
			and Item.Earthstrike:CD() == 0	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end	
			
			if Setting("Trinkets") 
			and Item.JomGabbar:Equipped() 
			and Item.JomGabbar:CD() == 0	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Trinkets") 
			and Item.BadgeoftheSwarmguard:Equipped() 
			and Item.BadgeoftheSwarmguard:CD() == 0	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Racials")
			and Spell.BloodFury:Known() 
			and Spell.BloodFury:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Racials")
			and Spell.BerserkingTroll:Known()
			and Spell.BerserkingTroll:CD() == 0
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Recklessness")
			and Spell.Recklessness:Known()
			and Spell.Recklessness:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1	
			end
			
			if Setting("Use Best Rage Potion") and ((GetItemCount(13442) >= 1 and GetItemCooldown(13442) <= 1.6) or (GetItemCount(5633) >= 1 and GetItemCooldown(5633) <= 1.6))
				then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if ReadyCooldownCountValue > 0 
			then return true
			
			elseif ReadyCooldownCountValue == 0
			then return false
			end	


end

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
    Target = (Player.Target or false)
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs()
	Target5Y, Target5YC = EnemiesAroundTarget()
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
	local base, posBuff, negBuff = UnitAttackPower("player")
	local effectiveAP = base + posBuff + negBuff  
	

	-- Sets sweeping strikes to of after use
    if Setting("Auto Disable SS") 
	and HUD.Sweeping == 1 
	and Buff.SweepStrikes:Exist(Player) 
		then DMWHUDSWEEPING:Toggle(2) 
	end
	
	
	-- activate Cds on Keypress
    if Setting("CoolD Mode") == 3
	and CDKeyPressed()
	and ReadyCooldown()
	and HUD.CDs == 3
		then DMWHUDCDS:Toggle(2)
		UseCDsTime = GetTime()
	elseif Setting("CoolD Mode") == 3
	and (not ReadyCooldown() or not Player.Combat)
	and (HUD.CDs == 2 or HUD.CDs == 1)
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
	end
	
	-- getting actual Stance
	if select(2, GetShapeshiftFormInfo(1)) then
        Stance = "Battle"
    elseif select(2, GetShapeshiftFormInfo(2)) then
        Stance = "Defensive"
    elseif select(2, GetShapeshiftFormInfo(3)) then
        Stance = "Berserk"
    end
	
	if not (Target or not Player.Combat)
		then
		armorMitigation = 0.5
		TargetArmor = 3500
	end
	if not Player.Combat
		then
		table.wipe(SunderedMobStacks)
	end	

	local a,b,c = 1, 1, 1
	
	if Buff.SaygesDarkFortuneofDamage:Exist(Player)
	then a = 1.1
	else a = 1
	end
	if Buff.TracesofSilithyst:Exist(Player)
	then b = 1.05
	else b = 1
	end
	if Stance == "Defensive"
	then c = 0.9
	else c = 1
	end	
	DmgModiBuffOrStance = a * b * c		
	
end

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

local function GetDTfromDetails()
	if IsAddOnLoaded("Details! Damage Meter")
	and Player.CombatTime >= 5
		then
		local currentCombat = Details:GetCurrentCombat()
		local cT = currentCombat:GetCombatTime()
		local damageTaken = 0
		local DTPS = 0
		for _, actor in currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
			if (actor:IsPlayer()) 
			then
				damageTaken = damageTaken + actor.damage_taken
				DTPS = DTPS + (actor.damage_taken/cT)
				return damageTaken, DTPS
			end
		end
	
	else
		return 0, 0
	end
end

-- Calculation of Units Armor
local function GetArmorOfTarget(...)
	Locals()
	local timeStamp, subEvent, _, sourceID, sourceName, _, _, targetID, _,_,_, SpellID, SpellName,_,BtDmg,_,_,_,_,_, critical, glancing = ...;
		local BtCalcDmg = 0.45 * effectiveAP
		local CritMuti

		if Talent.Impale.Rank == 1
			then CritMuti = 2.1
		elseif Talent.Impale.Rank == 2
			then CritMuti = 2.2
		else CritMuti = 2
		end
				
		if critical
			then
			DamageBT = (BtDmg / DmgModiBuffOrStance) / CritMuti
		else
			DamageBT = (BtDmg / DmgModiBuffOrStance)
		end
		
		armorMitigation = (BtCalcDmg - DamageBT) / BtCalcDmg
		
		TargetArmor = ((85 * UnitLevel("player") * armorMitigation + 400 * armorMitigation)/ (1 - armorMitigation))
		
		-- if TargetArmor < 0
			-- then TargetArmor = 0
		-- end
		
		if Setting("Print Target Armor") 
		and TargetArmor >= 0
			then print("Target Armor: ", round(TargetArmor, 2)) 
		elseif Setting("Print Target Armor") 
		and TargetArmor < 0
			then print("Target Armor: 0") 
		end
		
		if Setting("Print Armormitigation") then print(round(armorMitigation, 4)) end
end

--calculate rage values per MH and Offhand hit 
local function ragegain(t)--t is the time for which we calculate the rage income
	--calculate rage values per MH and Offhand hit 
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage = UnitDamage("player")
	local cFactor = 0.0091107836 * (UnitLevel("player"))^2 + 3.225598133 * (UnitLevel("player"))^2 + 4.2652911
	local mainhandSpeed = select(1, UnitAttackSpeed("player"))
	local calcDamageDoneMH = DmgModiBuffOrStance* (((maxDamage + minDamage) / 2) + (effectiveAP / 14) * mainhandSpeed)
	local rageFromDamageMH = (calcDamageDoneMH * (1 - armorMitigation)) / cFactor * 7.5
	local hasOffHand = false
	local offhandSpeed = select(2, UnitAttackSpeed("player")) 
	local calcDamageOH = 0
	local rageFromDamageOffH = 0
	local RageFromAngerPerSec = Talent.AngerManagement.Rank / 3
	
	if not t
		then return 0
	end
	
	--Check for Offhand
	if (not offhandSpeed) or (offhandSpeed == 0) 
		then
		hasOffHand = false
	else
		hasOffHand = true
    end
	
	if hasOffHand
		then 
		calcDamageOH = DmgModiBuffOrStance *(((minOffHandDamage + maxOffHandDamage)/2) + (effectiveAP / 14) * offhandSpeed * (0.5 + 0.025 * Talent.DuelWieldSpec.Rank))
		rageFromDamageOffH = (calcDamageOH * (1 - armorMitigation)) / cFactor * 7.5
	end

	--calculate rage values per Damage Taken infight (via Deatails addon)	
	local damageTaken = select(1,GetDTfromDetails())
	local DTPS = select(2,GetDTfromDetails())
	local rageFromDamageTakenPerSec = DTPS / cFactor * 2.5
		
	--calculate the summary of rage over t value
	local rageFromDamageTakenOverTime = rageFromDamageTakenPerSec * t
	local rageFromTalents = RageFromAngerPerSec * t
	local rageFromDamage = 0
	local MainHandSwings,OffHandSwings = 1, 1

	if hasOffHand
		then
		if (Player.SwingMH + 2 * mainhandSpeed) <= t
			then MainHandSwings = 3		
		elseif (Player.SwingMH + mainhandSpeed) <= t
			then MainHandSwings = 2
		elseif Player.SwingMH <= t
			then MainHandSwings = 1
		elseif Player.SwingMH > t
			then MainHandSwings = 0
		end
		
		if (Player.SwingOH + 2 * offhandSpeed) <= t
			then MainHandSwings = 3	
		elseif (Player.SwingOH + offhandSpeed) <= t
			then OffHandSwings = 2
		elseif Player.SwingOH <= t
			then OffHandSwings = 1
		elseif Player.SwingOH > t
			then OffHandSwings = 0
		end
		rageFromDamage = MainHandSwings * rageFromDamageMH + OffHandSwings * rageFromDamageOffH + rageFromDamageTakenOverTime + rageFromTalents
		return rageFromDamage
	 
	elseif not hasOffHand
		then
		if (Player.SwingMH + 2 * mainhandSpeed) <= t
			then MainHandSwings = 3		
		elseif (Player.SwingMH + mainhandSpeed) <= t
			then MainHandSwings = 2
		elseif Player.SwingMH <= t
			then MainHandSwings = 1
		elseif Player.SwingMH > t
			then MainHandSwings = 0
		end
		rageFromDamage = MainHandSwings * rageFromDamageMH + OffHandSwings * rageFromDamageOffH + rageFromDamageTakenOverTime + rageFromTalents
		return rageFromDamage
	end

	return 0	
	
end

--Can we Slam Function
local function CanSlam()
    local latency = (select(4, GetNetStats()) / 1000) or 0
    local slamSpeed = (1.5 - (0.1 * Talent.ImprovedSlam.Rank))

	if not Player.Moving
	and (select(1, UnitAttackSpeed("player")) - Player.SwingMH) <= 0.15
	and select(1, UnitAttackSpeed("player")) >= (slamSpeed + latency)
	and IsSpellInRange("Slam", "target") == 1
		then
		return true
	end
end

-- cancel Yellow hit when the mod is called
local function cancelAAmod()
    if IsCurrentSpell(Spell.Cleave.SpellID) 
	or IsCurrentSpell(Spell.HeroicStrike.SpellID) 
		then SpellStopCasting() 
		end
end

local function stanceDanceCast(spell, dest, stance)
    if (Setting("FuckRage&StanceDance") or rageLost <= Setting("RageLose on StanceChange")) then
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
       dumpRage(Player.Power - Setting("Rage Dump"))
    end
    return true
end

-- Regular Spellcast
local function regularCast(spell, Unit, pool)
    if pool and Spell[spell]:Cost() > Player.Power then return true end
    if Spell[spell]:Cast(Unit) then 
	return true end
end

-- Smartcast Spell with Stance Check
local function smartCast(spell, Unit, pool)

    if Spell[spell] ~= nil then

        if (Setting("RotationType") == 1 or Setting("RotationType") == 2) 
			then
            if stanceCheck[firstCheck][spell] then 
                if Stance == firstCheck then
					if Spell[spell]:Cast(Unit) then 
					return true end
                else
                    if stanceDanceCast(spell, Unit, firstCheck) then 
					return true end
                end
            elseif stanceCheck[secondCheck][spell] then
                if Stance == secondCheck then
                    if Spell[spell]:Cast(Unit) then 
					return true end
                else
                    if stanceDanceCast(spell, Unit, secondCheck) then
					return true end
                end
            elseif stanceCheck[thirdCheck][spell] then
                if Stance == thirdCheck then
                    if Spell[spell]:Cast(Unit) then 
					return true end
                else
                    if stanceDanceCast(spell, Unit, thirdCheck) then 
					return true end
                end
            else
                if Spell[spell]:Cast(Unit) then 
				return true end
            end
		

        end
       -- if pool and Spell[spell]:CD() <= 1.5 then return true end
    end
end

-- Dumps Rage in first place with HS or Cleave -- if there is still rage it dumps it with the next part
local function dumpRage(value)

--------Slam Dump Harmstring over HS--------

	if Setting("Slam")
	and Setting("RotationType") == 1
	and (Enemy5YC >= 2 or not Setting("Heroic Strike"))
	and Setting("Cleave")
	and whatIsQueued == "NA"
	and Player.Power >= Spell.Cleave:Cost()
		then
		RunMacroText("/cast Cleave")
		DMW.Player.SwingDump = true
	end

	if Setting("Slam")
	and Setting("Hamstring Dump")
	and Setting("RotationType") == 1
	and Setting("Only HString MHSwing >= GCD")
	and Player.Power >= Setting("Hamstring dump above # rage") 
	and Player.SwingMH > 1.5
	and Spell.Hamstring:Known()
	and Player.Power >= Spell.Hamstring:Cost()
	and GCD == 0 
		then
        if Spell.Bloodthirst:Known()
		and Spell.Bloodthirst:CD() >= 1.5
		and Spell.Whirlwind:Known()
		and Spell.Whirlwind:CD() >= 1.5
			then
			if smartCast("Hamstring", Target)  
				then
				value = value - Spell.Hamstring:Cost()
			end
		elseif Spell.MortalStrike:Known()
		and Spell.MortalStrike:CD() >= 1.5
		and Spell.Whirlwind:Known()
		and Spell.Whirlwind:CD() >= 1.5
			then
			if smartCast("Hamstring", Target)  
				then
				value = value - Spell.Hamstring:Cost()
			end
		end
	elseif Setting("Slam")
	and Setting("Hamstring Dump")	
	and Setting("RotationType") == 1
	and not Setting("Only HString MHSwing >= GCD")
	and Player.Power >= Setting("Hamstring dump above # rage") 
	and Spell.Hamstring:Known()
	and Player.Power >= Spell.Hamstring:Cost()
	and GCD == 0 
		then
        if Spell.Bloodthirst:Known()
		and Spell.Bloodthirst:CD() >= 1.5
		and Spell.Whirlwind:Known()
		and Spell.Whirlwind:CD() >= 1.5
			then
			if smartCast("Hamstring", Target) 
				then
				value = value - Spell.Hamstring:Cost()
			end
		elseif Spell.MortalStrike:Known()
		and Spell.MortalStrike:CD() >= 1.5
		and Spell.Whirlwind:Known()
		and Spell.Whirlwind:CD() >= 1.5
			then
			if smartCast("Hamstring", Target)  
				then
				value = value - Spell.Hamstring:Cost()
			end
		end
	end

--------------normal dump part--------------

	if whatIsQueued == "NA" 
		then
        if (Setting("RotationType") == 1 or Setting("RotationType") == 2)
		and (Enemy5YC >= 2 or not Setting("Heroic Strike"))
		and Setting("Cleave")
		and Player.Power >= Spell.Cleave:Cost()
		and (not Setting("Calculate Rage") or (Player.Power - Spell.Cleave:Cost() + ragegain(Spell.Whirlwind:CD())) >= Spell.Whirlwind:Cost())
			then 
			RunMacroText("/cast Cleave")
			value = value - Spell.Cleave:Cost()
			DMW.Player.SwingDump = true

		elseif Player.Power >= Spell.HeroicStrike:Cost()
		and Setting("Heroic Strike")
		then		
			if  Spell.Bloodthirst:Known()
			and (not Setting("Calculate Rage") or (Player.Power - Spell.HeroicStrike:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
				then
				RunMacroText("/cast Heroic Strike")
				value = value - Spell.HeroicStrike:Cost()
				DMW.Player.SwingDump = true
			elseif Spell.MortalStrike:Known()
			and (not Setting("Calculate Rage") or (Player.Power - Spell.HeroicStrike:Cost() + ragegain(Spell.MortalStrike:CD())) >= Spell.MortalStrike:Cost())
				then
				RunMacroText("/cast Heroic Strike")
				value = value - Spell.HeroicStrike:Cost()
				DMW.Player.SwingDump = true
			end

        end
    else
        -- if DMW.Player.SwingDump == nil then
            if whatIsQueued == "HS" 
			and Setting("RotationType") == 1
				then
                value = value - Spell.HeroicStrike:Cost()
			elseif whatIsQueued == "HS" 
			and	Setting("RotationType") == 2
				then
				value = value - Spell.HeroicStrike:Cost()
            elseif whatIsQueued == "CLEAVE" then
                value = value - Spell.Cleave:Cost()
            end
        -- end
    end

	-- if there is still rage left dump it with BT OR WW or Harmstring 

    if value > 0 
		then
        if Spell.Bloodthirst:Known()
		and Player.Power >= Spell.Bloodthirst:Cost()
		and Spell.Bloodthirst:CD() == 0
		then
            if smartCast("Bloodthirst", Target)  
				then
				value = value - Spell.Bloodthirst:Cost()
			end
        elseif Spell.MortalStrike:Known()
		and Player.Power >= Spell.MortalStrike:Cost()
		and Spell.MortalStrike:CD() == 0
		then
            if smartCast("MortalStrike", Target) 
				then
				value = value - Spell.MortalStrike:Cost()					
			end
		elseif Setting("Whirlwind") 
		and Setting("RotationType") == 1
		and Spell.Whirlwind:Known()
		and Player.Power >= Spell.Whirlwind:Cost()
		and Spell.Whirlwind:CD() == 0
		and (not Setting("Calculate Rage") or (Player.Power - Spell.Whirlwind:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
			then
            if smartCast("Whirlwind", Target)
				then
				value = value - Spell.Whirlwind:Cost()	
			end
		elseif Setting("SunderArmor") 
		and Setting("RotationType") == 2
		and Spell.SunderArmor:Known()
		-- and not Debuff.ExposeArmor:Exist(Target)
		and Player.Power >= Spell.SunderArmor:Cost()
		and Spell.SunderArmor:CD() == 0
			then
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 1.5
			and (not Setting("Calculate Rage") or (Player.Power - Spell.SunderArmor:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
				then
				if smartCast("SunderArmor", Target)
					then
					value = value - Spell.SunderArmor:Cost()
				end
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 1.5
			and (not Setting("Calculate Rage") or (Player.Power - Spell.SunderArmor:Cost() + ragegain(Spell.MortalStrike:CD())) >= Spell.MortalStrike:Cost())
				then
				if smartCast("SunderArmor", Target) 
					then
					value = value - Spell.SunderArmor:Cost()
				end
			end
		elseif Setting("SunderArmor")
		and Setting("RotationType") == 2
		-- and Debuff.ExposeArmor:Exist(Target)				
		and Spell.BattleShout:Known() 
		and Spell.BattleShout:CD() == 0
		and Player.Power >= Spell.BattleShou:Cost()
		then 
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 1.5
			and (not Setting("Calculate Rage") or (Player.Power - Spell.BattleShout:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
				then
				if Spell.BattleShout:Cast(Player) 
					then 
					value = value - Spell.BattleShout:Cost() 
				end
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 1.5
			and (not Setting("Calculate Rage") or (Player.Power - Spell.BattleShout:Cost() + ragegain(Spell.MortalStrike:CD())) >= Spell.MortalStrike:Cost())
				then
				if Spell.BattleShout:Cast(Player)  
					then 
					value = value - Spell.BattleShout:Cost() 
				end
			end 	
		elseif Setting("Hamstring Dump")
		and Setting("RotationType") == 1
		and Setting("Only HString MHSwing >= GCD")
		and Player.SwingMH > 1.5
		and Player.Power >= Setting("Hamstring dump above # rage") 
		and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
		and Spell.Hamstring:Known()
		and Player.Power >= Spell.Hamstring:Cost()
		and GCD == 0 
			then
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 1.5
			and Spell.Whirlwind:Known()
			and Spell.Whirlwind:CD() >= 1.5
				then
				if smartCast("Hamstring", Target)   
					then
					value = value - Spell.Hamstring:Cost()
				end
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 1.5
			and Spell.Whirlwind:Known()
			and Spell.Whirlwind:CD() >= 1.5
				then
				if smartCast("Hamstring", Target)  
					then
					value = value - Spell.Hamstring:Cost()
				end
			end
		elseif Setting("Hamstring Dump")	
		and Setting("RotationType") == 1
		and not Setting("Only HString MHSwing >= GCD")
		and Player.Power >= Setting("Hamstring dump above # rage") 
		and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
		and Spell.Hamstring:Known()
		and Player.Power >= Spell.Hamstring:Cost()
		and GCD == 0 
			then
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() >= 1.5
			and Spell.Whirlwind:Known()
			and Spell.Whirlwind:CD() >= 1.5
				then
				if smartCast("Hamstring", Target)  
					then
					value = value - Spell.Hamstring:Cost()
				end
			elseif Spell.MortalStrike:Known()
			and Spell.MortalStrike:CD() >= 1.5
			and Spell.Whirlwind:Known()
			and Spell.Whirlwind:CD() >= 1.5
				then
				if smartCast("Hamstring", Target)  
					then
					value = value - Spell.Hamstring:Cost()
				end
			end 
		end
			
        return true
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
    if Setting("Execute")
	and	(HUD.Execute == 1 or HUD.Execute == 2 or HUD.Execute == 3 or HUD.Execute == 4)
		then
        for _, Unit in ipairs(Enemy5Y) do
            if Unit.HP <= 20 then
                exeCount = exeCount + 1
            end
        end
    end
    if Setting("Execute") 
	and HUD.Execute == 1 
		then
        if Spell.Execute:Known() 
		and exeCount >= 1
		and GCD == 0 
			then
            for _, Unit in ipairs(Enemy5Y) do
                if Unit.HP <= 20
				and Unit.Health >= 500 then
					if whatIsQueued ~= "NA"
					and Player.Power < Spell.Execute:Cost()
						then 
						cancelAAmod()
					end
					if Setting("Queue HS/ExecutePhase")
					and whatIsQueued == "NA"
					and Player.Power >= (Spell.Execute:Cost() + Spell.HeroicStrike:Cost())
					then
						RunMacroText("/cast Heroic Strike")
					end
					
					if smartCast("Execute", Unit, nil) 
						then return true 
					end
					
                end
            end
        end

    elseif Setting("Execute") 
	and HUD.Execute == 2

	and exeCount >= 1	
		then
        if Enemy5YC <= 3 then -- <= 3 then
            if Spell.Execute:Known() 
			and GCD == 0 
			then
                for _, Unit in ipairs(Enemy5Y) do
                    if Unit.HP <= 20 
					and Unit.Health >= 500 then
						if whatIsQueued ~= "NA"
						and Player.Power < Spell.Execute:Cost()
							then 
							cancelAAmod()
						end
						if Setting("Queue HS/ExecutePhase")
						and whatIsQueued == "NA"
						and Player.Power >= (Spell.Execute:Cost() + Spell.HeroicStrike:Cost())
						then
							RunMacroText("/cast Heroic Strike")
						end
						
						if smartCast("Execute", Unit, nil) 
							then return true 
						end
                    end
                end
            end
        end
    elseif Setting("Execute") 
	and HUD.Execute == 3 
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
			if Spell.Bloodthirst:Known()
			and Spell.Bloodthirst:CD() == 0
			and effectiveAP >= 2000
				then 
				if smartCast("Bloodthirst", Target)
					then return true 
				end		
				return true		
			else
				if whatIsQueued ~= "NA"
				and Player.Power < Spell.Execute:Cost()
					then 
					cancelAAmod()
				end
				if Setting("Queue HS/ExecutePhase")
				and whatIsQueued == "NA"
				and Player.Power >= (Spell.Execute:Cost() + Spell.HeroicStrike:Cost())
					then
					RunMacroText("/cast Heroic Strike")
				end
			end
			
			if smartCast("Execute", Unit, nil) 
				then return true 
			end		
		end
	elseif Setting("Execute") 
	and HUD.Execute == 4
        then
		if Enemy5YC <= 6 
		and Enemy5YC >= 2
		and exeCount >= 1
		then 
			if Spell.Execute:Known() 
			and GCD == 0 
			then
				for _, Unit in ipairs(Enemy5Y) do
					if Unit.HP < 20 
					and Unit.Health >= 500 then
						if whatIsQueued ~= "NA"
						and Player.Power < Spell.Execute:Cost()
							then 
							cancelAAmod()
						end
						if Setting("Queue HS/ExecutePhase")
						and whatIsQueued == "NA"
						and Player.Power >= (Spell.Execute:Cost() + Spell.HeroicStrike:Cost())
							then
							RunMacroText("/cast Heroic Strike")
						end
						
						if smartCast("Execute", Unit, nil) 
							then return true 
						end
					end
				end
			end
		
		
		elseif Target 
			and Target.HP <= 20
			and not Target.Dead 
			and Target.Distance <= 2 
			and Target.Attackable 
			and Target.Facing
			and Spell.Execute:Known()
			and GCD == 0 
				then
					if Spell.Bloodthirst:Known()
						and Spell.Bloodthirst:CD() == 0
						and effectiveAP >= 2000
							then 
							if smartCast("Bloodthirst", Target)
								then return true 
							end			
					else
						if whatIsQueued ~= "NA"
						and Player.Power < Spell.Execute:Cost()
							then 
							cancelAAmod()
						end
						if Setting("Queue HS/ExecutePhase")
						and whatIsQueued == "NA"
						and Player.Power >= (Spell.Execute:Cost() + Spell.HeroicStrike:Cost())
						then
							RunMacroText("/cast Heroic Strike")
						end
						
					if smartCast("Execute", Unit, nil) 
						then return true 
					end
					
					end
		end
	end
end

-- Auto Overpower
local function AutoOverpower()
	-- print("autoover")
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
				if Spell.Bloodthirst:Known()
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
	-- print("autobuff")
    if Setting("BattleShout")
	and Spell.BattleShout:Known()
	and not Player:AuraByName("Battle Shout", OnlyPlayer) 
		then 
			if Spell.BattleShout:Cast(Player) 
				then return true 
			end 
	end
end

local function ReadyCooldown()
			ReadyCooldownCountValue = 0
			
			if Setting("Trinkets")
			and Item.DiamondFlask:Equipped() 
			and Item.DiamondFlask:CD() <= 1.6
			then 
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			if Setting("DeathWish")
			and Spell.DeathWish:Known()
			and Spell.DeathWish:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			if Setting("Trinkets") 
			and Item.Earthstrike:Equipped()
			and Item.Earthstrike:CD() == 0	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end	
			
			if Setting("Trinkets") 
			and Item.JomGabbar:Equipped() 
			and Item.JomGabbar:CD() == 0	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Trinkets") 
			and Item.BadgeoftheSwarmguard:Equipped() 
			and Item.BadgeoftheSwarmguard:CD() == 0	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Racials")
			and Spell.BloodFury:Known() 
			and Spell.BloodFury:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Racials")
			and Spell.BerserkingTroll:Known()
			and Spell.BerserkingTroll:CD() == 0
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Setting("Recklessness")
			and Spell.Recklessness:Known()
			and Spell.Recklessness:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1	
			end
			
			if Setting("Use Best Rage Potion") and ((GetItemCount(13442) >= 1 and GetItemCooldown(13442) <= 1.6) or (GetItemCount(5633) >= 1 and GetItemCooldown(5633) <= 1.6))
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
local TTDDiamondFlask = Setting("TTD for DiamondFlask")
local TTDDeathWish = Setting("TTD for DeathWish")
local TTDEarthstrike = Setting("TTD for Earthstrike")
local TTDJomGabbar = Setting("TTD for JomGabbar")
local TTDBadgeoftheSwarmguard = Setting("TTD for BadgeoftheSwarmguard")
local TTDBloodFury = Setting("TTD for BloodFury")
local TTDBerserkingTroll = Setting("TTD for BerserkingTroll")
local TTDRecklessness = Setting("TTD for Recklessness")
local TTDRagePotion = Setting("TTD for RagePotion")
local SAKPDiamondFlask = Setting("Seconds after Keypress for DiamondFlask")
local SAKPDeathWish = Setting("Seconds after Keypress for DeathWish")
local SAKPEarthstrike = Setting("Seconds after Keypress for Earthstrike")
local SAKPJomGabbar = Setting("Seconds after Keypress for JomGabbar")
local SAKPBadgeoftheSwarmguard = Setting("Seconds after Keypress for BadgeoftheSwarmguard")
local SAKPBloodFury = Setting("Seconds after Keypress for BloodFury")
local SAKPBerserkingTroll = Setting("Seconds after Keypress for BerserkingTroll")
local SAKPRecklessness = Setting("Seconds after Keypress for Recklessness")
local SAKPRagePotion = Setting("Seconds after Keypress for RagePotion")

	-- if not Item.DiamondFlask:Equipped() --not equiped
		-- and GetItemCount(20130) >= 1	--but in inventory cause of CD or whatever
		-- then
			-- SAKPDeathWish = 0
			-- SAKPEarthstrike = 10
			-- SAKPJomGabbar = 10
			-- SAKPBadgeoftheSwarmguard = 2
			-- SAKPBloodFury = 5
			-- SAKPBerserkingTroll = 20
			-- SAKPRecklessness = 15
			-- SAKPRagePotion = 10
	-- end
	
	if Setting("CoolD Mode") == 2 
		then 
		
		if Setting("Trinkets") 
		and Item.DiamondFlask:Equipped() 
		and Item.DiamondFlask:CD() == 0
		and Target.TTD <= TTDDiamondFlask
		then 
			if Item.DiamondFlask:Use(Player) then return true end
			
		elseif Setting("DeathWish")
		and Spell.DeathWish:Known()
		and Player.Power >= 10
		and Spell.DeathWish:CD() == 0 
		and Player.Target.TTD <= TTDDeathWish
		then
			if smartCast("DeathWish", Player, true) then return true end
			
		elseif Setting("Trinkets") 
		and Item.Earthstrike:Equipped()
		and Item.Earthstrike:CD() == 0 	
		and Player.Target.TTD <= TTDEarthstrike
		then
			if Item.Earthstrike:Use(Player) then return true end
			
		elseif Setting("Trinkets")
		and Item.JomGabbar:Equipped() 
		and Item.JomGabbar:CD() == 0 	
		and Player.Target.TTD <= TTDJomGabbar
		then
			if Item.JomGabbar:Use(Player) then return true end
			
		elseif Setting("Trinkets")
		and Item.BadgeoftheSwarmguard:Equipped()
		and	Item.BadgeoftheSwarmguard:CD() == 0 
		and Player.Target.TTD <= TTDBadgeoftheSwarmguard
		then
			if Item.BadgeoftheSwarmguard:Use(Player) then return true end
			
		elseif Setting("Racials")
		and Spell.BloodFury:Known() 
		and Spell.BloodFury:CD() == 0 
		and Player.Target.TTD <= TTDBloodFury
		then
			if Spell.BloodFury:Cast(Player) then return true end
			
		elseif Setting("Racials")
		and Spell.BerserkingTroll:Known()
		and Spell.BerserkingTroll:CD() == 0 
		and Player.Target.TTD <= TTDBerserkingTroll 
		then
			if Spell.BerserkingTroll:Cast(Player) then return true end
		
		elseif Setting("Recklessness")
		and Spell.Recklessness:Known()
		and Spell.Recklessness:CD() == 0 
		and Player.Target.TTD <= TTDRecklessness
		then
			if smartCast("Recklessness", Player, true) then return true end
			
		elseif Setting("Use Best Rage Potion") and GetItemCount(13442) >= 1 and GetItemCooldown(13442) == 0 and Player.Target.TTD <= TTDRagePotion 
			then
			name = GetItemInfo(13442)
			RunMacroText("/use " .. name)
			return true
		elseif Setting("Use Best Rage Potion") and GetItemCount(5633) >= 1 and GetItemCooldown(5633) == 0 and Player.Target.TTD <= TTDRagePotion 
			then
			name = GetItemInfo(5633)
			RunMacroText("/use " .. name)
			return true 
			
		else return false
		
		end
		
	elseif Setting("CoolD Mode") == 3
			then
				
				if Setting("Trinkets")
				and Item.DiamondFlask:Equipped() 
				and Item.DiamondFlask:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPDiamondFlask) <= GetTime()
				then 
					if Item.DiamondFlask:Use(Player) then return true end
			
				elseif Setting("DeathWish") 
				and Spell.DeathWish:Known()
				and Spell.DeathWish:CD() == 0				
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPDeathWish) <= GetTime()
				then
					if smartCast("DeathWish", Player, true) then return true end
					
				elseif Setting("Trinkets") 
				and Item.Earthstrike:Equipped()
				and Item.Earthstrike:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPEarthstrike) <= GetTime()			
				then
					if Item.Earthstrike:Use(Player) then return true end
					
				elseif Setting("Trinkets")
				and Item.JomGabbar:Equipped() 
				and Item.JomGabbar:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPJomGabbar) <= GetTime()			
				then
					if Item.JomGabbar:Use(Player) then return true end
				
				elseif Setting("Trinkets")
				and Item.BadgeoftheSwarmguard:Equipped() 
				and Item.BadgeoftheSwarmguard:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPBadgeoftheSwarmguard) <= GetTime()			
				then
					if Item.JomGabbar:Use(Player) then return true end
					
				elseif Setting("Racials")
				and Spell.BloodFury:Known()
				and Spell.BloodFury:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPBloodFury) <= GetTime()			
				then
					if Spell.BloodFury:Cast(Player) then return true end
					
				elseif Setting("Racials")
				and Spell.BerserkingTroll:Known()
				and Spell.BerserkingTroll:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPBerserkingTroll) <= GetTime()			
				then
					if Spell.BerserkingTroll:Cast(Player) then return true end
				
				elseif Setting("Recklessness")
				and Spell.Recklessness:Known()
				and Spell.Recklessness:CD() == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPRecklessness) <= GetTime()				
				then
					if smartCast("Recklessness", Player, true) then return true end		
				
				elseif Setting("Use Best Rage Potion") and GetItemCount(13442) >= 1 and GetItemCooldown(13442) == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPRagePotion) <= GetTime()
					then
					name = GetItemInfo(13442)
					RunMacroText("/use " .. name)
					return true
				elseif Setting("Use Best Rage Potion") and GetItemCount(5633) >= 1 and GetItemCooldown(5633) == 0
				and UseCDsTime ~= 0
				and (UseCDsTime + SAKPRagePotion) <= GetTime()				
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
local slotId17, textureName1, checkRelic1 = GetInventorySlotInfo("SecondaryHandSlot")	--offhand
local ItemTypeOffhand

	if Setting("ItemType for Offhand") == 1
		then ItemTypeOffhand = "One-Handed Axes"
	elseif Setting("ItemType for Offhand") == 2
		then ItemTypeOffhand = "One-Handed Maces"
	elseif Setting("ItemType for Offhand") == 3
		then ItemTypeOffhand = "One-Handed Swords"
	elseif Setting("ItemType for Offhand") == 4
		then ItemTypeOffhand = "Daggers"
	end
	
	if (Setting("RotationType") == 1 or Setting("RotationType") == 10) then
		for bag = 0,4 do
			for slot = 1,GetContainerNumSlots(bag) do
				local item = GetContainerItemID(bag,slot)

				if item ~= nil
				and select(7, GetItemInfo(item)) == itemtype
				and select(3, GetItemInfo(item)) >= Setting("Min Q. gear equiped with Lifesaver") 
					then
					UseContainerItem(bag,slot)
					return true
				end
			end
		end
	elseif Setting("RotationType") == 2 then
		if itemtype == "Shields" then
			for bag = 0,4 do
				for slot = 1,GetContainerNumSlots(bag) do
					local item = GetContainerItemID(bag,slot)

					if item ~= nil
					and select(7, GetItemInfo(item)) == itemtype
						then
						UseContainerItem(bag,slot)
						return true
					end
				end
			end
		elseif itemtype == "Offhand" then
			for bag = 0,4 do
				for slot = 1,GetContainerNumSlots(bag) do
					local item = GetContainerItemID(bag,slot)

					if item ~= nil
					and select(7, GetItemInfo(item)) == ItemTypeOffhand
					and select(3, GetItemInfo(item)) >= Setting("Min Q. gear for Kick Gear") 
						then
						EquipItemByName(item, slotId17)
						return true
					end
				end
			end	
		end	
	end
end

local function IsEquipped(itemID, slot)
    local ID = GetInventoryItemID("player", slot)
    if ID == itemID
		then
		return true

	else return false
    end
end


local function weaponswap(def,off)
local MainhandName = select(1, GetItemInfo(Setting("ItemID Mainhand")))
local DefMainhandName = select(1, GetItemInfo(Setting("ItemID DefMainhand")))
local OffhandName = select(1, GetItemInfo(Setting("ItemID Offhand")))
local ShieldName = select(1, GetItemInfo(Setting("ItemID Shield")))
local TwohanderName = select(1, GetItemInfo(Setting("ItemID 2 Hander")))
local ItemIdMH =  tonumber(Setting("ItemID Mainhand"))
local ItemIdDefMh = tonumber(Setting("ItemID DefMainhand"))
local ItemIdOH = tonumber(Setting("ItemID Offhand"))
local ItemIdS = tonumber(Setting("ItemID Shield"))
local ItemIdTH = tonumber(Setting("ItemID 2 Hander"))


	if (Setting("Equip 1h and shield when aggro") or Setting("Swap to shield for kick"))
	and def
	and ItemIdDefMh ~= nil
	and ItemIdS ~= nil
	and (not IsEquipped(ItemIdDefMh, 16) or not IsEquipped(ItemIdS, 17)) --16Mainhand 17Offhand
		then 
		for bag = 0,4 do
			for slot = 1,GetContainerNumSlots(bag) do
				local item = GetContainerItemID(bag,slot)
				if item ~= nil
				and item == ItemIdDefMh
					then
					RunMacroText("/equipslot 16 " .. DefMainhandName)

				end
				if item ~= nil
				and item == ItemIdS
					then 
					RunMacroText("/equipslot 17 " .. ShieldName)

				end
				if IsEquipped(ItemIdDefMh, 16) and IsEquipped(ItemIdS, 17)
				then return true end
			end
		end
		
	elseif Setting("Equip 2 x 1h after aggroloose")
	and off
	and ItemIdMH ~= nil
	and ItemIdOH ~= nil
	and (not IsEquipped(ItemIdMH, 16) or not IsEquipped(ItemIdOH, 17)) --16Mainhand 17Offhand
		then 
		for bag = 0,4 do
			for slot = 1,GetContainerNumSlots(bag) do
				local item = GetContainerItemID(bag,slot)

				if item ~= nil
				and item == ItemIdMH
					then 
					RunMacroText("/equipslot 16 " .. MainhandName)
					
				end
				if item ~= nil
				and item == ItemIdOH
					then 
					RunMacroText("/equipslot 17 " .. OffhandName)
					
				end
				if IsEquipped(ItemIdMH, 16) and IsEquipped(ItemIdOH, 17)
				then return true end
			end
		end
	elseif Setting("Equip 2H after aggroloose")
	and off
	and ItemIdTH ~= nil
	and not IsEquipped(ItemIdTH, 16) --16Mainhand 17Offhand
		then 
		for bag = 0,4 do
			for slot = 1,GetContainerNumSlots(bag) do
				local item = GetContainerItemID(bag,slot)

				if item ~= nil
				and item == ItemIdTH
					then 
					RunMacroText("/equipslot 16 " .. TwohanderName)
					
				end
				if IsEquipped(ItemIdTH, 16)
				then return true end
			end
		end
	-- elseif Setting("Swap to shield for kick")
	-- and off
	-- and ItemIdOH ~= nil
	-- and not IsEquipped(ItemIdOH, 17) --16Mainhand 17Offhand
		-- then 
		-- for bag = 0,4 do
			-- for slot = 1,GetContainerNumSlots(bag) do
				-- local item = GetContainerItemID(bag,slot)

				-- if item ~= nil
				-- and item == ItemIdOH
					-- then 
					-- RunMacroText("/equipslot 17 " .. OffhandName)
					
				-- end
				-- if IsEquipped(ItemIdOH, 17)
				-- then return true end
			-- end
		-- end
		
	elseif (((Setting("Equip 1h and shield when aggro") or Setting("Swap to shield for kick")) and IsEquipped(ItemIdDefMh, 16) and IsEquipped(ItemIdS, 17))
	or (Setting("Equip 2 x 1h after aggroloose") and IsEquipped(ItemIdMH, 16) and IsEquipped(ItemIdOH, 17))
	or (Setting("Equip 2H after aggroloose") and IsEquipped(ItemIdTH, 16))) --or (Setting("Swap to shield for kick") and not def and IsEquipped(ItemIdOH, 17)) or (Setting("Swap to shield for kick") and def and IsEquipped(ItemIdS, 17))
		then return true

	end	
end


local function lifesaver()
	if Target
	and Player:IsTanking()
	and not UnitPlayerControlled("target")
	and (not Setting("Lifesaver only in Raid") or (Setting("Lifesaver only in Raid") and UnitInRaid("player") ~= nil))
	and Setting("RotationType") == 1
		then
		if Setting("Lifes. allways")
			then
			if Setting("Equip 1h and shield when aggro")
			then
				if weaponswap(true,false)
					then DMW.Settings.profile.Rotation.RotationType = 2 return true
				end
			else DMW.Settings.profile.Rotation.RotationType = 2 return true
			end
		elseif Setting("Lifes. Enemy Max HP")
		and Target.HealthMax >= Setting("MaxHP in tousands")
			then 
			if Setting("Equip 1h and shield when aggro")
			then
				if weaponswap(true,false)
					then DMW.Settings.profile.Rotation.RotationType = 2 return true
				end
			else DMW.Settings.profile.Rotation.RotationType = 2 return true
			end
		elseif Setting("Lifes. Enemy Level")
		and Target.Level >= Setting("EnemyLvl")
			then 
			if Setting("Equip 1h and shield when aggro")
			then
				if weaponswap(true,false)
					then DMW.Settings.profile.Rotation.RotationType = 2 return true
				end
			else DMW.Settings.profile.Rotation.RotationType = 2 return true
			end			
		-- elseif Setting("Lifes. Bossaggro")
		-- and Target.IsBoss()
			-- then 
			-- if Setting("Equip 1h and shield when aggro")
			-- then
				-- if weaponswap(true,false)
					-- then DMW.Settings.profile.Rotation.RotationType = 2 return true
				-- end
			-- else DMW.Settings.profile.Rotation.RotationType = 2 return true
			-- end			
		end
		
	elseif Setting("RotationType") == 2
	and (not Player:IsTanking() or not Player.Combat)
		then
		if Setting("Equip 2 x 1h after aggroloose")
			then
				if weaponswap(false,true)
					then DMW.Settings.profile.Rotation.RotationType = 1 return true
				end
		elseif Setting("Equip 2H after aggroloose")
			then
				if weaponswap(false,true)
					then DMW.Settings.profile.Rotation.RotationType = 1 return true
				end
		else DMW.Settings.profile.Rotation.RotationType = 1 return true
		end
		

	end 
end


local function AutoTargetAndFacing()

-- Auto targets Enemy in Range
    if Setting("AutoTarget") 
	and (not Target or not Target.ValidEnemy or Target.Dead or not ObjectIsFacing("Player", Target.Pointer, 160) or IsSpellInRange("Hamstring", "target") == 0)
		then 
		for _, Unit in ipairs(Enemy5Y) do	
			if GetRaidTargetIndex(Unit.Pointer) == 8 
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true
			elseif GetRaidTargetIndex(Unit.Pointer) == 7
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true
			elseif GetRaidTargetIndex(Unit.Pointer) == 6
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true			
			elseif GetRaidTargetIndex(Unit.Pointer) == 5
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif GetRaidTargetIndex(Unit.Pointer) == 4
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif GetRaidTargetIndex(Unit.Pointer) == 3
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true					
			elseif GetRaidTargetIndex(Unit.Pointer) == 2
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true					
			elseif GetRaidTargetIndex(Unit.Pointer) == 1
			and IsSpellInRange("Hamstring", Unit.Pointer) == 1
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif Player:AutoTarget(5, true) 
				then return true 
			
			end
		end
	end

	
-- Auto Face the Target
    if Setting("AutoFace")
    and Player.Combat 
	and Target 
	and Target.ValidEnemy
	and IsSpellInRange("Hamstring", "target") == 1
	and not ObjectIsFacing("Player", Target.Pointer, 160) then
        FaceDirection(Target.Pointer, true)
		return true 
    end
end



local function SomeDebuffs()

-- Thunderclap when Units in Range without debuff
    if Setting("ThunderClap") and Setting("ThunderClap") > 0 
	and Setting("ThunderClap") <= Enemy5YC
	and Player.Power >= Spell.ThunderClap:Cost()
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
	and Player.Power >= Spell.PiercingHowl:Cost()
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
	and Player.Power >= Spell.DemoShout:Cost()
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

local function Consumes()

-- Sapper Charge
	if Setting("Use Sapper Charge")
	and Player.Combat
	and (DMW.Time - ItemUsage) > 1.5 
	and Enemy10YC ~= nil
	and Enemy10YC >= Setting("Enemys 10Y")
	and GetItemCount(Item.GoblinSapperCharge.ItemID) >= 1
	and Item.GoblinSapperCharge:CD() == 0 
		then 
		if Item.GoblinSapperCharge:Use(Player)
			then 
			ItemUsage = DMW.Time
			return true
		end
	end

-- Granates and dynamite
	if Setting("Use Trowables") >= 1
	and Target
	and Player.Combat
	and (DMW.Time - ItemUsage) > 1.5 
	and Target5YC ~= nil
	and Target5YC >= Setting("Enemys 5Y around Target")
	and Target.Facing
	then
		if Setting("Use Trowables") == 2
		then
			if GetItemCount(Item.DenseDynamite.ItemID) >= 1
			and Item.DenseDynamite:CD() == 0 
			then 
				if Item.DenseDynamite:UseGround(Target)
					then
					ItemUsage = DMW.Time
					return true
				end
			elseif GetItemCount(Item.ThoriumGrenade.ItemID) >= 1
			and Item.ThoriumGrenade:CD() == 0 
			then 
				if Item.ThoriumGrenade:UseGround(Target)
					then
					ItemUsage = DMW.Time
					return true
				end
			elseif GetItemCount(Item.EZThroDynamitII.ItemID) >= 1
			and Item.EZThroDynamitII:CD() == 0 
			then 
				if Item.EZThroDynamitII:UseGround(Target)
					then
					ItemUsage = DMW.Time
					return true
				end			
			elseif GetItemCount(Item.IronGrenade.ItemID) >= 1
			and Item.IronGrenade:CD() == 0 
			then 
				if Item.IronGrenade:UseGround(Target)
					then
					ItemUsage = DMW.Time
					return true
				end		
			end
			
		elseif Setting("Use Trowables") == 3
			and GetItemCount(Item.DenseDynamite.ItemID) >= 1
			and Item.DenseDynamite:CD() == 0 
			then 
				if Item.DenseDynamite:UseGround(Target)
					then 
					ItemUsage = DMW.Time
					return true
				end
		elseif Setting("Use Trowables") == 4
			and GetItemCount(Item.EZThroDynamitII.ItemID) >= 1
			and Item.EZThroDynamitII:CD() == 0 
			then 
				if Item.EZThroDynamitII:UseGround(Target)
					then 
					ItemUsage = DMW.Time
					return true
				end	
		elseif Setting("Use Trowables") == 5
			and GetItemCount(Item.ThoriumGrenade.ItemID) >= 1
			and Item.ThoriumGrenade:CD() == 0 
			then 
				if Item.ThoriumGrenade:UseGround(Target)
					then 
					ItemUsage = DMW.Time
					return true
				end		
		elseif Setting("Use Trowables") == 6
			and GetItemCount(Item.IronGrenade.ItemID) >= 1
			and Item.IronGrenade:CD() == 0 
			then 
				if Item.IronGrenade:UseGround(Target)
					then 
					ItemUsage = DMW.Time
					return true
				end			
		
		end
	end

--Use "Healthstone" 
	if Setting("Healthstone")
	and Player.Combat
	and (DMW.Time - ItemUsage) > 1.5 
    and Player.HP < Setting("Use Healthstone at #% HP") 
    and (Item.MajorHealthstone:Use(Player) 
    or Item.GreaterHealthstone:Use(Player) 
    or Item.Healthstone:Use(Player) 
    or Item.LesserHealthstone:Use(Player) 
    or Item.MinorHealthstone:Use(Player)) 
	then
        ItemUsage = DMW.Time 
		return true
    end

	-- Use Best HP Pot
	if Setting("Use Best HP Potion") then
		if DMW.Player.HP <= Setting("Use Potion at #% HP") and Player.Combat and (DMW.Time - ItemUsage) > 1.5 then
			if GetItemCount(13446) >= 1 and GetItemCooldown(13446) == 0 then
				name = GetItemInfo(13446)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true 
			elseif GetItemCount(3928) >= 1 and GetItemCooldown(3928) == 0 then
				name = GetItemInfo(3928)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(1710) >= 1 and GetItemCooldown(1710) == 0 then
				name = GetItemInfo(1710)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(929) >= 1 and GetItemCooldown(929) == 0 then
				name = GetItemInfo(929)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(858) >= 1 and GetItemCooldown(858) == 0 then
				name = GetItemInfo(858)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(118) >= 1 and GetItemCooldown(118) == 0 then
				name = GetItemInfo(118)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			end
		end
	end
end



function Warrior.Rotation()
    Locals()


	--Debug and Log Info	
	if Setting("Debug")
	and not DMW.UI.Debug.Frame:IsShown() 
		then
        DMW.UI.Debug.Frame:Show()
    elseif not Setting("Debug")
	and DMW.UI.Debug.Frame:IsShown()
		then
		DMW.UI.Debug.Frame:Hide()	            
	end
	
	if Setting("Log")
	and not DMW.UI.Log.Frame:IsShown() 
		then
        DMW.UI.Log.Frame:Show()
    elseif not Setting("Log")
	and DMW.UI.Log.Frame:IsShown()
		then
		DMW.UI.Log.Frame:Hide()	            
	end	
	
	if Consumes() then
		return true
	end

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


	if AutoTargetAndFacing()
		then return true 
	end
	
	
	if SomeDebuffs()
		then return true 
	end

    -----------------FURY DW/2H PART--------------------FURY DW/2H PART--------------------FURY DW/2H PART--------------------FURY DW/2H PART------
    ---FURY DW/2H PART--------------------FURY DW/2H PART--------------------FURY DW/2H PART--------------------FURY DW/2H PART--------------------
    -----------------FURY DW/2H PART--------------------FURY DW/2H PART--------------------FURY DW/2H PART--------------------FURY DW/2H PART------

	
    if Setting("RotationType") == 1 --or (Target and Target.Player) 
		then
		Locals()
	
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
		and Enemy5YC ~= nil
		and Enemy5YC > 0 
			then

			-----life saver if aggro---------
			if Setting("Lifesaver") 
				then 
				if lifesaver()
					then return true
				end
			end
	
			-- Bers Rage --
			if Setting("Berserker Rage") 
			and Spell.BersRage:CD() == 0 
			and Spell.BersRage:Known() 
				then	
				if smartCast("BersRage", Player)
					then return true 
				end 
			end
			
			-- Bloodrage --
			if Setting("Bloodrage")
			and Spell.Bloodrage:Known()
			and Spell.Bloodrage:CD() == 0
			and Player.Power <= 50 
			and Player.HP >= 30
				then
				if smartCast("Bloodrage", Target)  
					then return true 
				end
			end
		
	
			--Changed to Auto or Keypress
			if Setting("CoolD Mode") == 2
			and Target 
			and Target:IsBoss()
			and ReadyCooldown()
			and Target.TTD >= 10 and  Target.TTD <= 80
				then 
				if CoolDowns() 
					then return true 
				end 
			
			elseif Setting("CoolD Mode") == 3
			and CDs
			and Target 
			and ReadyCooldown()
				then 
				if CoolDowns() 
					then 
				end
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
			and Player.Power >= Spell.Pummel:Cost()
				then
				for _, Unit in ipairs(Enemy5Y) do
				local castName = Unit:CastingInfo()
					if castName ~= nil 
					and (Unit:Interrupt() or interruptList[castName]) 
						then
						if smartCast("Pummel", Unit, true) 
							then return true 
						end
				end
					end
			end

			
			-- Buffs Battleshout Casts Overpower or EXECUTE
            if (AutoExecute() or AutoBuff() or AutoOverpower()) 
				then return true 
			end

			if Target
			then			
					if Enemy8YC ~= nil
					and Enemy8YC >= 2 
						then
						
						if Setting("Whirlwind")
						and Spell.Whirlwind:Known()	
						and Spell.Whirlwind:CD() == 0 
						and Player.Power >= Spell.Whirlwind:Cost()
							then 
							if smartCast("Whirlwind", Player, true) 
								then return true 
							end 
						end
						
						if Setting("Bloodthirst") 
						and Spell.Bloodthirst:Known() 
						and Spell.Bloodthirst:CD() == 0
						and (not Setting("Calculate Rage") or (Player.Power - Spell.Bloodthirst:Cost() + ragegain(Spell.Whirlwind:CD())) >= Spell.Whirlwind:Cost())
						and  Player.Power >= Spell.Bloodthirst:Cost()
							then 				
							if smartCast("Bloodthirst", Target, true) 
								then return true 
							end
						elseif Setting("MortalStrike") 
						and Spell.MortalStrike:Known() 
						and Spell.MortalStrike:CD() == 0 
						and (not Setting("Calculate Rage") or (Player.Power - Spell.MortalStrike:Cost() + ragegain(Spell.Whirlwind:CD())) >= Spell.Whirlwind:Cost())
						and  Player.Power >= Spell.MortalStrike:Cost()
							then
							if smartCast("MortalStrike", Target, true) 
								then return true 
							end
						end
					
					else				
						--first Global Sunder
						
						if Setting("First Global Sunder")
						-- and not Debuff.ExposeArmor:Exist(Target)
						and Spell.SunderArmor:Known() 
						and Spell.SunderArmor:CD() == 0
						and Player.Power >= Spell.SunderArmor:Cost()
						and SunderStacks <= 5
						and Target.HealthMax >= Setting("GCDSunder MaxHP")
						and TargetSundered ~= Target.GUID
						then 
							if smartCast("SunderArmor", Target)
								then 
								TargetSundered = Target.GUID
								return true 
							end
						end
						
						if Setting("SunderArmor") 
						and not Setting("First Global Sunder")
						-- and not Debuff.ExposeArmor:Exist(Target)						
						and Spell.SunderArmor:Known() 
						and Spell.SunderArmor:CD() == 0 
						and Player.Power >= Spell.SunderArmor:Cost() 
						and SunderStacks <= Setting("Apply Stacks of Sunder Armor")
						then 
							if smartCast("SunderArmor", Target)
								then return true 
							end
						end

						if Setting("Use Slam") 
						and Setting("Use Slam over BT") 
						and effectiveAP <= 1500
						and Player.Power >= Spell.Slam:Cost() 
						and Spell.Slam:Known() 
						and Spell.Slam:CD() == 0	
						and CanSlam()
							then
							if smartCast("Slam", Target)
								then return true
							end
						end
						
						if Setting("Bloodthirst") 
						and Spell.Bloodthirst:Known() 
						and Spell.Bloodthirst:CD() == 0 
						and Player.Power >= Spell.Bloodthirst:Cost()
							then 
							if smartCast("Bloodthirst", Target) 
								then return true 
							end  					
						elseif Setting("MortalStrike") 
						and Spell.MortalStrike:Known() 
						and Spell.MortalStrike:CD() == 0 
						and Player.Power >= Spell.MortalStrike:Cost() 
							then
							if smartCast("MortalStrike", Target) 
								then return true 
							end 
						end
						
						if Setting("Whirlwind") 
						and Spell.Whirlwind:Known() 
						and Spell.Whirlwind:CD() == 0 
						and Player.Power >= Spell.Whirlwind:Cost() 
							then
							if Setting("Bloodthirst") 
							and Spell.Bloodthirst:Known() 
							and (not Setting("Calculate Rage") or (Player.Power - Spell.Whirlwind:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
								then
									if smartCast("Whirlwind", Unit, nil) 
										then return true 
									end
							elseif Setting("MortalStrike")  
							and Spell.MortalStrike:Known()
							and (not Setting("Calculate Rage") or (Player.Power - Spell.Whirlwind:Cost() + ragegain(Spell.MortalStrike:CD())) >= Spell.MortalStrike:Cost())
								then                 
								if smartCast("Whirlwind", Unit, nil) 
									then return true 
								end
							end		
						end

					end
					
					if Setting("Use Slam") 
					and Player.Power >= Setting("Use Slam above # rage") 
					and Spell.Slam:Known() 
					and Player.Power >= Spell.Slam:Cost()
					and Spell.Slam:CD() == 0	
					and CanSlam()
					then
						if smartCast("Slam", Target) 
							then return true
						end
					end
				
						-- Hamstring --
								
					if (Setting("Hamstring < 30% Enemy HP") or Setting("Hamstring PvP"))
					and Spell.Hamstring:Known() 
					and GCD == 0 
					and Player.Combat 
					and Target 
					and (Target.HP <= 35 or Setting("Hamstring PvP")) 
					and Target.Distance <= 5 
					and not Debuff.Hamstring:Exist(Target) 
					and Player.Power >= Spell.Hamstring:Cost() 
					and smartCast("Hamstring", Target) 
						then return true
					end
				
					--AbuseHS()
					--Rage dump with HS or Cleave if there is still rage with harmstring if activated
					--if dumpRage(Player.Power - Setting("Rage Dump"))
							
					if Setting("Rage Dump?") 
					and Player.Power >= Setting("Rage Dump") 
						then
						if dumpRage(Player.Power - Setting("Rage Dump"))
							then return true 
						end
					end
					
			end		
        end
		

    -----------------FURY Prot PART--------------------FURY Prot PART--------------------FURY Prot PART--------------------FURY Prot PART------
    ---FURY Prot PART--------------------FURY Prot PART--------------------FURY Prot PART--------------------FURY Prot PART--------------------
    -----------------FURY Prot PART--------------------FURY Prot PART--------------------FURY Prot PART--------------------FURY Prot PART------	
	
	elseif Setting("RotationType") == 2 --or (Target and Target.Player) 
		then
		Locals()
		-- swap back to main weapons and rotation
		if Setting("Lifesaver") 
			then 
			if lifesaver()
				then return true
			end
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
		
		-- Swap back to 1h offhand
		-- if Setting("Swap to shield for kick")
		-- and IsEquippedItemType("Shields")
		-- then
			-- for _, Unit in ipairs(Enemy5Y) do
			-- local castName = Unit:CastingInfo()
				-- if castName == nil
				-- and not (Unit:Interrupt() or interruptList[castName])
					-- then 
					-- if weaponswap(false,true) 
						-- then return true
					-- end
				-- end
			-- end
		-- end

        if Player.Combat
		and Enemy5YC ~= nil
		and Enemy5YC > 0 
			then
		

			
			-- Bloodrage --
			if Setting("Bloodrage")
			and Spell.Bloodrage:Known()
			and Spell.Bloodrage:CD() == 0
			and Player.Power <= 50 
			and Player.HP >= 30
				then
					if smartCast("Bloodrage", Target)
					then 
					return true end
			end
			
			
		
			--Changed to Auto or Keypress
			if Setting("CoolD Mode") == 2
			and Target 
			and Target:IsBoss()
			and CDs
			and ReadyCooldown()
			and Target.TTD >= 10 and  Target.TTD <= 80
				then 
				if CoolDowns() 
					then return true 
				end 
			
			elseif Setting("CoolD Mode") == 3
			and CDs
			and Target 
			and ReadyCooldown()
				then 
				if CoolDowns() 
					then 
				end
			end

			--unqueue HS or Cleave when low rage
			if Player.Power < 20
			and (whatIsQueued == "HS" or whatIsQueued == "CLEAVE")
			and Player.SwingMH <= 0.3
			and Player.SwingMH > 0
				then				
				cancelAAmod()
			end
			
			-- AutoKICK with ShildBash if something in 5Yards casts something
			if Setting("Pummel/ShildBash")
			and Target 
			and IsEquippedItemType("Shields")
			and Spell.ShieldBash:Known()
			and Spell.ShieldBash:CD() == 0
			and Player.Power >= Spell.ShieldBash:Cost()
				then
				local castName = Target:CastingInfo()
				if castName ~= nil 
				and (Target:Interrupt() or interruptList[castName]) 
					then
					if smartCast("ShieldBash", Target, true) 
						then return true 
					end
				end
			-- elseif Setting("Swap to shield for kick")
			-- and Setting("Pummel/ShildBash")
			-- and Target 
			-- and not IsEquippedItemType("Shields")
			-- and Spell.ShieldBash:Known()
			-- and Spell.ShieldBash:CD() == 0
			-- and Player.Power >= Spell.ShieldBash:Cost()
				-- then
				-- for _, Unit in ipairs(Enemy5Y) do
				-- local castName = Unit:CastingInfo()
					-- if castName ~= nil 
					-- and (Unit:Interrupt() or interruptList[castName]) 
						-- then
						-- if weaponswap(true,false) 
							-- then 
							-- if smartCast("ShieldBash", Target, true) 
								-- then return true
							-- end
						-- end
					-- end	
				-- end
			end

			
			-- Buffs Battleshout Casts Overpower or EXECUTE
            if (AutoExecute() or AutoRevenge())
				then return true 
			end

			if Target
			then			
		
				if Setting("Bloodthirst") 
				and Spell.Bloodthirst:Known() 
				and Spell.Bloodthirst:CD() == 0 
				and Player.Power >= Spell.Bloodthirst:Cost()
				then 
					if smartCast("Bloodthirst", Target) 
						then return true 
					end						
				elseif Setting("MortalStrike") 
				and Spell.MortalStrike:Known() 
				and Spell.MortalStrike:CD() == 0 
				and Player.Power >= Spell.MortalStrike:Cost() 
					then
					if smartCast("MortalStrike", Target) 
						then return true 
					end 
				end				
	
				if Setting("SunderArmor")
				-- and not Debuff.ExposeArmor:Exist(Target)				
				and Spell.SunderArmor:Known() 
				and Spell.SunderArmor:CD() == 0 
				and Player.Power >= Spell.SunderArmor:Cost()
				then 
					if Spell.Bloodthirst:Known()
					and Spell.Bloodthirst:CD() >= 1.5
					and (not Setting("Calculate Rage") or (Player.Power - Spell.SunderArmor:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
						then
						if smartCast("SunderArmor", Target)
							then return true 
						end
					elseif Spell.MortalStrike:Known()
					and Spell.MortalStrike:CD() >= 1.5
					and (not Setting("Calculate Rage") or (Player.Power - Spell.SunderArmor:Cost() + ragegain(Spell.MortalStrike:CD())) >= Spell.MortalStrike:Cost())
						then
						if smartCast("SunderArmor", Target)
							then return true 
						end
					end 
				elseif Setting("SunderArmor")
				-- and Debuff.ExposeArmor:Exist(Target)				
				and Spell.BattleShout:Known() 
				and Spell.BattleShout:CD() == 0
				and Player.Power >= Spell.BattleShou:Cost()
				then 
					if Spell.Bloodthirst:Known()
					and Spell.Bloodthirst:CD() >= 1.5
					and (not Setting("Calculate Rage") or (Player.Power - Spell.BattleShout:Cost() + ragegain(Spell.Bloodthirst:CD())) >= Spell.Bloodthirst:Cost())
						then
						if Spell.BattleShout:Cast(Player) 
							then return true 
						end
					elseif Spell.MortalStrike:Known()
					and Spell.MortalStrike:CD() >= 1.5
					and (not Setting("Calculate Rage") or (Player.Power - Spell.BattleShout:Cost() + ragegain(Spell.MortalStrike:CD())) >= Spell.MortalStrike:Cost())
						then
						if Spell.BattleShout:Cast(Player)  
							then return true 
						end
					end 	
				end
				
				if AutoBuff()
					then return true 
				end				

				-- Hamstring --
				if (Setting("Hamstring < 30% Enemy HP") or Setting("Hamstring PvP"))
				and Spell.Hamstring:Known() 
				and GCD == 0 
				and Player.Combat 
				and Target 
				and (Target.HP <= 35 or Setting("Hamstring PvP")) 
				and Target.Distance <= 5  
				and not Debuff.Hamstring:Exist(Target) 
				and Player.Power >= Spell.Hamstring:Cost() 
				and smartCast("Hamstring", Target) 
					then return true
				end		
				
				if Setting("Use ShieldBlock")
				and IsEquippedItemType("Shields")
				and Player.Power >= Spell.ShieldBlock:Cost()
				then
					for k, v in pairs(Enemy10Y) do
						if UnitIsUnit(UnitTarget(v.Pointer), "player")
						and Spell.ShieldBlock:Known()
						and Spell.ShieldBlock:CD() == 0
						and Player.HP <= Setting("Shieldblock HP") 
						and UnitIsUnit(v.Target, "player") 
						and (v.SwingMH > 0 or v.SwingMH <= 0.5) 
							then
							smartCast("ShieldBlock", Player)
							break
						end
					end
				end
				
				if Setting("ShieldWall")
				and Player.HP <= Setting("Shieldwall HP")
				and Spell.ShieldWall:Known()
				and Spell.ShieldWall:CD() == 0
				and IsEquippedItemType("Shields")
				and smartCast("ShieldWall", Player, true)
					then return true 
				end

				
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



eventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED" ) and DMW.UI.MinimapIcon
	and select(4, CombatLogGetCurrentEventInfo()) == UnitGUID("player")
	and select(2, CombatLogGetCurrentEventInfo()) == "SPELL_DAMAGE"
	and select(13, CombatLogGetCurrentEventInfo()) == "Bloodthirst"
		then
		GetArmorOfTarget(CombatLogGetCurrentEventInfo())		
	elseif(event == "UNIT_AURA") and DMW.UI.MinimapIcon then
		GetSunderStacks()
		Buffsniper()		
	end
end)
