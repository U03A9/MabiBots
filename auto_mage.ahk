;
; AutoHotkey Script by CIDR#6168
;
; Start Mabinogi, compile this script, run executable as administrator
; This script will automatically cast inspiration, snapcast + magic cast, and all shields.
; You can modify the below code to match your own hotkeys. In the future, I will add GUI
; support for setting hotkeys. 
;
; v1.0.0

#SingleInstance Force ; Only allow one instance
#UseHook ; Improves response time of key presses
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Client ; Easy coordinate mode.

; ========================================================================================= ;

; Set up GUI
Gui +LastFound +AlwaysOnTop +ToolWindow -Caption
Gui, Font, s10, Lucida Console
WinSet, TransColor, %CustomColor% 230
Gui, Add, CheckBox, checked vMagicShield, Magic Shield Training
Gui, Add, CheckBox, checked vInspiration, Inspiration Training
Gui, Add, CheckBox, checked vBurnMana, -- -- Burn Mana to 10%
Gui, Add, CheckBox, checked vSnapcast, Snapcast + Spellwalk Training
Gui, Add, CheckBox, checked vSpellwalk, -- -- Cycle Ice Spear, Lightning, Fireball
Gui, Add, CheckBox, checked vCrusader, Crusader Training
Gui, Add, Text, , MabiBot `n  -- by CIDR
Gui, Add, Button, gstart, Start
Gui, Add, Button, gstop, Stop
Gui, Add, Button, gexit, Stop
Gui, show, w400 h250
return

stop:
	GuiControl, Enable, Start
	GuiControl, Disable, Stop
	stopped := 1
return

start:
	GuiControl, Enable, Stop
	GuiControl, Disable, Start
	stopped := 0

    ; Alert user bot is starting
    if (mana_burn == True){
        ; Get user input
        InputBox, mana_pool, Total Mana, "Please enter the total amount of MP you have"
        InputBox, magic_mana_cost, Skill Charge Cost, "Please enter the mana cost for one charge of the skill in hotkey 4"

        ; Set cast count
        max_cast_count := Ceil(((mana_pool * .90) / magic_mana_cost))

        MsgBox, 1, AutoMage, Please verify your settings are correct`n`tTotal Mana %mana_pool%`n`tMana Cost of Skill %magic_mana_cost%`n`tWhen draining mana you will cast %max_cast_count% times

    } else{
        MsgBox, 1, AutoMage, Please verify your settings are correct`n`tManaburn Off

    }

    ifMsgBox, OK
    {
        
        ; Select Mabinogi window
        WinActivate, Mabinogi

        ; Undo the assumed click (Mabinogi issue).
        MouseClick, Left, 1, 1, 1, 2, U

        ; Pause to make sure the above worked.
        Sleep 250

        ; Set up initial triggers
        Random, inspiration_cooldown, 260000, 260500
        Random, snapcast_cooldown, 120000, 120500
        Random, crusader_cooldown, 20000, 20500

        inspiration_trigger := A_TickCount + inspiration_cooldown
        snapcast_trigger := A_TickCount + snapcast_cooldown
        crusader_trigger := A_TickCount + crusader_cooldown

        loop{

            ; Set random intervals for skill casting before new loop
            Random, inspiration_cooldown, 260000, 260500
            Random, snapcast_cooldown, 120000, 120500
            Random, crusader_cooldown, 20000, 20500
            
            ; Randomize cast gap before new loop
            Random, cast_gap, 1250, 1500

            if (vMagicShield == True){
                ; Set script start time
                start_time := A_TickCount

                ; Loop through shield skills
                while (A_tickcount < (start_time + shield_expiration_time)){
                    ; Fire Shield
                    send {5}
                    Sleep, (shield_expiration_time)  

                    ; Ice Shield
                    send {6}
                    Sleep, (shield_expiration_time)

                    ; Lightning Shield
                    send {7}
                    Sleep, (shield_expiration_time)

                    ; Natural shield
                    send {8}

                }
            }

            if (vInspiration == True and A_TickCount > inspiration_trigger || inspiration_triggered != True){
                if (vManaBurn == True){
                    ; Turn Mediation off
                    send {9}
                    Sleep, %cast_gap%

                    ; Sets counter
                    cast_count := 0

                    ; Burn out mana
                    while cast_count < max_cast_count{
                        ; Cast magic and cancel
                        send {4}
                        Sleep, 2500, 3000
                        send {x}
                        Sleep, 800, 1200

                        ; Cancel skill and increment
                        cast_count += 1
                    }

                    ; Turn Meditation on
                    send {9}                    

                }
                
                ; Cast inspiration
                send {3}
                Sleep, 3500

                ; Set trigger
                inspiration_triggered := True
                inspiration_trigger := A_TickCount + inspiration_cooldown

            }
            
            if (vSnapcast == True and A_TickCount > snapcast_trigger || snapcast_triggered != True){
                ; Turn on Spellwalk
                send {0}
                Sleep, %cast_gap%

                ; Snap cast
                send {1}
                Sleep, %cast_gap%

                ; Magic Cast
                if (vSpellWalk == True){
                    ; This will instead cast skills in the following order to fulfill spellwalk training requirements
                    ; 0 - Ice Spear
                    ; 1 - Thunder
                    ; 2 - Fireball
                    ; 3 - Party Healing

                    ; Ice Spear
                    if (current_spell == 0 || spell_triggered != True){
                        send {F5}
                        Sleep, %cast_gap%

                        current_spell := 1
                        spell_triggered := True

                    ; Thunder
                    } else if (current_spell == 1){
                        send {F6}
                        Sleep, %cast_gap%
                        
                        current_spell := 2

                    ; Fireball
                    } else if (current_spell == 2){
                        send {F7}
                        Sleep, %cast_gap%
                        
                        current_spell := 3
                    
                    ; Party Healing
                    } else if (current_speel == 3){
                        send {F8}
                        Sleep, %cast_gap%
                        
                        current_spell := 0

                    }
                } else{
                    send {2}
                    Sleep, %cast_gap%          

                }
                
                ; Target
                send {TAB}
                Sleep, %cast_gap%
                
                ; Use skill
                send {e}
                Sleep, %cast_gap%
                send {e}
                Sleep, 5500, 6500
    
                ; Turn off Spellwalk
                send {0}
                Sleep, 400, 600

                ; Set trigger
                snapcast_triggered := True
                snapcast_trigger := A_TickCount + snapcast_cooldown

            }

            if (vCrusader == True and A_TickCount > crusader_trigger || crusader_triggered != True){
                ; This will loop through the various skills one at a time (since they share a cooldown)
                ; 0 - Shield
                ; 1 - Spike
                ; 2 - Sword

                ; Shield
                if (current_skill == 0 || skill_triggered != True){
                    send {5}
                    Sleep, %cast_gap%

                    current_skill := 1
                    skill_triggered := True

                ; Spike
                } else if (current_skill == 1){
                    send {6}
                    Sleep, %cast_gap%

                    ; Target and use
                    send {TAB}
                    Sleep, 850, 1250
                    send {e}
                    Sleep, %cast_gap%
                    send {e}

                    current_skill := 2

                ; Sword
                } else if (current_skill == 2){
                    send {7}
                    Sleep, %cast_gap%

                    ; Target and use
                    send {TAB}
                    Sleep, 850, 1250
                    send {e}
                    Sleep, %cast_gap%
                    send {e}
                    
                    current_skill := 0

                }

                ; Set trigger
                crusader_triggered := True
                crusader_trigger := A_TickCount + crusader_cooldown

            }
        }
    }

    IfMsgBox, Cancel
    {
        ; If OK isn't pressed, exit script  
        ExitApp

    }
return

over:
GuiClose:
GuiEscape:
ExitApp

