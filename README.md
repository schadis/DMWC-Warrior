# DMWC-Warrior

* 2h Fury, Fury and MS is working(no PVP coding)
* all the best to immortalhz
* IF you wanna know what good settings are go to https://guybrushgit.github.io/WarriorSim/ and sim it

## Todo: 

* ??? Tell me more

## Changelog

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
