; ========================================
; FLIR ResearchIR Batch Frame Export Tool v2.0
; ========================================
; Function: Automate batch export of FLIR ResearchIR frame data to CSV
; Feature: Uses image recognition technology, no manual coordinate configuration needed
; ========================================

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Set all coordinate modes to Screen (not relative to active window)
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

; ========================================
; Configuration Parameters - Modify as needed
; ========================================

; Frame range settings
StartFrame := 1          ; Starting frame number
EndFrame := 100          ; Ending frame number

; Save path settings (modify to your actual save path)
SavePath := "C:\FLIR_Export"  ; CSV file save directory

; ========================================
; Image Recognition Settings
; ========================================

; Image file paths (must be in same directory as script)
SaveButtonImage := "save.png"      ; Save button screenshot
NextFrameImage := "next.png"       ; Next frame arrow button screenshot

; Image recognition tolerance (0-255, higher value = more tolerance)
ImageTolerance := 30

; Debug mode - set to true to show where images are found (for troubleshooting)
DebugMode := false

; ========================================
; Time Delay Settings (milliseconds)
; ========================================
DelayShort := 300        ; Short delay (interface response)
DelayMedium := 800       ; Medium delay (dialog opening)
DelayLong := 1500        ; Long delay (file saving)

; ========================================
; Function Definitions
; ========================================

; Find image and click
FindAndClick(ImageFile, ErrorMsg := "") {
    global ImageTolerance
    global DebugMode

    ; Ensure we're using Screen coordinates
    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen

    ; Set image recognition tolerance
    if (ImageTolerance > 0)
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%ImageTolerance% %ImageFile%
    else
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %ImageFile%

    if (ErrorLevel = 0) {
        ; Image found, click center position using screen coordinates
        if (DebugMode) {
            ToolTip, Found %ImageFile% at X:%FoundX% Y:%FoundY%, %FoundX%, %FoundY%
            Sleep, 1000
            ToolTip  ; Clear tooltip
        }

        Click, %FoundX%, %FoundY%, 0  ; Move mouse without clicking first
        Sleep, 50
        Click, %FoundX%, %FoundY%     ; Then click
        return true
    } else {
        ; Image not found
        if (ErrorMsg != "") {
            MsgBox, 48, Image Recognition Failed, %ErrorMsg%`n`nPlease ensure:`n1. %ImageFile% file exists in script directory`n2. Button is visible on screen (not minimized/hidden)`n3. Image is clear and matches current display`n4. Try increasing ImageTolerance value`n`nSearching full screen: 0,0 to %A_ScreenWidth%,%A_ScreenHeight%
        }
        return false
    }
}

; ========================================
; Main Program Start
; ========================================

; Check if image files exist
IfNotExist, %SaveButtonImage%
{
    MsgBox, 16, Error, File not found: %SaveButtonImage%`n`nPlease ensure save.png exists in the script directory!
    ExitApp
}

IfNotExist, %NextFrameImage%
{
    MsgBox, 16, Error, File not found: %NextFrameImage%`n`nPlease ensure next.png exists in the script directory!
    ExitApp
}

; Display startup information
MsgBox, 4, FLIR Batch Export Tool v2.0,
(
Prepare to batch export FLIR frame data
Start Frame: %StartFrame%
End Frame: %EndFrame%
Save Path: %SavePath%

Important Notes:
1. Ensure FLIR ResearchIR software is open
2. Ensure Profile window is open
3. Ensure save.png and next.png files are ready
4. Manually navigate to the starting frame first (Frame %StartFrame%)
5. Click "Yes" to start export
6. Press ESC to abort at any time

Using image recognition technology - no coordinate configuration needed!

Start now?
)

IfMsgBox No
{
    ExitApp
}

; Ensure save directory exists
IfNotExist, %SavePath%
{
    MsgBox, 4, Create Directory, Save directory does not exist. Create it?`n%SavePath%
    IfMsgBox Yes
        FileCreateDir, %SavePath%
    else
        ExitApp
}

; Give user 5 seconds to prepare
ProgressStart := A_TickCount
Progress, b w300, Preparing... Starting in 5 seconds, FLIR Batch Export
Loop, 5
{
    Progress, % (6-A_Index)*20, % "Preparing... Starting in " . (6-A_Index) . " seconds"
    Sleep, 1000
}
Progress, Off

; Main loop - process each frame
TotalFrames := EndFrame - StartFrame + 1
CurrentProgress := 0

Loop, %TotalFrames%
{
    CurrentFrame := StartFrame + A_Index - 1
    CurrentProgress := Round((A_Index / TotalFrames) * 100)

    ; Display progress
    Progress, %CurrentProgress%, Processing Frame %CurrentFrame% (%A_Index%/%TotalFrames%), FLIR Batch Export Progress

    ; ======= Step 1: Use image recognition to find and click Save button =======
    if (!FindAndClick(SaveButtonImage, "Cannot find Save button!")) {
        MsgBox, 4, Continue?, Save button recognition failed for Frame %CurrentFrame%. Continue?
        IfMsgBox No
            ExitApp
        continue
    }
    Sleep, %DelayMedium%

    ; ======= Step 2: Use keyboard shortcuts in Save As dialog =======
    ; Use Alt+T to switch to file type dropdown (Save as type)
    Send, !t
    Sleep, %DelayShort%

    ; Select CSV option (use down arrow key)
    Send, {Down}
    Sleep, 200
    Send, {Enter}
    Sleep, %DelayShort%

    ; ======= Step 3: Use keyboard shortcut to enter filename =======
    ; Alt+N usually corresponds to filename input box (File name)
    Send, !n
    Sleep, %DelayShort%

    ; Clear current filename and enter new one
    Send, ^a
    Sleep, 100
    Send, Frame_%CurrentFrame%
    Sleep, %DelayShort%

    ; ======= Step 4: Use Alt+S or Enter to save =======
    ; Try Alt+S (Save button shortcut)
    Send, !s
    Sleep, %DelayLong%

    ; Check for overwrite prompt (if file already exists)
    IfWinExist, Confirm Save As
    {
        Send, {Enter}  ; Confirm overwrite
        Sleep, %DelayMedium%
    }
    IfWinExist, ahk_class #32770  ; Standard Windows dialog
    {
        Send, {Enter}  ; Confirm
        Sleep, %DelayMedium%
    }

    ; ======= Step 5: Use image recognition to click next frame arrow =======
    ; Only switch to next frame if not the last frame
    if (A_Index < TotalFrames)
    {
        if (!FindAndClick(NextFrameImage, "Cannot find next frame button!")) {
            MsgBox, 4, Continue?, Next frame button recognition failed after Frame %CurrentFrame%. Continue?
            IfMsgBox No
                ExitApp
        }
        Sleep, %DelayMedium%
    }
}

; Complete
Progress, Off
MsgBox, 64, Complete, Batch export complete!`n`nExported %TotalFrames% frames`nSave location: %SavePath%

ExitApp

; ========================================
; Hotkey Definitions
; ========================================

; Press ESC to abort program
Esc::
{
    MsgBox, 4, Confirm, Are you sure you want to abort the batch export?
    IfMsgBox Yes
        ExitApp
    return
}

; Press F1 to display help
F1::
{
    MsgBox, 64, Help Information,
    (
    FLIR Batch Export Tool v2.0 - Hotkey Guide

    ESC - Abort program
    F1  - Display this help

    v2.0 New Features:
    - Uses image recognition technology, no manual coordinate configuration
    - Uses keyboard shortcuts for save dialog, more stable and reliable
    - Requires save.png and next.png image files

    Usage Steps:
    1. Capture Save button and save as save.png
    2. Capture next frame arrow button and save as next.png
    3. Modify script configuration (start frame, end frame, save path)
    4. Open FLIR ResearchIR software and Profile window
    5. Manually navigate to starting frame
    6. Run this script

    How It Works:
    - Uses image recognition to find and click Save button
    - Uses keyboard shortcuts for save dialog (Alt+T for type, Alt+N for filename, Alt+S to save)
    - Uses image recognition to find and click next frame arrow
    - Repeats this process until all frames are complete
    )
    return
}
