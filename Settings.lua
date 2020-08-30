local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()

    if DMW.Player.Talents.SweepingStrikes.Rank > 0 then
        UI.HUD.Options = {
            [1] = {
                Sweeping = {
                    [1] = {Text = "Sweeping Strikes |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "Sweeping Strikes |cFFFFFF00Off", Tooltip = ""}
                }
            }
        }

    else
        UI.HUD.Options = {
            [1] = {
                blank = {
                    [1] = {Text = "", Tooltip = ""},
                    [2] = {Text = "", Tooltip = ""}
                }
            }
        }
    end
    UI.HUD.Options[2] = {
        Charge = {
            [1] = {Text = "Charge |cFF00FF00And_InterCept", Tooltip = ""},
            [2] = {Text = "Only |cFFFFFF00InterCept", Tooltip = ""},
            [3] = {Text = "|cFFFFFF00No_Moving", Tooltip = ""}
        }
    }
	UI.HUD.Options[3] = {
                Dump_HS_OnOff = {
                    [1] = {Text = "Dump_HS_OnOff |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "Dump_HS_OnOff |cFFFFFF00Off", Tooltip = ""}
		}      
	}

    UI.HUD.Options[4] = {
        Execute = {
            [1] = {Text = "Execute 360++", Tooltip = ""},
            [2] = {Text = "Execute If <= 3 units", Tooltip = ""},
            [3] = {Text = "Execute |cffffffffTarget", Tooltip = ""},
            [4] = {Text = "Execute |cffffffffMix", Tooltip = ""},
            [5] = {Text = "Execute |cFFFFFF00Disabled", Tooltip = ""}
	    }
    }	

    -- UI.AddHeader("This Is A Header")
    -- UI.AddDropdown("This Is A Dropdown", nil, {"Yay", "Nay"}, 1)
    -- UI.AddToggle("This Is A Toggle", "This is a tooltip", true)
    -- UI.AddRange("This Is A Range", "One more tooltip", 0, 100, 1, 70)
	
    UI.AddHeader("Usual Options")
	    -- UI.AddToggle("Debug", nil, false)
		UI.AddDropdown("RotationType", nil, {"2HFury/Fury","FurryProt"}, 1)
		UI.AddBlank()
		UI.AddToggle("BattleStance NoCombat", "Switches to Battle Stance if we are not InCombat" , false)
        UI.AddToggle("Charge&Intercept", nil, false)
		
	 -- UI.AddHeader("What Stance to Check first")	
        -- UI.AddDropdown("First check Stance", "", {"Battle","Defensive","Berserker"}, "Battle")
        -- UI.AddDropdown("Second check Stance", "", {"Battle","Defensive","Berserker"}, "Berserker")
        -- UI.AddDropdown("Third check Stance", "", {"Battle","Defensive","Berserker"}, "Defensive")

		
    UI.AddHeader("Auto Stuff")
        UI.AddToggle("AutoFace", "Makes you Face the Target all the Time", false)
        UI.AddToggle("AutoTarget", "Targets the next Target automaticly", false)
        UI.AddToggle("BattleShout", nil, true)
        UI.AddToggle("Pummel/ShildBash", "Has to be checked for FurryProt swap option", false)
        -- UI.AddToggle("Auto Disable SS", nil, false)
		-- UI.AddToggle("AutoTreatTarget", nil, false) only in tank rota not supported atm
		
		
    UI.AddHeader("DPS Shit/Spells")
        -- UI.AddToggle("Rend", nil, false)	not programmed
		-- UI.AddToggle("SweepingStrikes", nil, false) not programmed
        UI.AddToggle("Bloodthirst", nil, true)
        UI.AddToggle("Whirlwind","Not used in FurryProt", true)
        UI.AddToggle("Overpower","Not used in FurryProt", true)
		UI.AddToggle("MortalStrike", nil, false)
		UI.AddToggle("Hamstring < 35% Enemy HP", nil, true)
		UI.AddToggle("Hamstring PvP", nil, true)

	UI.AddHeader("Rage Settings")
		UI.AddToggle("Bloodrage", "Use Bloodrage when available", false)
		UI.AddToggle("Berserker Rage", "Use Berserker Rage", false)
        UI.AddToggle("Rage Dump?", "Shall we Dump the Rage that is too much", false)
        UI.AddRange("Rage Dump", "On witch Value do we have too much Rage", 30, 100, 1, 30)
        UI.AddToggle("Hamstring Dump", "Dumps Rage also with Hamstring, good with Windfurry, not used in FurryProt", false)
		UI.AddRange("Hamstring dump above # rage", "At what amount of rage Hamstring will also be used as dump", 0, 100, 1, 40)
		UI.AddToggle("Only HString MHSwing >= GCD", "Uses Hamstring only when MH hits in a GCD", false)
		UI.AddRange("RageLose on StanceChange", "What Amount of Rage can we waste for a StanceChange", 0, 100, 1, 30)
		UI.AddToggle("Queue HS/ExecutePhase", "Will queue HS in Execute Phase when there is more rage than Excost", false)
		
		
        -- UI.AddToggle("Slam Dump", nil, false)

------------------------------------------------------------------------------------------------------------------------------
    UI.AddTab("CDs & Consumables")
		UI.AddHeader("Cooldowns")	
		UI.AddToggle("Recklessness", "Use Recklessness in Auto/Keypress Mode", false)
		UI.AddToggle("Use Best Rage Potion", "Check back for Potions and use best available one", false)
		UI.AddDropdown("CoolD Mode", "Use CDs automaticly or on Keypress", {"None","Auto","Keypress"},2)
		UI.AddDropdown("Key for CDs", "Only in use with Keypress mode", {"None","LeftShift","LeftControl","LeftAlt","RightShift","RightControl","RightAlt"},1)


		UI.AddHeader("Consumables")
		UI.AddToggle("Use Best HP Potion", "Check back for Potions and use best available one")
		UI.AddRange("Use Potion at #% HP", nil, 1, 100, 1, 8)
		UI.AddToggle("Healthstone", nil, true)
		UI.AddRange("Use Healthstone at #% HP", nil, 10, 100, 1, 50, true)		
		
		UI.AddHeader("Engineering Stuff")
		UI.AddToggle("Use Sapper Charge", "uses Sapper according to Setting", false)
		UI.AddRange("Enemys 10Y", "Enemys in 10 Yards Sapper Range", 0, 15, 1, 8)
		UI.AddDropdown("Use Trowables", "Select the item to use", {"None","All","DenseDynamite","EZThroDynamitII","ThoriumGrenade","IronGrenade"},1)
		UI.AddRange("Enemys 5Y around Target", "Enemys in 5 around Target", 0, 15, 1, 8)	
	

		--UI.AddBlank()
		
		
		
    UI.AddTab("CDs Auto Mode")
		UI.AddHeader("Settings for Auto use of CDs")
		UI.AddHeader("Keep in mind that TTD is not accurate in EX-Phase!")	
		UI.AddHeader("You have to set it higher!")		
		UI.AddRange("TTD for DiamondFlask", "Time to die -> use DiamondFlask / duration=60s", 10, 80, 1, 65)
		UI.AddRange("TTD for DeathWish", "Time to die -> use DeathWish / duration=30s", 10, 60, 1, 42)		
		UI.AddRange("TTD for Earthstrike", "Time to die -> use Earthstrike / duration=20s", 10, 60, 1, 35)
		UI.AddRange("TTD for JomGabbar", "Time to die -> use JomGabbar / duration=20s", 10, 60, 1, 35)
		UI.AddRange("TTD for BadgeoftheSwarmguard", "Time to die -> use BadgeoftheSwarmguard / duration=30s", 10, 60, 1, 40)
		UI.AddRange("TTD for BloodFury", "Time to die -> use BloodFury / duration=25s", 10, 60, 1, 38)
		UI.AddRange("TTD for BerserkingTroll", "Time to die -> use BerserkingTroll / duration=10s", 10, 60, 1, 20)
		UI.AddRange("TTD for Recklessness", "Time to die -> use Recklessness / duration=15s", 10, 60, 1, 28)
		UI.AddRange("TTD for RagePotion", "Time to die -> use RagePotion / duration=20s", 10, 60, 1, 35)
 
	UI.AddTab("CDs Keypress Mode")
		UI.AddHeader("Settings Keypress mode and the use of CDs")
		UI.AddHeader("Seconds after ButtonPress to use the Cooldowns")
		UI.AddRange("Seconds after Keypress for DiamondFlask", "duration=60s", 0, 60, 1, 0)
		UI.AddRange("Seconds after Keypress for DeathWish", "durationt=30s", 0, 60, 1, 23)		
		UI.AddRange("Seconds after Keypress for Earthstrike", "duration=20s", 0, 60, 1, 33)
		UI.AddRange("Seconds after Keypress for JomGabbar", "duration=20s", 0, 60, 1, 33)
		UI.AddRange("Seconds after Keypress for BadgeoftheSwarmguard", "duration=30s", 0, 60, 1, 25)
		UI.AddRange("Seconds after Keypress for BloodFury", "duration=25s", 0, 60, 1, 28)
		UI.AddRange("Seconds after Keypress for BerserkingTroll", "duration=10s", 0, 60, 1, 43)
		UI.AddRange("Seconds after Keypress for Recklessness", "duration=15s", 0, 60, 1, 35)
		UI.AddRange("Seconds after Keypress for RagePotion", "duration=20s", 0, 60, 1, 33)		


		
------------------------------------------------------------------------------------------------------------------------------	
	UI.AddTab("Tanky")
    UI.AddHeader("Tanky Stuff")
        UI.AddToggle("SunderArmor", "Applies SunderArmor Spam on GCD if FurryProt", true)
		UI.AddDropdown("Apply Stacks of Sunder Armor", "Apply # Stacks of Sunder Armor", {"1","2","3","4","5"}, "5")
		UI.AddToggle("Revenge", "Auto use Revenge", false)
        UI.AddToggle("Use ShieldBlock", nil, true)
        UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50, true)
	
	UI.AddHeader("Only for FurryProt")
		UI.AddToggle("Swap to shild for kick","Swaps back to 1h after Pummel/ShildBash has to be activ", false)
		UI.AddDropdown("ItemType for Offhand", "Searches for the first item it can equip with selected Type", {"One-Handed Axes","One-Handed Maces","One-Handed Swords","Daggers"}, 1)
		UI.AddBlank()
		UI.AddDropdown("Min Q. gear for Kick Gear","Searches for the first item it can equip with selected Quality", {"white","green","blue","purple"}, 3)
       

	    -- UI.AddToggle("MockingBlow", nil, false)
        -- UI.AddToggle("Taunt", nil, false)
		
    UI.AddHeader("Lifesaver for 2Hand Furry - if Aggro in Raid from boss")		
		UI.AddToggle("Lifesaver", "Will equip a shield and 1h and cast shieldwall if Aggro in RAID", false)
		UI.AddDropdown("Min Q. gear equiped with Lifesaver", "searches for the first item it can equip", {"white","green","blue","purple"}, "3")

	UI.AddTab("Debuffs")	
	UI.AddHeader("Debuffs")
        if DMW.Player.Spells.PiercingHowl:Known() 
		then
			UI.AddRange("PiercingHowl", "Units near w/o debuff", 0, 10, 1, 0)
        end
		UI.AddRange("ThunderClap", "Units near w/o debuff, take care will swap you in BattleStance", 0, 10, 1, 0)
        UI.AddRange("DemoShout", "Units near w/o debuff", 0, 10, 1, 0)
    
	-- UI.AddHeader("Experiments")
        -- UI.AddToggle("abuse", nil, false)
        -- UI.AddRange("abuse range", "qwe", 0, 3, 0.01, 0.5)

------------------------------------------------------------------------------------------------------------------------------	
	UI.AddTab("Buff Sniper")
		UI.AddHeader("If World buff drops log off")
		UI.AddHeader("Only select one")
		UI.AddToggle("WCB", "If Warchiefsblessing is on you log off", false)
		UI.AddToggle("Ony_Nef", "If Dragonslayer is on you log off", false)
		UI.AddToggle("ZG", "If Spirit of Zandalar is on you log off", false)
	
------------------------------------------------------------------------------------------------------------------------------	
	UI.AddTab("Print Spells")
		UI.AddToggle("Print","prints", false)
	
	
end