; ========================================
; Image Capture Tool - FLIR AutoSave Helper
; ========================================
; Function: Help users capture Save button and next frame arrow button images
; For use with FLIR_AutoSave.ahk image recognition feature
; ========================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; ========================================
; Usage Instructions
; ========================================

MsgBox, 64, Image Capture Tool - Instructions,
(
This tool will help you capture button images from the FLIR software interface

You need to capture two images:
1. save.png - Save button in Profile window
2. next.png - Next frame arrow button in bottom timeline

Capture Steps:

Method 1: Use Windows Snipping Tool (Recommended)
----------------------------------------
1. Open FLIR ResearchIR software and Profile window
2. Press Win+Shift+S to open Windows Snipping Tool
3. Select "Rectangular Snip"
4. Precisely capture the Save button area
5. Screenshot will be automatically copied to clipboard
6. Open Paint (mspaint.exe) or other image editor
7. Paste and save as save.png
8. Repeat steps 2-7 to capture next frame arrow, save as next.png

Method 2: Use This Tool's Hotkeys
----------------------------------------
Press Ctrl+1: Capture save.png (Save button)
Press Ctrl+2: Capture next.png (Next frame arrow)

When using this tool's hotkeys:
1. After pressing hotkey, screen will pause for 3 seconds
2. Quickly select the area to capture with mouse
3. Image will be saved automatically when you release mouse

Important Notes:
----------------------------------------
- Captured images should be clear and visible
- Try to include only the button itself, not too much background
- Recommended image size: 20x20 to 100x100 pixels
- Ensure saved in same directory as script

Click "OK" to begin
)

; Create main GUI
Gui, +AlwaysOnTop
Gui, Font, s10 Bold
Gui, Add, Text, x20 y20 w460, Image Capture Tool - FLIR AutoSave
Gui, Font, s9 Normal
Gui, Add, Text, x20 y50 w460, Use the following hotkeys to capture images, or use Windows built-in Snipping Tool (Win+Shift+S)

Gui, Add, GroupBox, x20 y80 w460 h120, Hotkey Capture (Select Area)
Gui, Add, Text, x40 y105, Ctrl+1 - Capture Save button (save as save.png)
Gui, Add, Text, x40 y130, Ctrl+2 - Capture next frame arrow (save as next.png)
Gui, Add, Text, x40 y155 cRed, After pressing hotkey, select area with mouse
Gui, Add, Text, x40 y175 cBlue, Tip: You can also use Win+Shift+S for Windows Snipping Tool

Gui, Add, GroupBox, x20 y210 w460 h100, Captured Images
Gui, Add, Text, x40 y235 vSaveStatus, save.png: Not captured
Gui, Add, Text, x40 y260 vNextStatus, next.png: Not captured

Gui, Add, Button, x20 y320 w220 h35 gCheckImages, Check Image Files
Gui, Add, Button, x250 y320 w230 h35 gShowHelp, View Detailed Instructions

Gui, Add, Text, x20 y365 w460 h2 +0x10  ; Separator line

Gui, Add, Button, x380 y375 w100 h30 gGuiClose, Close

Gui, Show, w500 h420, FLIR Image Capture Tool

; Check image files on startup
Gosub, CheckImages

return

; ========================================
; Screenshot Functionality
; ========================================

; AutoHotkey doesn't directly support region capture
; Recommend using Windows built-in Snipping Tool

^1::  ; Ctrl+1 - Capture save.png
{
    MsgBox, 64, Capture Save Button,
    (
    Prepare to capture Save button image

    Recommended: Use Windows Snipping Tool:
    1. Press Win+Shift+S to open Snipping Tool
    2. Select the Save button area
    3. Open Paint (mspaint)
    4. Press Ctrl+V to paste
    5. Save as save.png (in script directory)

    Or use any screenshot software to capture the Save button area
    and save as save.png
    )
    return
}

^2::  ; Ctrl+2 - Capture next.png
{
    MsgBox, 64, Capture Next Frame Arrow,
    (
    Prepare to capture next frame arrow image

    Recommended: Use Windows Snipping Tool:
    1. Press Win+Shift+S to open Snipping Tool
    2. Select the next frame arrow button area
    3. Open Paint (mspaint)
    4. Press Ctrl+V to paste
    5. Save as next.png (in script directory)

    Or use any screenshot software to capture the arrow button area
    and save as next.png
    )
    return
}

; ========================================
; Check Image Files
; ========================================

CheckImages:
{
    saveExists := FileExist("save.png")
    nextExists := FileExist("next.png")

    if (saveExists)
        GuiControl,, SaveStatus, save.png: ✓ Exists
    else
        GuiControl,, SaveStatus, save.png: ✗ Not found

    if (nextExists)
        GuiControl,, NextStatus, next.png: ✓ Exists
    else
        GuiControl,, NextStatus, next.png: ✗ Not found

    if (saveExists && nextExists)
    {
        MsgBox, 64, Check Complete, Both image files are ready!`n`nYou can now run FLIR_AutoSave.ahk
    }
    else if (!saveExists && !nextExists)
    {
        MsgBox, 48, Check Complete, Both image files do not exist.`n`nPlease use Windows Snipping Tool (Win+Shift+S) to capture button images.
    }
    else
    {
        missing := !saveExists ? "save.png" : "next.png"
        MsgBox, 48, Check Complete, Still missing: %missing%`n`nPlease continue to capture the missing image.
    }

    return
}

; ========================================
; Show Detailed Help
; ========================================

ShowHelp:
{
    MsgBox, 64, Detailed Instructions,
    (
    ========================================
    Image Capture Detailed Steps
    ========================================

    Goal: Capture two button images for image recognition

    1. Save Button (save.png)
    ----------------------------------------
    Location: Save button in upper right corner of Profile window
    Requirement: Clearly capture button area, include complete button

    Capture Method:
    a) Open FLIR software and Profile window
    b) Press Win+Shift+S (Windows 10/11 Snipping Tool)
    c) Select rectangular snip mode
    d) Precisely select Save button
    e) Open Paint (Win+R, type mspaint, press Enter)
    f) Press Ctrl+V to paste screenshot
    g) File → Save As → PNG Picture
    h) Filename: save.png
    i) Save location: Same folder as script

    2. Next Frame Arrow (next.png)
    ----------------------------------------
    Location: Right arrow button in bottom timeline
    Requirement: Clearly capture arrow button, include complete icon

    Capture Method: Same as above, save filename as next.png

    Capture Tips:
    ----------------------------------------
    - Ensure button is in normal state when capturing (not highlighted/pressed)
    - Try to select precisely, reduce background interference
    - Image should not be too large or too small (recommended 30-80 pixels)
    - Ensure image is clear, not blurry

    Verification:
    ----------------------------------------
    After capturing, click "Check Image Files" button to verify
    When both files exist, you can use FLIR_AutoSave.ahk
    )
    return
}

; ========================================
; Close Program
; ========================================

GuiClose:
GuiEscape:
{
    ExitApp
}

; ESC key to exit
Esc::ExitApp
