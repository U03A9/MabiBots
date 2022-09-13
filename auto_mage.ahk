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
; Get user input
InputBox, mana_pool, Total Mana, "Please enter the total amount of MP you have"
InputBox, magic_mana_cost, Skill Charge Cost, "Please enter the mana cost for one charge of the skill in hotkey 4"


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

; Set random intervals for skill casting
Random, inspiration_cooldown, 260000, 260500
Random, snapcast_cooldown, 120000, 120500

; Set up initial triggers
inspiration_trigger := A_TickCount + inspiration_cooldown
snapcast_trigger := A_TickCount + snapcast_cooldown

; ######################################### ;
;  CHANGE ONLY SETTINGS BETWEEN THE LINEs. 

shield_loop := True
inspiration_loop := True
snapcast_loop := True

; ######################################### ;

; Prompt user to start
max_cast_count := Ceil(((mana_pool * .90) / magic_mana_cost))

; Alert user bot is starting
MsgBox, 1, AutoMage, Please verify your settings are correct`n`tTotal Mana %mana_pool%`n`tMana Cost of Skill %magic_mana_cost%`n`tWhen draining mana you will cast %max_cast_count% times
ifMsgBox, OK
{
    ; Undo the assumed click (Ma    binogi ==sue).
    MouseClick, Left, 1, 1, 1, 2, U

    ; Pause to make sure the above worked.
    Sleep 250

    loop{
        ; Select Mabinogi window
        WinActivate, Mabinogi

        ; Randomize timers before new loop
        Random, cast_gap, 1250, 1500
        Random, inspiration_cooldown, 260000, 260500
        Random, snapcast_cooldown, 125000, 127500
        Random, shield_expiration_time, 13500, 14500

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

            }
        }

        if (inspiration_loop == True and A_TickCount >= inspiration_trigger || inspiration_triggered != True){
            ; Cast inspiration
            send {3}
            Sleep, 3500

            ; Set next trigger time
            inspiration_trigger := A_TickCount + inspiration_cooldown
            inspiration_triggered := True

        }
        
        if (snapcast_loop == True and A_TickCount > snapcast_trigger || snapcast_triggered != True){
            ; Turn on Spellwalk
            send {0}
            Sleep, %cast_gap%
            
            ; Snap cast
            send {1}
            Sleep, %cast_gap%

            ; Magic Cast
            send {-}
            Sleep, %cast_gap%          

            ; Target
            send {TAB}
            Sleep, %cast_gap%
            
            ; Use skill
            send {e}
            send {e}
            send {e}
            Sleep, 3500, 5000
 
            ; Turn off Spellwalk
            send {0}
            Sleep, 400, 600

            ; Set next trigger time
            snapcast_trigger := A_TickCount + snapcast_cooldown
            snapcast_triggered := True

        }
    }
}

IfMsgBox, Cancel
{
    ; If OK isn't pressed, exit script  
    ExitApp

}