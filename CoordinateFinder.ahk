; ========================================
; 坐标获取工具 - FLIR AutoSave辅助工具
; ========================================
; 功能：帮助获取屏幕上各个控件的精确坐标
; 使用方法：
;   1. 运行此脚本
;   2. 将鼠标移动到需要点击的位置
;   3. 按Ctrl+Shift+C复制当前鼠标坐标
;   4. 按F1查看所有已保存的坐标
;   5. 按F2清除已保存的坐标
; ========================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; 全局变量
CoordList := []
CoordCount := 0

; 创建GUI显示当前坐标
Gui, +AlwaysOnTop +ToolWindow
Gui, Font, s10, Consolas
Gui, Add, Text, x10 y10 w400, 坐标获取工具 - 实时显示鼠标位置
Gui, Add, Text, x10 y35 w400 vCoordText, X: 0, Y: 0
Gui, Add, Text, x10 y60 w400, 快捷键：Ctrl+Shift+C 保存坐标 | F1 查看已保存 | F2 清除
Gui, Show, w420 h90, FLIR坐标获取工具

; 设置定时器实时更新坐标
SetTimer, UpdateCoords, 50
return

; 更新坐标显示
UpdateCoords:
    MouseGetPos, xpos, ypos
    GuiControl,, CoordText, X: %xpos%, Y: %ypos%
    return

; ========================================
; 快捷键定义
; ========================================

; Ctrl+Shift+C - 保存当前坐标
^+c::
{
    MouseGetPos, xpos, ypos
    CoordCount++

    ; 询问坐标名称
    InputBox, CoordName, 坐标名称, 请输入此坐标的名称（例如：帧输入框、Save按钮等）:, , 400, 150
    if ErrorLevel
        return

    if (CoordName = "")
        CoordName := "坐标" . CoordCount

    ; 保存到数组
    CoordList.Push({name: CoordName, x: xpos, y: ypos})

    ; 复制到剪贴板
    Clipboard := CoordName . "X := " . xpos . "`n" . CoordName . "Y := " . ypos

    ; 显示提示
    ToolTip, 已保存: %CoordName%`nX: %xpos%, Y: %ypos%`n(已复制到剪贴板), %xpos%, %ypos%
    SetTimer, RemoveToolTip, 2000

    ; 播放提示音
    SoundBeep, 750, 100

    return
}

; F1 - 显示所有已保存的坐标
F1::
{
    if (CoordList.Length() = 0)
    {
        MsgBox, 48, 坐标列表, 还没有保存任何坐标！`n`n使用 Ctrl+Shift+C 保存当前鼠标位置的坐标
        return
    }

    ; 构建坐标列表文本
    CoordText := "已保存的坐标：`n`n"
    CoordCode := "; ========================================`n"
    CoordCode .= "; 复制以下代码到FLIR_AutoSave.ahk中`n"
    CoordCode .= "; ========================================`n`n"

    for index, coord in CoordList
    {
        CoordText .= index . ". " . coord.name . "`n   X: " . coord.x . ", Y: " . coord.y . "`n`n"

        ; 生成代码格式
        varName := RegExReplace(coord.name, "\s+", "")
        CoordCode .= varName . "X := " . coord.x . "      ; " . coord.name . " X坐标`n"
        CoordCode .= varName . "Y := " . coord.y . "      ; " . coord.name . " Y坐标`n`n"
    }

    ; 显示列表
    MsgBox, 64, 已保存的坐标, %CoordText%

    ; 复制代码到剪贴板
    Clipboard := CoordCode
    TrayTip, 坐标代码已复制, 坐标代码已复制到剪贴板，可以直接粘贴到脚本中, 3, 1

    return
}

; F2 - 清除所有已保存的坐标
F2::
{
    MsgBox, 4, 确认清除, 确定要清除所有已保存的坐标吗？
    IfMsgBox Yes
    {
        CoordList := []
        CoordCount := 0
        MsgBox, 64, 已清除, 所有坐标已清除！
    }
    return
}

; F3 - 显示帮助
F3::
{
    HelpText =
    (
    ========================================
    FLIR坐标获取工具 - 使用说明
    ========================================

    用途：
    获取FLIR ResearchIR软件界面上各个控件的屏幕坐标

    操作步骤：

    1. 打开FLIR ResearchIR软件

    2. 打开Profile窗口（显示温度曲线的窗口）

    3. 运行此坐标获取工具

    4. 按照以下顺序获取坐标：
       a) 将鼠标移到底部帧序号显示区域中心
          按 Ctrl+Shift+C，输入名称"帧输入框"

       b) 将鼠标移到Profile窗口的Save按钮
          按 Ctrl+Shift+C，输入名称"Save按钮"

       c) 点击一次Save按钮打开保存对话框

       d) 将鼠标移到文件名输入框
          按 Ctrl+Shift+C，输入名称"文件名输入框"

       e) 将鼠标移到"Save as type"下拉框
          按 Ctrl+Shift+C，输入名称"文件类型下拉框"

       f) 将鼠标移到最终的Save按钮
          按 Ctrl+Shift+C，输入名称"最终Save按钮"

    5. 按 F1 查看所有坐标并复制代码

    6. 将复制的代码粘贴到FLIR_AutoSave.ahk中

    快捷键：
    Ctrl+Shift+C - 保存当前鼠标位置坐标
    F1 - 查看所有已保存坐标并复制代码
    F2 - 清除所有已保存坐标
    F3 - 显示此帮助
    ESC - 退出程序
    )

    MsgBox, 64, 使用说明, %HelpText%
    return
}

; ESC - 退出
Esc::
{
    MsgBox, 4, 退出确认, 确定要退出坐标获取工具吗？
    IfMsgBox Yes
        ExitApp
    return
}

; 移除提示
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return

; 关闭GUI时退出
GuiClose:
    ExitApp
    return
