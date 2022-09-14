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
CustomColor := e8e8e8
WinSet, TransColor, %CustomColor% 230
Gui, Add, CheckBox, vMagicShield, Magic Shield Training
Gui, Add, CheckBox, vInspiration, Inspiration Training
Gui, Add, CheckBox, vBurnMana, -- Burn Mana to 10`%
Gui, Add, CheckBox, vSnapcast, Snapcast + Spellwalk Training
Gui, Add, CheckBox, vSpellwalk, -- Cycle Ice Spear, Lightning, Fireball
Gui, Add, CheckBox, vCrusader, Crusader Training
Gui, Add, Text, , MabiBot `n  -- by CIDR
Gui, Add, Button, gstart, Start
Gui, Add, Button, gquit, Quit

; Push gui to top right of screen
SysGet, sizeframe, 33
SysGet, cyborder, 8
GuiWidth := 500, GuiHeight := 250
gui,show, % "x" A_ScreenWidth - GuiWidth - sizeframe - cyborder " y"  cyborder " w" Guiwidth " h" GuiHeight
return

start:
    Gui, Submit, NoHide
	GuiControl, Enable, Stop
	GuiControl, Disable, Start

    ; Alert user bot is starting
    if (BurnMana == True){
        ; Get user input
        InputBox, mana_pool, Total Mana, "Please enter the total amount of MP you have"
        InputBox, magic_mana_cost, Skill Charge Cost, "Please enter the mana cost for one charge of the skill in hotkey 4"

        ; Set cast count
        max_cast_count := Ceil(((mana_pool * .90) / magic_mana_cost))

    }
        
    ; Select Mabinogi window
    WinActivate, Mabinogi

    ; Undo the assumed click (Mabinogi issue).
    MouseClick, Left, 1, 1, 1, 2, U

    ; Pause to make sure the above worked.
    Sleep 250

    ; Set up initial triggers
    Random, inspiration_cooldown, 260000, 262500
    Random, snapcast_cooldown, 90000, 92500
    Random, crusader_cooldown, 20000, 22500

    inspiration_trigger := A_TickCount
    snapcast_trigger := A_TickCount
    crusader_trigger := A_TickCount

    loop{

        ; Set random intervals for skill casting before new loop
        Random, inspiration_cooldown, 260000, 262500
        Random, snapcast_cooldown, 90000, 92500
        Random, crusader_cooldown, 20000, 22500
        
        ; Randomize cast gap before new loop
        Random, cast_gap, 1250, 1500

        if (MagicShield == True){
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

        if (Inspiration == True and A_TickCount > inspiration_trigger){
            if (BurnMana == True){
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
            inspiration_trigger := A_TickCount + inspiration_cooldown

        }
        
        if (Snapcast == True and A_TickCount > snapcast_trigger){
            ; Snap cast
            send {1}
            Sleep, %cast_gap%

            ; Magic Cast
            if (Spellwalk == True){
                ; This will instead cast skills in the following order to fulfill Spellwalk training requirements
                ; 0 - Ice Spear
                ; 1 - Thunder
                ; 2 - Fireball
                ; 3 - Party Healing

                ; Turn on Spellwalk
                send {0}
                Sleep, %cast_gap%


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

            if (Spellwalk == True){
                ; Turn off Spellwalk
                send {0}
                Sleep, 400, 600
            }
            
            ; Set trigger
            snapcast_trigger := A_TickCount + snapcast_cooldown

        }

        if (Crusader == True and A_TickCount > crusader_trigger){
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
            crusader_trigger := A_TickCount + crusader_cooldown

        }
    }
return

over:
GuiClose:
GuiEscape:
quit:
ExitApp

