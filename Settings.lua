local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
    -- DMW.Helpers.Rotation.CastingCheck = false
    if DMW.Player.Talents.SweepingStrikes.Rank > 0 then
        UI.HUD.Options = {
            [1] = {
                Sweeping = {
                    [1] = {Text = "Sweeping Strikes |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "Sweeping Strikes |cFFFFFF00Off", Tooltip = ""}
                }
            }
        }
    elseif DMW.Player.Talents.DeathWish.Rank > 0 then
        UI.HUD.Options = {
            [1] = {
                DeathWish_Racial = {
                    [1] = {Text = "DeathWish&Racial |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "DeathWish&Racial |cFFFFFF00Off", Tooltip = ""}
                }
            }
        }
    else
        UI.HUD.Options = {
            [1] = {
                DeathWish_Racial = {
                    [1] = {Text = "DeathWish&Racial |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "DeathWish&Racial |cFFFFFF00Off", Tooltip = ""}
                }
            }
        }
    end
    UI.HUD.Options[2] = {
        Charge = {
            [1] = {Text = "Charge |cFF00FF00And_InterCept", Tooltip = ""},
            [2] = {Text = "Only |cFFFFFF00InterCept", Tooltip = ""},
            [3] = {Text = "|cFFFFFF0No_Moving", Tooltip = ""}
        }
    }
    UI.HUD.Options[3] = {
        Execute = {
            [1] = {Text = "Execute 360++", Tooltip = ""},
            [2] = {Text = "Execute If <= 3 units", Tooltip = ""},
            [3] = {Text = "Execute |cffffffffTarget", Tooltip = ""},
            [4] = {Text = "Execute |cFFFFFF00Disabled", Tooltip = ""}
        }
    }
    -- UI.AddHeader("This Is A Header")
    -- UI.AddDropdown("This Is A Dropdown", nil, {"Yay", "Nay"}, 1)
    -- UI.AddToggle("This Is A Toggle", "This is a tooltip", true)
    -- UI.AddRange("This Is A Range", "One more tooltip", 0, 100, 1, 70)
	
	
	
    UI.AddHeader("Usual Options")
	    -- UI.AddToggle("Debug", nil, false)
		UI.AddDropdown("RotationType", nil, {"Fury","Tank"}, "Fury")
		UI.AddBlank()
		UI.AddToggle("BattleStance NoCombat", "Switches to Battle Stance if we are not InCombat" , false)
        UI.AddToggle("Charge&Intercept", nil, false)
		
	 -- UI.AddHeader("What Stance to Check first")	
        -- UI.AddDropdown("First check Stance", "", {"Battle","Defensive","Berserker"}, "Battle")
        -- UI.AddDropdown("Second check Stance", "", {"Battle","Defensive","Berserker"}, "Berserker")
        -- UI.AddDropdown("Third check Stance", "", {"Battle","Defensive","Berserker"}, "Defensive")

		
    UI.AddHeader("Auto Stuff")
        UI.AddToggle("AutoFaceMelee", "Makes you Face the Target all the Time", false)
        UI.AddToggle("AutoTarget", "Targets the next Target automaticly", false)
        UI.AddToggle("BattleShout", nil, true)
        UI.AddToggle("Pummel/ShildBash", nil, false)
        -- UI.AddToggle("Auto Disable SS", nil, false)
		-- UI.AddToggle("AutoTreatTarget", nil, false) only in tank rota not supported atm
		
    --UI.AddHeader("Big Cooldowns")
        --UI.AddToggle("Racial", nil, false)	not programmed
		--UI.AddToggle("Bloodrage", nil, false)	not programmed
		
    UI.AddHeader("Dps Shit")
        -- UI.AddToggle("Rend", nil, false)	not programmed
		-- UI.AddToggle("SweepingStrikes", nil, false) not programmed
        UI.AddToggle("BThirst", nil, true)
        UI.AddToggle("Whirlwind", nil, true)
        UI.AddToggle("Overpower", nil, true)
		UI.AddToggle("Hamstring < 35% Enemy HP", nil, true)
		
	UI.AddHeader("Rage Settings")
		UI.AddToggle("Bloodrage", "Use Bloodrage when available", false)
		UI.AddToggle("Berserker Rage", "Use Berserker Rage", false)
        UI.AddToggle("Rage Dump?", "Shall we Dump the Rage that is too much", false)
        UI.AddRange("Rage Dump", "On witch Value do we have too much Rage", 50, 100, 5, 60)
        UI.AddToggle("Hamstring Dump", "Dumps Rage also with Hamstring, good with Windfurry", false)
		UI.AddRange("RageLose on StanceChange", "What Amount of Rage can we waste for a StanceChange", 0, 100, 5, 30)
        -- UI.AddToggle("Slam Dump", nil, false)	

    UI.AddHeader("Tanky Stuff")
        UI.AddToggle("SunderArmor", "Applies SunderArmor debuff to Targets", true)
		UI.AddDropdown("Apply Stacks of Sunder Armor", "Apply # Stacks of Sunder Armor", {"1","2","3","4","5"}, "5")
		UI.AddToggle("Revenge", nil, false)
        UI.AddToggle("Use ShieldBlock", nil, true)
        UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50)
        UI.AddToggle("MockingBlow", nil, false)
        UI.AddToggle("Taunt", nil, false)
    
	UI.AddHeader("Debuffs")
        if DMW.Player.Spells.PiercingHowl:Known() 
		then
			UI.AddRange("PiercingHowl", "Units near w/o debuff", 0, 10, 1, 0)
        end
		UI.AddRange("ThunderClap", "Units near w/o debuff", 0, 10, 1, 0)
        UI.AddRange("DemoShout", "Units near w/o debuff", 0, 10, 1, 0)
    
	-- UI.AddHeader("Experiments")
        -- UI.AddToggle("abuse", nil, false)
        -- UI.AddRange("abuse range", "qwe", 0, 3, 0.01, 0.5)

    UI.AddTab("Consumables")
	UI.AddHeader("Consumables")
	UI.AddToggle("Use Best HP Potion", "Check back for Potions and use best available one")
	UI.AddRange("Use Potion at #% HP", nil, 10, 100, 1, 50, true)

		
end
