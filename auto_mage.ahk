;
; AutoHotkey Script by CIDR#6168
;
; Start Mabinogi, compile this script, run executable as administrator
; This script will automatically cast inspiration, snapcast + magic cast, and all shields.
; You can modify the below code to match your own hotkeys. In the future, I will add GUI
; support for setting hotkeys. 
;
; v1.0.0

#SingleInstance Force \; Only allow one instance
#UseHook ; Improves response time of key presses
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

If not A_IsAdmin
    Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" ; Run script as admin


SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Client ; Easy coordinate mode.

; ========================================================================================= ;

; CODE FOR GUI (Future)
;CustomColor = 000000
;Gui +LastFound +AlwaysOnTop +ToolWindow -Caption
;Gui, Color, %CustomColor%
;Gui, Font, s10, Lucida Console
; 
;Gui, Add, Text, x50 y0 w385 BackgroundTrans 0x5
;Gui, Add, Text, x50 y0 w385 BackgroundTrans cWhite, AutoMage Bot is Off
;WinSet, TransColor, %CustomColor% 230
;Gui, Add, CheckBox, checked vvari1 x12 y10 w115, Field1
;Gui, Show

; ######################################### ;
;  CHANGE ONLY SETTINGS BETWEEN THE LINES. 

shield_loop := False
inspiration_loop := True
snapcast_loop := True
crusader_loop := True 
spellwalk_adv_magic_training := True
mana_burn := False

; ######################################### ;

; Prompt user to start
max_cast_count := Ceil(((mana_pool * .90) / magic_mana_cost))

; Alert user bot is starting
if (mana_burn == True){
    ; Get user input
    InputBox, mana_pool, Total Mana, "Please enter the total amount of MP you have"
    InputBox, magic_mana_cost, Skill Charge Cost, "Please enter the mana cost for one charge of the skill in hotkey 4"

    MsgBox, 1, AutoMage, Please verify your settings are correct`n`tTotal Mana %mana_pool%`n`tMana Cost of Skill %magic_mana_cost%`n`tWhen draining mana you will cast %max_cast_count% times

} else{
    MsgBox, 1, AutoMage, Please verify your settings are correct`n`tManaburn Off

}

ifMsgBox, OK
{
    ; Undo the assumed click (Ma    binogi ==sue).
    MouseClick, Left, 1, 1, 1, 2, U

    ; Pause to make sure the above worked.
    Sleep 250
    
    ; Select Mabinogi window
    WinActivate, Mabinogi

    ; Set random intervals for skill casting before new loop
    Random, inspiration_cooldown, 260000, 260500
    Random, snapcast_cooldown, 120000, 120500
    Random, crusader_cooldown, 15000, 15500

    ; Set up initial triggers before new loop
    inspiration_trigger := A_TickCount + inspiration_cooldown
    snapcast_trigger := A_TickCount + snapcast_cooldown
    crusader_trigger := A_TickCount + crusader_cooldown

    loop{

        ; Randomize cast gap before new loop
        Random, cast_gap, 1250, 1500

        if (shield_loop == True){
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

        if (inspiration_loop == True and A_TickCount > inspiration_trigger || inspiration_triggered != True){
            ; Cast inspiration
            send {3}
            Sleep, 3500

            ; Set trigger
            inspiration_triggered := True
            inspiration_trigger = A_TickCount + inspiration_cooldown

        }
        
        if (snapcast_loop == True and A_TickCount > snapcast_trigger || snapcast_triggered != True){
            ; Turn on Spellwalk
            send {0}
            Sleep, %cast_gap%

            ; Snap cast
            send {1}
            Sleep, %cast_gap%

            ; Magic Cast
            if (spellwalk_adv_magic_training == True){
                ; This will instead cast skills in the following order to fulfill spellwalk training requirements
                ; 0 - Ice Spear
                ; 1 - Thunder
                ; 2 - Fireball

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
            Sleep, 5500, 6500
 
            ; Turn off Spellwalk
            send {0}
            Sleep, 400, 600

            ; Set trigger
            snapcast_triggered := True
            snapcast_trigger = A_TickCount + snapcast_cooldown

        }

        if (crusader_loop == True and A_TickCount > crusader_trigger || crusader_triggered != True){
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

                current_skill := 2

            ; Sword
            } else if (current_skill == 2){
                send {7}
                Sleep, %cast_gap%

                current_skill := 0

            }

            ; Set trigger
            crusader_triggered := True
            crusader_trigger = A_TickCount + crusader_cooldown

        }
    }
}

IfMsgBox, Cancel
{
    ; If OK isn't pressed, exit script  
    ExitApp

}