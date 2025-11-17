# FLIR ResearchIR Batch Frame Data Export Tool v2.0

## Introduction

This is an AutoHotkey script tool for automating batch export of frame data from FLIR ResearchIR 4 software. Since FLIR ResearchIR software does not provide a batch export feature and requires manually saving data frame by frame, this tool automates this repetitive process.

## v2.0 New Features ⭐

- **Image Recognition Technology**: No manual coordinate configuration needed, uses image recognition to automatically find buttons
- **Keyboard Shortcuts**: Save dialog uses keyboard shortcuts for more stable and reliable operation
- **Better Adaptability**: Adapts to different resolutions and window positions
- **Simplified Configuration**: Only need to capture two button images

## Features

- Automate batch export of specified frame range data
- Support export to CSV format (X and Y values)
- Customizable frame range (start frame and end frame)
- Customizable save path
- **Uses image recognition, no coordinate configuration needed**
- **Uses keyboard shortcuts for save dialog**
- Real-time progress display
- Support cancellation mid-process (ESC key)

## File Description

- `FLIR_AutoSave.ahk` - Main script, executes batch export task (v2.0 uses image recognition)
- `ImageCapture.ahk` - Image capture helper tool (newly added)
- `CoordinateFinder.ahk` - Coordinate acquisition tool (used by v1.x, not needed for v2.0)
- `save.png` - Save button screenshot (user needs to capture)
- `next.png` - Next frame arrow button screenshot (user needs to capture)
- `1.jpg`, `2.jpg`, `3.jpg` - Operation process screenshot reference
- `README.md` - This documentation

## System Requirements

- Windows Operating System
- FLIR ResearchIR 4 software
- AutoHotkey v1.1 or higher ([Download](https://www.autohotkey.com/))

## Installation Steps

1. Download and install AutoHotkey: https://www.autohotkey.com/
2. Download all project files to the same folder

## Usage Steps

### Step 1: Capture Button Images

Use Windows Snipping Tool to capture two button images:

**Method 1: Use Windows Snipping Tool (Recommended)**

1. Open FLIR ResearchIR software and Profile window
2. Press `Win+Shift+S` to open Windows Snipping Tool (Windows 10/11)
3. Select rectangular snip mode

4. **Capture Save Button**:
   - Precisely select the "Save" button in upper right corner of Profile window
   - Open Paint (press Win+R, type mspaint, press Enter)
   - Press Ctrl+V to paste
   - File → Save As → PNG Picture
   - Filename: `save.png`
   - Save to script folder

5. **Capture Next Frame Arrow**:
   - Press `Win+Shift+S` to reopen Snipping Tool
   - Select the "next frame" right arrow button in bottom timeline
   - Open Paint, paste
   - Save as `next.png` (save to script folder)

**Method 2: Use ImageCapture Tool**

1. Double-click to run `ImageCapture.ahk`
2. Follow the interface prompts
3. Use the tool's instructions to capture images

**Capture Tips**:
- Ensure button is in normal state when capturing (not highlighted/pressed)
- Try to select precisely, only include button itself
- Recommended image size: 30-80 pixels
- Ensure image is clear

### Step 2: Configure Script Parameters

1. Right-click `FLIR_AutoSave.ahk`, select "Edit Script"
2. Find "Configuration Parameters" section, modify the following settings:

   ```ahk
   ; Frame range settings
   StartFrame := 1          ; Starting frame number (change to your start frame)
   EndFrame := 100          ; Ending frame number (change to your end frame)

   ; Save path settings
   SavePath := "C:\FLIR_Export"  ; CSV file save directory (change to your save path)
   ```

3. (Optional) Adjust image recognition tolerance:
   ```ahk
   ImageTolerance := 30     ; If recognition fails, can increase appropriately (0-255)
   ```

4. (Optional) Enable debug mode to see where images are found:
   ```ahk
   DebugMode := true        ; Shows tooltip when image is found (for troubleshooting)
   ```

5. Save script (Ctrl+S)

### Step 3: Run Batch Export

1. Ensure FLIR ResearchIR software is open
2. Ensure Profile window is open
3. Confirm `save.png` and `next.png` are ready
4. **Important: Manually navigate to the starting frame** (e.g., if StartFrame is set to 1, navigate to Frame 1 first)
5. Double-click to run `FLIR_AutoSave.ahk`
6. Click "Yes" in the confirmation dialog
7. Wait 5 seconds for preparation time
8. Script will automatically start batch export
9. Can press `ESC` key to abort at any time

## How It Works

The script automatically repeats the following steps:

1. **Image recognition to find Save button** - Searches entire screen for save.png image and clicks it
2. **Uses keyboard shortcuts for save dialog**:
   - `Alt+T` - Switch to file type dropdown
   - `↓` + `Enter` - Select CSV format
   - `Alt+N` - Switch to filename input box
   - Enter "Frame_[frame number]"
   - `Alt+S` - Click save button
3. **Wait for file save to complete**
4. **Image recognition to find next frame arrow** - Find next.png image and click it
5. Repeat above steps until all frames are complete

**v2.0 Advantages**:
- Image recognition: Automatically adapts to different window positions and resolutions
- Keyboard shortcuts: More stable and reliable than clicking coordinates
- No configuration needed: Only need to capture two images

## Hotkey Guide

### FLIR_AutoSave.ahk (Main Script)
- `ESC` - Abort batch export
- `F1` - Display help information

### ImageCapture.ahk (Image Capture Tool)
- `Ctrl+1` - View save.png capture instructions
- `Ctrl+2` - View next.png capture instructions
- `ESC` - Exit program

### CoordinateFinder.ahk (v1.x legacy tool, not needed for v2.0)
- `Ctrl+Shift+C` - Save current mouse position coordinates
- `F1` - View all saved coordinates and copy code
- `F2` - Clear all saved coordinates
- `F3` - Display help information
- `ESC` - Exit program

## FAQ

### 1. Image recognition failed, cannot find button?
- **Check image files**: Ensure save.png and next.png files exist in script directory
- **Enable debug mode**: Set `DebugMode := true` in script to see if images are found
- **Increase tolerance**: Set `ImageTolerance := 100` (or even higher, up to 255) for more lenient matching
- **Re-capture images**: Use clearer, more precise screenshots
  - Capture when button is in normal state (not highlighted or pressed)
  - Capture at actual size (don't resize)
  - Save as PNG format (not JPG)
- **Check window visibility**: Ensure button is fully visible, not blocked by other windows
- **Check display scaling**: If using Windows display scaling (125%, 150%), try capturing images at that scale
- **Try larger capture**: Capture a slightly larger area including some background around the button

### 2. Save dialog keyboard shortcuts not working?
- **Verify shortcuts**: Different Windows or FLIR software versions may have different shortcuts
- **Manual test**: Open save dialog, manually test if Alt+T, Alt+N, Alt+S work
- **Modify script**: If shortcuts are different, can modify corresponding Send commands in script
- **Use Tab key**: Can try using Tab key navigation instead of Alt shortcuts

### 3. Script not responding after running?
- Check if AutoHotkey is installed correctly
- Ensure FLIR software and Profile window are open
- Check if save.png and next.png files exist
- Check if there are error prompt dialogs

### 4. Files not saved to specified location?
- Check if SavePath is correct
- Ensure path exists and has write permissions
- Check if correct backslash is used in path (Windows uses backslash \)

### 5. Save speed too fast or too slow?
- Can adjust delay parameters in script:
  ```ahk
  DelayShort := 300        ; Short delay (interface response)
  DelayMedium := 800       ; Medium delay (dialog opening)
  DelayLong := 1500        ; Long delay (file saving)
  ```

### 6. Some frames failed to save?
- Increase delay time to give software more response time
- Check if disk space is sufficient
- Check if frame number is within valid range
- Check if there are error prompts, script will ask whether to continue

### 7. How to get better screenshots?
- Use Windows built-in Snipping Tool (Win+Shift+S)
- Only include button itself when capturing, don't include too much background
- Ensure screenshot is clear, not blurry
- Recommended image size: 30-80 pixels
- Button should be in normal state when capturing (not activated)

## Important Notes

1. **Must prepare image files**: Ensure save.png and next.png exist in script directory before running
2. **Must manually navigate to starting frame before running**: Script starts from current frame, exports frame by frame by clicking right arrow
3. **Do not move mouse or operate computer during execution**: Otherwise may interfere with script execution
4. **Must test before first use**: Recommend setting small range (e.g., 1-5 frames) to test if normal
5. **Image quality is important**: Screenshots must be clear, only include button itself
6. **Backup important data**: Although script does not modify original data, recommend backing up
7. **Ensure frame range is correct**: If current frame number plus frames to export exceeds total video frames, may cause errors
8. **Do not minimize windows**: Ensure FLIR window and buttons are visible
9. **Test shortcuts**: Manually test if save dialog shortcuts work before first use

## Technical Support

For issues or suggestions, please submit an Issue on GitHub.

## License

This project is licensed under the MIT License and can be freely used and modified.

## Changelog

### v2.0 (2025-11-17)
- **Major Update**: Uses image recognition technology, no manual coordinate configuration needed
- **Added**: Uses keyboard shortcuts for save dialog, more stable and reliable
- **Added**: ImageCapture.ahk image capture helper tool
- **Improved**: Automatically adapts to different resolutions and window positions
- **Simplified**: Only need to capture two button images
- **Optimized**: Added image file checking and detailed error prompts
- **Optimized**: Improved error handling, asks whether to continue if recognition fails

### v1.1 (2025-11-17)
- Improved: Uses right arrow button to switch frames, replacing frame number input method
- Simplified operation process, improved stability
- User needs to manually navigate to starting frame before running
- Updated usage instructions and operating principles

### v1.0 (2025-11-17)
- Initial version release
- Support batch export of frame data to CSV format
- Includes coordinate acquisition helper tool (CoordinateFinder.ahk)
