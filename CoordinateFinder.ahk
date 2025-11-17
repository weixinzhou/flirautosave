; ========================================
; Coordinate Finder Tool - FLIR AutoSave Helper
; ========================================
; Function: Help obtain precise coordinates of screen controls
; Usage:
;   1. Run this script
;   2. Move mouse to the position you need to click
;   3. Press Ctrl+Shift+C to save current mouse coordinates
;   4. Press F1 to view all saved coordinates
;   5. Press F2 to clear saved coordinates
; Note: This tool is for v1.x compatibility. v2.0 uses image recognition instead.
; ========================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Global variables
CoordList := []
CoordCount := 0

; Create GUI to display current coordinates
Gui, +AlwaysOnTop +ToolWindow
Gui, Font, s10, Consolas
Gui, Add, Text, x10 y10 w400, Coordinate Finder Tool - Real-time Mouse Position
Gui, Add, Text, x10 y35 w400 vCoordText, X: 0, Y: 0
Gui, Add, Text, x10 y60 w400, Hotkeys: Ctrl+Shift+C Save Coord | F1 View Saved | F2 Clear
Gui, Show, w420 h90, FLIR Coordinate Finder

; Set timer to update coordinates in real-time
SetTimer, UpdateCoords, 50
return

; Update coordinate display
UpdateCoords:
    MouseGetPos, xpos, ypos
    GuiControl,, CoordText, X: %xpos%, Y: %ypos%
    return

; ========================================
; Hotkey Definitions
; ========================================

; Ctrl+Shift+C - Save current coordinates
^+c::
{
    MouseGetPos, xpos, ypos
    CoordCount++

    ; Ask for coordinate name
    InputBox, CoordName, Coordinate Name, Enter a name for this coordinate (e.g., Frame Input, Save Button):, , 400, 150
    if ErrorLevel
        return

    if (CoordName = "")
        CoordName := "Coordinate" . CoordCount

    ; Save to array
    CoordList.Push({name: CoordName, x: xpos, y: ypos})

    ; Copy to clipboard
    Clipboard := CoordName . "X := " . xpos . "`n" . CoordName . "Y := " . ypos

    ; Show tooltip
    ToolTip, Saved: %CoordName%`nX: %xpos%, Y: %ypos%`n(Copied to clipboard), %xpos%, %ypos%
    SetTimer, RemoveToolTip, 2000

    ; Play notification sound
    SoundBeep, 750, 100

    return
}

; F1 - Display all saved coordinates
F1::
{
    if (CoordList.Length() = 0)
    {
        MsgBox, 48, Coordinate List, No coordinates saved yet!`n`nUse Ctrl+Shift+C to save current mouse position coordinates
        return
    }

    ; Build coordinate list text
    CoordText := "Saved Coordinates:`n`n"
    CoordCode := "; ========================================`n"
    CoordCode .= "; Copy following code to FLIR_AutoSave.ahk`n"
    CoordCode .= "; ========================================`n`n"

    for index, coord in CoordList
    {
        CoordText .= index . ". " . coord.name . "`n   X: " . coord.x . ", Y: " . coord.y . "`n`n"

        ; Generate code format
        varName := RegExReplace(coord.name, "\s+", "")
        CoordCode .= varName . "X := " . coord.x . "      ; " . coord.name . " X coordinate`n"
        CoordCode .= varName . "Y := " . coord.y . "      ; " . coord.name . " Y coordinate`n`n"
    }

    ; Display list
    MsgBox, 64, Saved Coordinates, %CoordText%

    ; Copy code to clipboard
    Clipboard := CoordCode
    TrayTip, Coordinate Code Copied, Coordinate code has been copied to clipboard and can be pasted directly into script, 3, 1

    return
}

; F2 - Clear all saved coordinates
F2::
{
    MsgBox, 4, Confirm Clear, Are you sure you want to clear all saved coordinates?
    IfMsgBox Yes
    {
        CoordList := []
        CoordCount := 0
        MsgBox, 64, Cleared, All coordinates have been cleared!
    }
    return
}

; F3 - Display help
F3::
{
    HelpText =
    (
    ========================================
    FLIR Coordinate Finder Tool - Instructions
    ========================================

    Purpose:
    Obtain screen coordinates of controls in FLIR ResearchIR software interface

    Operation Steps:

    1. Open FLIR ResearchIR software

    2. Open Profile window (window showing temperature curve)

    3. Run this coordinate finder tool

    4. Capture coordinates in the following order:
       a) Move mouse to Save button in Profile window
          Press Ctrl+Shift+C, enter name "Save Button"

       b) Move mouse to "Next Frame" right arrow button in bottom timeline
          Press Ctrl+Shift+C, enter name "Next Frame Arrow"

       c) Click Save button once to open save dialog

       d) Move mouse to filename input box
          Press Ctrl+Shift+C, enter name "Filename Input"

       e) Move mouse to "Save as type" dropdown
          Press Ctrl+Shift+C, enter name "File Type Dropdown"

       f) Move mouse to final Save button
          Press Ctrl+Shift+C, enter name "Final Save Button"

    5. Press F1 to view all coordinates and copy code

    6. Paste copied code into FLIR_AutoSave.ahk

    Hotkeys:
    Ctrl+Shift+C - Save current mouse position coordinates
    F1 - View all saved coordinates and copy code
    F2 - Clear all saved coordinates
    F3 - Display this help
    ESC - Exit program

    Note: v2.0 uses image recognition instead of coordinates
    )

    MsgBox, 64, Instructions, %HelpText%
    return
}

; ESC - Exit
Esc::
{
    MsgBox, 4, Exit Confirmation, Are you sure you want to exit the Coordinate Finder tool?
    IfMsgBox Yes
        ExitApp
    return
}

; Remove tooltip
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return

; Close GUI and exit
GuiClose:
    ExitApp
    return
