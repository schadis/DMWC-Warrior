# DMWC-Warrior

* 2h Fury same as Furry and FuryProt and simple Leveling rota
* IF you wanna know what good settings are go to https://guybrushgit.github.io/WarriorSim/ and sim it
* install details addon for rage calc of incoming dmg

## Feedback in Discord is welcome

## There is no PVP coding or Support

## Supported Trinkets and Consumes

* DiamondFlask
* Earthstrike
* JomGabbar 
* BadgeoftheSwarmguard
* BadgeoftheSwarmguard
* MightyRagePotion
* GreatRagePotion
* SapperCharges
* Nates and Dynamite (not all and this part needs work)

## Todo: ???

## Changelog

## 11.12.2020

* fixed typo at Only HString MHSwing > 0.5 in the rotation
* trying to fix ragelost on stance dance that "Fuck Rage Lost Setting" is not needed anymore 
* above fails if you are swap settings infight, going tank rotation as example (need new idea)

## 20.11.2020

* trying to fix ragelost on stance dance that "Fuck Rage Lost Setting" is not needed anymore 
(fails if you are swap settings infight, going tank rotation as example)
* changed ragecalc to also go after WW if WW is your next mainspell
* removed ragecalc on fury for ww as mainspell cause dump was used before ww and ww was not cast
* fixed ww on Cthun that it is not used cause of to much range to the hitbox
* splited of Cleave and HS ragedump for furyprot to seperate lines cause of ragecalc
* TESTING: Viscidus rotation and weaponswap to frost weapons(swap not always working)

## 17.11.2020

* added LIP instead of Healthpot on HP setting toggle
* removed lifesaver (was not working reliable)
* added spell tab for different Rotations (fury/prot&furyprot)
* added rend in PVP for rogues
* added ragecalc to also do the calculation for next Whirlwind
* fixed exposed armor check
* changed rage dump spellcasts back to regular cast (was looping)
* fixed sunder dump for fury prot
* fixed sunderstacks there was a wrong operator
* added weaponswap menu
* TESTING: added Viscidus rotation and weaponswap to frost weapons(swap not always working)
* TESTING:(rotation only does autos in def stance swaps to bersi if you target a blob)
* Known BUG: Pls use Fuck Rage Setting cause lost Rage on stance dance needs fix!!!

* No guarantee that every change is documented!!!

## 23.10.2020

* fixed addon out of date issue

## 12.10.2020

* fixed LIP support
* Autotarget and Autoface fixes

## 06.10.2020

* fixed Stuck in stance dance
* added bandage support

## 05.10.2020

* added simple leveling rota (not every option does something in this, pls try yourself)
* fixed Settings for First Global Sunder
* fixed Settings for lifesaver
* fixed whatisqued
* added toogle for HS toggling (was auto on before)
* exposed armor check for sunder armor
* restructure of the code
* merged experimental into master branch

## 27.09.2020

* First Global Sunder
* battleshout monitoring to prevent overriding
* toggle to ignore rageloose when stancedancing
* changed most spellcast on smartcast to ensure stance is correct

## 23.09.2020

* removed seperate lifesaver rotation will switch to furry prot instead
* added weapon switching in defferent forms
* removed equip shild for kick cause was not working
* added more settings for differen things like shildwall if you want to use it as lifesaver
* added different seetings for lifesaver as trigger (allways, bossaggro, aggro of a target lvl+ or its maxHP)

## 21.09.2020

* fixed a bug in ragecalc (was not working without a reload)
* added toogle to switch of ragecalc
* added Heroic Strike and Cleave and Execute Main toggles

## 09.09.2020

* fixed execute functions
* remover MS over execute cause it was bullshit(only BT is better when AP >=2000)
* finished rage calculation function (install details Addon if you whant to have incoming dmg inclunded)
* added calculation of armor and armor mitigation value
* added the possibility to print target armor in chat (information for you)
* added calculation for minimum ragegain Mainhand and Offhand (incl.% dmg Worldbuffs)
* changed dump function from cd of mainspell dependend to ragecalc
* removed dump with HS from Hud and added a toogle instead
* moved some of the functions to a other position in the code (that everything can be called)

## 02.09.2020

* added trinket and seperated cooldown toggles (cds, racials...)
* repositioned slam in the code (from dump to main rotation)
* added toogle to use slam over BT when AP is lower than 1500
* added checks that the rage dump spells dont delay BT caused by global
* added a section to the dump function for slam rotation
* reformated the rotation

## 31.08.2020

* added slam into dump function 
* added settings for slam

## 30.08.2020

* changed fix spellcost to functions to get values from talents and spellbook
* fix for utility section (was breaking the rotation)
* added hamstring Only HString MHSwing >= GCD
* added toogle for HS during EX Phase (when we have rage above execute cost)

## 28.08.2020

* small fixes to new code
* removed auto reduce cd times when there is no DiamondFlask equipped
* press your cd Key according to settings

## 27.08.2020

* added FurryProt Rotation (FurryProt untested)
* added shild swap mechanic in FurryProt rota for kicks
* added engineering items (sapper charge, nades, dynamite)      !!! will work with my DMWC fork or after merge!!!
* pls be aware that intercept or thunderclap or Execute will swap you out of defstance 
* it will not swap back until revenge procs and Conditions of ragelost setting is met

## 23.08.2020

* small fix to execute variant 4 (thx immy)
* added BadgeoftheSwarmguard and uncommented all other trinkets (will work with my DMWC fork or after merge)

## 18.08.2020

* fixed rage dump
* fixed cd usage

## 13.08.2020

* if you press your cooldown key it will fire each CD according to your settings.
* if your dont have DiamondFlask please Change settings accordingly.(to something like this 0,0,5,20,15,10 seconds)
* the setting "Change CDs Timing K.Mode" is only visible if you have a DiamondFlask equiped or in you inventory.
* with DiamondFlask and "Change CDs Timing K.Mode" not checked push your button around when the last 60secs of the fight are starting.
* with DiamondFlask cause of whatever in your inventory and "Change CDs Timing K.Mode" checked and you press your key 
* it will fire CDs in order directly after you press the button. (~last 30secs of the fight)

## 12.08.2020

* if you hit the 60seconds(with diamond flask) left to die mark with your CD Keypress, standard setting work well!
* added Hamstring dump above configured rage setting (was a fixed value before)
* added many settings for cooldown usage for auto and keypress mode
* removed auto use of diamond flask in keypress mode (will now be used on keypress)
* in keypress mode: the times after keypress when each cooldown is triggerd can be configured under settings
* if are 0 Cds left the function and the display in the hud will auto swap to disabled

## 11.08.2020

* reworkt CD trigger by button press (it will change the original cooldown HUD-UI toogle.....needs testing)
* interrupt HUD-UI can now be used (please check the spells it shall use under settings)
* in keypress mode diamond flask will be auto used or forced with the rest of the CDs by the button
* added 4th option for execute which is a combination of all other more or less^^

## 10.08.2020 

* added cooldown section into settings
* added button pressed forcing of cds (needs testing)
* fixed execute 360 (thanks immy)
* added MS with a checks if you have BT or MS
* added MS also in execute phase when over 2000Ap (incl. buffs, only working with execute on target setting)
* changed position of cooldowns function to work in execute phase
* reformat and deletion of useless stuff
* some spellchecks if these are known or on cd
* NOT TESTED (no lua errors on load)

## 09.08.2020

* added BT in execute phase when over 2000Ap (incl. buffs, only working with execute on target setting)
* changed rage dump (beginns to dump when the value of the setting is reached)
* dumpes with HS or cleave over 30 rage and if there is rage left or over 65 rage it uses Hamstring

## 07.08.2020

* added auto trinked use for Earthstrike and JomGabbar
* removed tank setting and rotation(out commented)

## 18.05.2020

* fixed lifesaver

## 14.05.2020

* If unitdebuff returns something else for sunder armor than 0-5 stacks sunder armor will be ignored

## 04.05.2020

* New settings Tabs for better overview
* added Hamstring for PVP
* added HS and Cleave canceling if low on Rage
* added lifesaver feature (if aggro swap to first 1h and shield it finds in your bag goes deff and cast wall if low HP
* if you dont have no aggro anymore it will swap back to the normal rotation)
* added my buff sniper (it only logs you out when the slected buff is droped, pls only select one at a time)
* if cooldows are activated in the Hud it will use flask if equiped 
* for the last 60 seconds and the rest of your CDs about 30s Time to Die 
* pls dont tank a raid with this rotation play fury or 2h fury thx

## 20.04.2020

* fixed sunder armor stacks 

## 14.04.2020

* DMWC-Warrior fury 2h with hamstring dump or tank (for dungeons tank shall work) 
* working with uploaded DMWC
* all not working thing are commented out 
