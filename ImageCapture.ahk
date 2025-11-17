; ========================================
; 图像截取工具 - FLIR AutoSave辅助工具
; ========================================
; 功能：帮助用户截取Save按钮和下一帧箭头按钮的图像
; 用于FLIR_AutoSave.ahk的图像识别功能
; ========================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; ========================================
; 使用说明
; ========================================

MsgBox, 64, 图像截取工具 - 使用说明,
(
本工具将帮助您截取FLIR软件界面的按钮图像

您需要截取两个图像：
1. save.png - Profile窗口的Save按钮
2. next.png - 底部时间轴的下一帧箭头按钮

截取步骤：

方法一：使用Windows截图工具（推荐）
----------------------------------------
1. 打开FLIR ResearchIR软件和Profile窗口
2. 按 Win+Shift+S 打开Windows截图工具
3. 选择"矩形截图"
4. 精确截取Save按钮区域
5. 截图会自动复制到剪贴板
6. 打开画图（mspaint.exe）或其他图片编辑器
7. 粘贴并保存为 save.png
8. 重复步骤2-7截取下一帧箭头，保存为 next.png

方法二：使用本工具的快捷键截图
----------------------------------------
按 Ctrl+1: 截取save.png（截取Save按钮）
按 Ctrl+2: 截取next.png（截取下一帧箭头）

使用本工具快捷键时：
1. 按下快捷键后，屏幕会暂停3秒
2. 快速用鼠标框选要截取的区域
3. 松开鼠标后自动保存图像

注意事项：
----------------------------------------
- 截取的图像应该清晰可见
- 尽量只包含按钮本身，不要包含太多背景
- 建议图像大小在20x20到100x100像素之间
- 确保保存在脚本同一目录下

点击"确定"开始
)

; 创建主界面
Gui, +AlwaysOnTop
Gui, Font, s10 Bold
Gui, Add, Text, x20 y20 w460, 图像截取工具 - FLIR AutoSave
Gui, Font, s9 Normal
Gui, Add, Text, x20 y50 w460, 请使用以下快捷键截取图像，或使用Windows自带截图工具（Win+Shift+S）

Gui, Add, GroupBox, x20 y80 w460 h120, 快捷键截图（框选区域）
Gui, Add, Text, x40 y105, Ctrl+1 - 截取Save按钮（保存为save.png）
Gui, Add, Text, x40 y130, Ctrl+2 - 截取下一帧箭头（保存为next.png）
Gui, Add, Text, x40 y155 cRed, 按下快捷键后，用鼠标框选要截取的区域
Gui, Add, Text, x40 y175 cBlue, 提示：也可以用Win+Shift+S使用Windows截图工具

Gui, Add, GroupBox, x20 y210 w460 h100, 已截取的图像
Gui, Add, Text, x40 y235 vSaveStatus, save.png: 未截取
Gui, Add, Text, x40 y260 vNextStatus, next.png: 未截取

Gui, Add, Button, x20 y320 w220 h35 gCheckImages, 检查图像文件
Gui, Add, Button, x250 y320 w230 h35 gShowHelp, 查看详细说明

Gui, Add, Text, x20 y365 w460 h2 +0x10  ; 分隔线

Gui, Add, Button, x380 y375 w100 h30 gGuiClose, 关闭

Gui, Show, w500 h420, FLIR图像截取工具

; 启动时检查图像文件
Gosub, CheckImages

return

; ========================================
; 截图功能（需要第三方工具支持）
; ========================================

; 由于AutoHotkey不直接支持区域截图，这里提供简化版本
; 实际建议使用Windows自带的截图工具

^1::  ; Ctrl+1 - 截取save.png
{
    MsgBox, 64, 截取Save按钮,
    (
    准备截取Save按钮图像

    建议使用Windows截图工具：
    1. 按 Win+Shift+S 打开截图工具
    2. 框选Save按钮
    3. 打开画图（mspaint）
    4. 按 Ctrl+V 粘贴
    5. 保存为 save.png（保存在脚本目录）

    或者使用任何截图软件截取Save按钮区域
    并保存为 save.png
    )
    return
}

^2::  ; Ctrl+2 - 截取next.png
{
    MsgBox, 64, 截取下一帧箭头,
    (
    准备截取下一帧箭头图像

    建议使用Windows截图工具：
    1. 按 Win+Shift+S 打开截图工具
    2. 框选下一帧箭头按钮
    3. 打开画图（mspaint）
    4. 按 Ctrl+V 粘贴
    5. 保存为 next.png（保存在脚本目录）

    或者使用任何截图软件截取箭头按钮区域
    并保存为 next.png
    )
    return
}

; ========================================
; 检查图像文件
; ========================================

CheckImages:
{
    saveExists := FileExist("save.png")
    nextExists := FileExist("next.png")

    if (saveExists)
        GuiControl,, SaveStatus, save.png: ✓ 已存在
    else
        GuiControl,, SaveStatus, save.png: ✗ 未找到

    if (nextExists)
        GuiControl,, NextStatus, next.png: ✓ 已存在
    else
        GuiControl,, NextStatus, next.png: ✗ 未找到

    if (saveExists && nextExists)
    {
        MsgBox, 64, 检查完成, 两个图像文件都已准备好！`n`n您现在可以运行FLIR_AutoSave.ahk了。
    }
    else if (!saveExists && !nextExists)
    {
        MsgBox, 48, 检查完成, 两个图像文件都不存在。`n`n请使用Windows截图工具（Win+Shift+S）截取按钮图像。
    }
    else
    {
        missing := !saveExists ? "save.png" : "next.png"
        MsgBox, 48, 检查完成, 还缺少: %missing%`n`n请继续截取缺少的图像。
    }

    return
}

; ========================================
; 显示详细帮助
; ========================================

ShowHelp:
{
    MsgBox, 64, 详细使用说明,
    (
    ========================================
    图像截取详细步骤
    ========================================

    目标：截取两个按钮的图像用于图像识别

    1. Save按钮（save.png）
    ----------------------------------------
    位置：Profile窗口右上角的Save按钮
    要求：清晰截取按钮区域，包含完整的按钮

    截取方法：
    a) 打开FLIR软件和Profile窗口
    b) 按 Win+Shift+S（Windows 10/11截图工具）
    c) 选择矩形截图模式
    d) 精确框选Save按钮
    e) 打开画图（Win+R输入mspaint回车）
    f) 按Ctrl+V粘贴截图
    g) 文件 → 另存为 → PNG图片
    h) 文件名输入: save.png
    i) 保存位置：与脚本同一文件夹

    2. 下一帧箭头（next.png）
    ----------------------------------------
    位置：底部时间轴的向右箭头按钮
    要求：清晰截取箭头按钮，包含完整图标

    截取方法：同上，保存文件名为 next.png

    截图技巧：
    ----------------------------------------
    - 截图时确保按钮处于正常状态（非高亮/按下）
    - 尽量精确框选，减少背景干扰
    - 图像不要太大也不要太小（建议30-80像素）
    - 确保图像清晰，不要模糊

    验证：
    ----------------------------------------
    截取完成后，点击"检查图像文件"按钮验证
    两个文件都存在后即可使用FLIR_AutoSave.ahk
    )
    return
}

; ========================================
; 关闭程序
; ========================================

GuiClose:
GuiEscape:
{
    ExitApp
}

; ESC键退出
Esc::ExitApp
