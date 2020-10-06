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
                    [2] = {Text = "Sweeping Strikes |cffff0000Off", Tooltip = ""}
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
            [3] = {Text = "|cffff0000No_Moving", Tooltip = ""}
        }
    }

    UI.HUD.Options[3] = {
        Execute = {
            [1] = {Text = "Execute 360++ |cFF00FF00", Tooltip = ""},
            [2] = {Text = "Execute If <= 3 units |cFF00FF00", Tooltip = ""},
            [3] = {Text = "Execute |cFF00FF00Target", Tooltip = ""},
            [4] = {Text = "Execute |cFF00FF00Mix", Tooltip = ""},
            [5] = {Text = "Execute |cffff0000Disabled", Tooltip = ""}
	    }
    }	

    -- UI.AddHeader("This Is A Header")
    -- UI.AddDropdown("This Is A Dropdown", nil, {"Yay", "Nay"}, 1)
    -- UI.AddToggle("This Is A Toggle", "This is a tooltip", true)
    -- UI.AddRange("This Is A Range", "One more tooltip", 0, 100, 1, 70)
	
    UI.AddHeader("Usual Options")
	    -- UI.AddToggle("Debug", nil, false)
		UI.AddDropdown("RotationType", nil, {"2HFury/Fury","FuryProt","Leveling"}, 1)
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
        UI.AddToggle("BattleShout", nil, false)
        UI.AddToggle("Pummel/ShildBash", "Has to be checked for FuryProt swap option", false)
        -- UI.AddToggle("Auto Disable SS", nil, false)
		-- UI.AddToggle("AutoTreatTarget", nil, false) only in tank rota not supported atm
		
		
    UI.AddHeader("DPS Shit/Spells")
        -- UI.AddToggle("Rend", nil, false)	not programmed
		-- UI.AddToggle("SweepingStrikes", nil, false) not programmed
        UI.AddToggle("Bloodthirst", nil, false)
        UI.AddToggle("Whirlwind","Not used in FuryProt", false)
        UI.AddToggle("Overpower","Not used in FuryProt", false)
		UI.AddToggle("MortalStrike", nil, false)
		UI.AddToggle("Heroic Strike", "Will use Heroic Strike for Rage dump, else it will Cleave", false)
		UI.AddToggle("Cleave", "Will use Cleave for Rage dump when there are more targets", false)
		UI.AddToggle("Execute", "Main toogle for Execute", false)
		UI.AddToggle("Hamstring < 35% Enemy HP", nil, false)
		UI.AddToggle("Hamstring PvP", nil, false)
		
------------------------------------------------------------------------------------------------------------------------------

    UI.AddTab("Rage Settings")
	UI.AddHeader("Rage Settings")
		UI.AddToggle("Bloodrage", "Use Bloodrage when available", false)
		UI.AddToggle("Berserker Rage", "Use Berserker Rage", false)
        UI.AddToggle("Rage Dump?", "Shall we Dump the Rage that is too much", false)
        UI.AddRange("Rage Dump", "On witch Value do we have too much Rage", 30, 100, 1, 30)
        UI.AddToggle("Hamstring Dump", "Dumps Rage also with Hamstring, good with Windfury, not used in FuryProt", false)
		UI.AddRange("Hamstring dump above # rage", "At what amount of rage Hamstring will also be used as dump", 0, 100, 1, 50)
		UI.AddToggle("Only HString MHSwing >= GCD", "Uses Hamstring only when MH swing duration is at min. a GCD", false)
		UI.AddBlank()
		UI.AddToggle("Use Slam", "For 2H Slam Spec", false)
		UI.AddRange("Use Slam above # rage", "At what amount of rage Slam will also be used as dump", 0, 100, 1, 50)
		UI.AddToggle("Use Slam over BT", "Uses Slam over BT when we have less then 1500AP", false)
		UI.AddToggle("Toggle HS", "Will queue and unque HS ... when its needed", false)
		UI.AddToggle("Queue HS/ExecutePhase", "Will queue HS in Execute Phase when there is more rage than Excost", false)
		UI.AddRange("RageLose on StanceChange", "What Amount of Rage can we waste for a StanceChange", 0, 100, 1, 30)
		UI.AddToggle("Calculate Rage", "Will use ragecalc for next swings", true)
		UI.AddToggle("FuckRage&StanceDance", "Will dance Stances no matter what rage lvl you are", false)
------------------------------------------------------------------------------------------------------------------------------

    UI.AddTab("CDs & Consumables")
		UI.AddHeader("Cooldowns")	
		UI.AddToggle("Recklessness", "Use Recklessness in Auto/Keypress Mode", false)
		UI.AddToggle("DeathWish", "Use DeathWish in Auto/Keypress Mode", false)
		UI.AddToggle("Racials", "Use Racials in Auto/Keypress Mode", false)
		UI.AddToggle("Trinkets", "Uses supportet Trinkets in Auto/Keypress Mode", false)
		UI.AddBlank()
		UI.AddToggle("Use Best Rage Potion", "Check back for Potions and use best available one", false)
		UI.AddDropdown("CoolD Mode", "Use CDs automaticly or on Keypress", {"None","Auto","Keypress"},2)
		UI.AddDropdown("Key for CDs", "Only in use with Keypress mode", {"None","LeftShift","LeftControl","LeftAlt","RightShift","RightControl","RightAlt"},1)


		UI.AddHeader("Consumables")
		UI.AddToggle("Use Best HP Potion", "Check back for Potions and use best available one")
		UI.AddRange("Use Potion at #% HP", nil, 1, 100, 1, 8)
		UI.AddToggle("Healthstone", nil, false)
		UI.AddRange("Use Healthstone at #% HP", nil, 10, 100, 1, 50, true)	
		UI.AddToggle("Use Bandages", nil, false)
		UI.AddRange("Use Bandages at #% HP", nil, 10, 100, 1, 50, true)
		
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
    UI.AddHeader("Tanky & Debuffs")
		UI.AddToggle("First Global Sunder", "On new Target the first Global will be SunderArmor if not 5 Stacks", false)
		UI.AddRange("GCDSunder MaxHP", "Will Sunder on first GCD only mobs with a bigger max health in tousands", 5, 100, 5 ,25)		
		UI.AddToggle("SunderArmor", "Applies SunderArmor Spam on GCD if FuryProt", false)
		UI.AddDropdown("Apply Stacks of Sunder Armor", "Apply # Stacks of Sunder Armor", {"1","2","3","4","5"}, "5")
		
		UI.AddToggle("Revenge", "Auto use Revenge", false)
		UI.AddBlank()
        UI.AddToggle("Use ShieldBlock", nil, false)
        UI.AddRange("Shieldblock HP", nil, 30, 100, 5, 50, true)
		UI.AddToggle("Use Shielwall", nil, false)
        UI.AddRange("Shieldwall HP", nil, 30, 100, 5, 50, true)
		UI.AddHeader("Debuffs")
		UI.AddRange("PiercingHowl", "Units near w/o debuff", 0, 10, 1, 0)
        UI.AddRange("ThunderClap", "Units near w/o debuff, take care will swap you in BattleStance", 0, 10, 1, 0)
        UI.AddRange("DemoShout", "Units near w/o debuff", 0, 10, 1, 0)
		
	

		-- UI.AddDropdown("ItemType for Offhand", "Searches for the first item it can equip with selected Type", {"One-Handed Axes","One-Handed Maces","One-Handed Swords","Daggers"}, 1)
		-- UI.AddBlank()
		-- UI.AddDropdown("Min Q. gear for Kick Gear","Searches for the first item it can equip with selected Quality", {"white","green","blue","purple"}, 3)
       

	    -- UI.AddToggle("MockingBlow", nil, false)
        -- UI.AddToggle("Taunt", nil, false)
		
    UI.AddTab("Lifesaver Weapon and Rotation Changes")
		-- UI.AddHeader("Swap in a Shield to kick")
		-- UI.AddToggle("Swap to shield for kick","Swaps back to 1h after... Pummel/ShildBash has to be activ", false)
		
		UI.AddHeader("Lifesaver Weapon and Rotation Changes")
		UI.AddToggle("Lifesaver", "Will swap to defensive rotation", false)
		UI.AddToggle("Lifes. allways", "Will trigger lifesaver allways on Aggro", false)
		UI.AddToggle("Lifesaver only in Raid", "Will use this only in a Raid", false)
		UI.AddBlank()
		--UI.AddToggle("Lifes. Bossaggro", "Will trigger lifesaver only on Bossaggro", false)
		UI.AddToggle("Lifes. Enemy Level", "Will activate Lifesaver on Enemy LVL", false)
		UI.AddRange("EnemyLvl", "Will trigger lifesaver only on Enemies Lvl", 0, 63, 1 ,61)
		UI.AddToggle("Lifes. Enemy Max HP", "Will activate Lifesaver on Max Hp", false)
		UI.AddRange("MaxHP in tousands", "Will trigger lifesaver only on Enemies with more ... max health in kilo", 5, 100, 5 ,20)


		UI.AddToggle("Equip 1h and shield when aggro", "Equips 1 hander and Shield on aggro", false)
		UI.AddBlank()
		UI.AddTextBox("ItemID DefMainhand", "Put in the ItemID of your Defensive Mainhand", 0.9, nil)		
		UI.AddTextBox("ItemID Shield", "Put in the ItemID of you Shield", 0.9, nil)
		
		UI.AddToggle("Equip 2 x 1h after aggroloose", "Will equip 2 x 1 hander after aggroloose", false)
		UI.AddBlank()
		UI.AddTextBox("ItemID Mainhand", "Put in the ItemID of your Mainhand", 0.9, nil)
		UI.AddTextBox("ItemID Offhand", "Put in the ItemID of your Offhand", 0.9, nil)
		
		UI.AddToggle("Equip 2H after aggroloose", "Will equip 2 hander after aggroloose", false)
		UI.AddTextBox("ItemID 2 Hander", "Put in the ItemID of you 2 Hander", 0.9, nil)

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

	--Debug/Print
	UI.AddTab("Debug/Print")
	UI.AddToggle("Debug","enables Debug, pls activate rotation once", false)
	UI.AddToggle("Log","enables Log, pls activate rotation once", false)
	UI.AddToggle("Print Target Armor","Prints the Calculated Target Armor....can be wrong on low level Mobs", false)
	UI.AddToggle("Print Armormitigation","Prints the Armormitigation", false)
	
end