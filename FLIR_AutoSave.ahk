; ========================================
; FLIR ResearchIR 批量帧数据导出工具 v2.0
; ========================================
; 功能：自动化批量保存FLIR ResearchIR中的帧数据为CSV格式
; 特点：使用图像识别技术，无需手动获取坐标
; ========================================

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Pixel, Screen

; ========================================
; 配置参数 - 请根据实际情况修改
; ========================================

; 帧范围设置
StartFrame := 1          ; 起始帧号
EndFrame := 100          ; 结束帧号

; 保存路径设置（请修改为你的实际保存路径）
SavePath := "C:\FLIR_Export"  ; CSV文件保存目录

; ========================================
; 图像识别设置
; ========================================

; 图像文件路径（必须与脚本在同一目录）
SaveButtonImage := "save.png"      ; Save按钮截图
NextFrameImage := "next.png"       ; 下一帧箭头按钮截图

; 图像识别容差（0-255，数值越大容差越大）
ImageTolerance := 30

; ========================================
; 时间延迟设置（毫秒）
; ========================================
DelayShort := 300        ; 短延迟（界面响应）
DelayMedium := 800       ; 中等延迟（对话框打开）
DelayLong := 1500        ; 长延迟（文件保存）

; ========================================
; 函数定义
; ========================================

; 查找图像并点击
FindAndClick(ImageFile, ErrorMsg := "") {
    global ImageTolerance

    ; 设置图像识别容差
    if (ImageTolerance > 0)
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%ImageTolerance% %ImageFile%
    else
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %ImageFile%

    if (ErrorLevel = 0) {
        ; 找到图像，点击中心位置
        Click, %FoundX%, %FoundY%
        return true
    } else {
        ; 未找到图像
        if (ErrorMsg != "")
            MsgBox, 48, 图像识别失败, %ErrorMsg%`n`n请确保：`n1. %ImageFile% 文件存在`n2. 窗口界面可见`n3. 图像清晰可识别
        return false
    }
}

; ========================================
; 主程序开始
; ========================================

; 检查图像文件是否存在
IfNotExist, %SaveButtonImage%
{
    MsgBox, 16, 错误, 找不到文件: %SaveButtonImage%`n`n请确保save.png文件存在于脚本目录中！
    ExitApp
}

IfNotExist, %NextFrameImage%
{
    MsgBox, 16, 错误, 找不到文件: %NextFrameImage%`n`n请确保next.png文件存在于脚本目录中！
    ExitApp
}

; 显示启动信息
MsgBox, 4, FLIR批量导出工具 v2.0,
(
准备批量导出FLIR帧数据
起始帧: %StartFrame%
结束帧: %EndFrame%
保存路径: %SavePath%

重要提示：
1. 确保FLIR ResearchIR软件已打开
2. 确保Profile窗口已打开
3. 确保save.png和next.png文件已准备好
4. 请先手动切换到起始帧（第%StartFrame%帧）
5. 点击"是"开始导出
6. 按ESC键可随时中止程序

使用图像识别技术，无需配置坐标！

是否开始？
)

IfMsgBox No
{
    ExitApp
}

; 确保保存目录存在
IfNotExist, %SavePath%
{
    MsgBox, 4, 创建目录, 保存目录不存在，是否创建？`n%SavePath%
    IfMsgBox Yes
        FileCreateDir, %SavePath%
    else
        ExitApp
}

; 给用户5秒准备时间
ProgressStart := A_TickCount
Progress, b w300, 准备中... 5秒后开始, FLIR批量导出
Loop, 5
{
    Progress, % (6-A_Index)*20, % "准备中... " . (6-A_Index) . "秒后开始"
    Sleep, 1000
}
Progress, Off

; 主循环 - 处理每一帧
TotalFrames := EndFrame - StartFrame + 1
CurrentProgress := 0

Loop, %TotalFrames%
{
    CurrentFrame := StartFrame + A_Index - 1
    CurrentProgress := Round((A_Index / TotalFrames) * 100)

    ; 显示进度
    Progress, %CurrentProgress%, 正在处理第 %CurrentFrame% 帧 (%A_Index%/%TotalFrames%), FLIR批量导出进度

    ; ======= 步骤1: 使用图像识别查找并点击Save按钮 =======
    if (!FindAndClick(SaveButtonImage, "无法找到Save按钮！")) {
        MsgBox, 4, 继续?, 第 %CurrentFrame% 帧的Save按钮识别失败，是否继续？
        IfMsgBox No
            ExitApp
        continue
    }
    Sleep, %DelayMedium%

    ; ======= 步骤2: 在Save As对话框中使用快捷键操作 =======
    ; 使用Alt+T切换到文件类型下拉框（Save as type）
    Send, !t
    Sleep, %DelayShort%

    ; 选择CSV选项（向下键选择）
    Send, {Down}
    Sleep, 200
    Send, {Enter}
    Sleep, %DelayShort%

    ; ======= 步骤3: 使用快捷键输入文件名 =======
    ; Alt+N 通常对应文件名输入框（File name）
    Send, !n
    Sleep, %DelayShort%

    ; 清除当前文件名并输入新的
    Send, ^a
    Sleep, 100
    Send, Frame_%CurrentFrame%
    Sleep, %DelayShort%

    ; ======= 步骤4: 使用Alt+S或Enter保存 =======
    ; 尝试Alt+S（Save按钮的快捷键）
    Send, !s
    Sleep, %DelayLong%

    ; 检查是否有覆盖提示（如果文件已存在）
    IfWinExist, Confirm Save As
    {
        Send, {Enter}  ; 确认覆盖
        Sleep, %DelayMedium%
    }
    IfWinExist, ahk_class #32770  ; 标准Windows对话框
    {
        Send, {Enter}  ; 确认
        Sleep, %DelayMedium%
    }

    ; ======= 步骤5: 使用图像识别点击下一帧箭头 =======
    ; 只有在不是最后一帧时才切换到下一帧
    if (A_Index < TotalFrames)
    {
        if (!FindAndClick(NextFrameImage, "无法找到下一帧按钮！")) {
            MsgBox, 4, 继续?, 第 %CurrentFrame% 帧后的下一帧按钮识别失败，是否继续？
            IfMsgBox No
                ExitApp
        }
        Sleep, %DelayMedium%
    }
}

; 完成
Progress, Off
MsgBox, 64, 完成, 批量导出完成！`n`n已导出 %TotalFrames% 个帧`n保存位置: %SavePath%

ExitApp

; ========================================
; 快捷键定义
; ========================================

; 按ESC键中止程序
Esc::
{
    MsgBox, 4, 确认, 确定要中止批量导出吗？
    IfMsgBox Yes
        ExitApp
    return
}

; 按F1显示帮助
F1::
{
    MsgBox, 64, 帮助信息,
    (
    FLIR批量导出工具 v2.0 - 快捷键说明

    ESC - 中止程序
    F1  - 显示此帮助

    v2.0 新特性：
    - 使用图像识别技术，无需手动配置坐标
    - 使用快捷键操作保存对话框，更稳定可靠
    - 需要准备save.png和next.png图像文件

    使用步骤：
    1. 截取Save按钮保存为save.png
    2. 截取下一帧箭头按钮保存为next.png
    3. 修改脚本配置参数（起始帧、结束帧、保存路径）
    4. 打开FLIR ResearchIR软件和Profile窗口
    5. 手动切换到起始帧
    6. 运行此脚本

    工作原理：
    - 使用图像识别查找并点击Save按钮
    - 使用快捷键操作保存对话框（Alt+T选择类型，Alt+N输入文件名，Alt+S保存）
    - 使用图像识别查找并点击下一帧箭头
    - 重复此过程直到完成所有帧
    )
    return
}
