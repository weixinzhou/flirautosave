; ========================================
; Test Image Search - FLIR AutoSave Helper
; ========================================
; Function: Test if save.png and next.png can be found on screen
; This helps diagnose image recognition issues
; ========================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Set all coordinate modes to Screen
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

; Configuration
ImageTolerance := 30  ; Start with 30, can increase if not found

; Display instructions
MsgBox, 64, Test Image Search - Instructions,
(
This tool will test if image recognition can find the buttons.

Before running:
1. Open FLIR ResearchIR software
2. Open Profile window
3. Make sure both buttons are visible on screen

The test will:
1. Try to find save.png
2. Move mouse to show where it was found
3. Try to find next.png
4. Move mouse to show where it was found

Press OK to start the test.
)

; Test save.png
MsgBox, 64, Test 1/2, Testing save.png...`n`nMake sure the Save button is visible in the Profile window.`n`nPress OK to search for save.png

TestImage("save.png", "Save Button")

; Test next.png
MsgBox, 64, Test 2/2, Testing next.png...`n`nMake sure the next frame arrow is visible at the bottom.`n`nPress OK to search for next.png

TestImage("next.png", "Next Frame Arrow")

; All tests complete
MsgBox, 64, Test Complete, All tests completed!`n`nIf both images were found, the script should work.`nIf not, try:`n- Increasing ImageTolerance`n- Re-capturing the images`n- Checking display scaling

ExitApp

; Function to test image search
TestImage(ImageFile, ButtonName) {
    global ImageTolerance

    ; Check if file exists
    IfNotExist, %ImageFile%
    {
        MsgBox, 16, File Not Found, Image file not found: %ImageFile%`n`nCurrent directory: %A_ScriptDir%`n`nPlease ensure %ImageFile% is in the script directory.
        return
    }

    ; Search for image
    MsgBox, 64, Searching..., Searching for %ImageFile%...`n`nScreen resolution: %A_ScreenWidth% x %A_ScreenHeight%`nTolerance: %ImageTolerance%`n`nSearching entire screen...

    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%ImageTolerance% %ImageFile%

    if (ErrorLevel = 0) {
        ; Image found!
        MsgBox, 64, Image Found!, SUCCESS!`n`n%ButtonName% found!`n`nImage: %ImageFile%`nCoordinates:`n  X: %FoundX%`n  Y: %FoundY%`n`nScreen: %A_ScreenWidth% x %A_ScreenHeight%`n`nThe mouse will now move to this position...

        ; Move mouse slowly to show where it was found
        MouseMove, %FoundX%, %FoundY%, 20

        ; Draw a box around the found location
        ToolTip, FOUND HERE!`n%ButtonName%`nX:%FoundX% Y:%FoundY%, %FoundX%, %FoundY%

        ; Keep tooltip visible
        MsgBox, 64, Verify Position, The mouse is now at the found position.`n`nX: %FoundX%`nY: %FoundY%`n`nIs this the correct %ButtonName%?`n`nThe tooltip shows where it was found.

        ToolTip  ; Clear tooltip

    } else {
        ; Image not found
        MsgBox, 48, Image NOT Found, FAILED!`n`n%ButtonName% was NOT found!`n`nImage: %ImageFile%`nFile exists: Yes`n`nScreen: %A_ScreenWidth% x %A_ScreenHeight%`nSearch area: 0,0 to %A_ScreenWidth%,%A_ScreenHeight%`nTolerance: %ImageTolerance%`n`nPossible solutions:`n`n1. Increase tolerance:`n   Change ImageTolerance := 30`n   to ImageTolerance := 100`n`n2. Re-capture image:`n   - Ensure button is visible`n   - Capture at actual size`n   - Save as PNG format`n`n3. Check display scaling:`n   - Windows display settings`n   - May need to capture at scaled size

        ; Offer to test with higher tolerance
        MsgBox, 4, Try Higher Tolerance?, Image not found with tolerance %ImageTolerance%.`n`nTry again with tolerance 100?

        IfMsgBox Yes
        {
            MsgBox, 64, Retrying..., Searching with tolerance 100...

            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %ImageFile%

            if (ErrorLevel = 0) {
                MsgBox, 64, Found with Higher Tolerance!, SUCCESS with tolerance 100!`n`n%ButtonName% found!`n`nCoordinates:`n  X: %FoundX%`n  Y: %FoundY%`n`nRECOMMENDATION:`nSet ImageTolerance := 100 in FLIR_AutoSave.ahk

                MouseMove, %FoundX%, %FoundY%, 20
                ToolTip, FOUND HERE!`n%ButtonName%`nX:%FoundX% Y:%FoundY%, %FoundX%, %FoundY%

                MsgBox, 64, Verify Position, Mouse moved to found position.`n`nIs this correct?

                ToolTip
            } else {
                MsgBox, 16, Still Not Found, Still not found even with tolerance 100.`n`nPlease:`n1. Ensure %ButtonName% is visible on screen`n2. Re-capture the image`n3. Check if button appearance matches captured image
            }
        }
    }
}
