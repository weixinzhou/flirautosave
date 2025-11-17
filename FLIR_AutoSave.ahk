; ========================================
; FLIR ResearchIR 批量帧数据导出工具
; ========================================
; 功能：自动化批量保存FLIR ResearchIR中的帧数据为CSV格式
; 使用前请先运行CoordinateFinder.ahk获取准确的屏幕坐标
; ========================================

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; ========================================
; 配置参数 - 请根据实际情况修改
; ========================================

; 帧范围设置
StartFrame := 1          ; 起始帧号
EndFrame := 100          ; 结束帧号

; 保存路径设置（请修改为你的实际保存路径）
SavePath := "C:\FLIR_Export"  ; CSV文件保存目录

; ========================================
; 屏幕坐标设置 - 请使用CoordinateFinder.ahk获取准确坐标
; ========================================

; 1. Profile窗口中的Save按钮坐标
; 从截图看，在Profile: Line 1窗口的右上角
SaveButtonX := 1238      ; Save按钮X坐标
SaveButtonY := 233       ; Save按钮Y坐标

; 2. 底部时间轴的"下一帧"右箭头按钮坐标
; 在底部播放控制区域，用于切换到下一帧
NextFrameButtonX := 730  ; 下一帧箭头按钮X坐标
NextFrameButtonY := 663  ; 下一帧箭头按钮Y坐标

; 3. Save As对话框中的文件名输入框坐标
FileNameInputX := 1020   ; 文件名输入框X坐标
FileNameInputY := 491    ; 文件名输入框Y坐标

; 4. Save As对话框中的"Save as type"下拉框坐标
FileTypeDropdownX := 1120  ; 文件类型下拉框X坐标
FileTypeDropdownY := 510   ; 文件类型下拉框Y坐标

; 5. Save As对话框中的最终Save按钮坐标
FinalSaveButtonX := 1312   ; 最终Save按钮X坐标
FinalSaveButtonY := 569    ; 最终Save按钮Y坐标

; ========================================
; 时间延迟设置（毫秒）
; ========================================
DelayShort := 300        ; 短延迟（界面响应）
DelayMedium := 800       ; 中等延迟（对话框打开）
DelayLong := 1500        ; 长延迟（文件保存）

; ========================================
; 主程序开始
; ========================================

; 显示启动信息
MsgBox, 4, FLIR批量导出工具,
(
准备批量导出FLIR帧数据
起始帧: %StartFrame%
结束帧: %EndFrame%
保存路径: %SavePath%

重要提示：
1. 确保FLIR ResearchIR软件已打开
2. 确保Profile窗口已打开
3. 请先手动切换到起始帧（第%StartFrame%帧）
4. 点击"是"开始导出
5. 按ESC键可随时中止程序

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

    ; ======= 步骤1: 点击Profile窗口的Save按钮 =======
    Click, %SaveButtonX%, %SaveButtonY%
    Sleep, %DelayMedium%

    ; ======= 步骤2: 在Save As对话框中选择CSV格式 =======
    ; 点击文件类型下拉框
    Click, %FileTypeDropdownX%, %FileTypeDropdownY%
    Sleep, %DelayShort%

    ; 选择CSV选项（使用键盘向下移动到CSV选项）
    ; 从截图看，CSV是第二个选项
    Send, {Down}
    Sleep, 200
    Send, {Enter}
    Sleep, %DelayShort%

    ; ======= 步骤3: 修改文件名为帧序号 =======
    Click, %FileNameInputX%, %FileNameInputY%
    Sleep, %DelayShort%

    ; 清除当前文件名并输入新的
    Send, ^a
    Sleep, 100
    Send, Frame_%CurrentFrame%
    Sleep, %DelayShort%

    ; ======= 步骤4: 点击Save按钮保存 =======
    Click, %FinalSaveButtonX%, %FinalSaveButtonY%
    Sleep, %DelayLong%

    ; 检查是否有覆盖提示（如果文件已存在）
    ; 如果有，自动点击Yes
    IfWinExist, Confirm Save As
    {
        Send, {Enter}  ; 确认覆盖
        Sleep, %DelayMedium%
    }

    ; ======= 步骤5: 点击右箭头切换到下一帧 =======
    ; 只有在不是最后一帧时才切换到下一帧
    if (A_Index < TotalFrames)
    {
        Click, %NextFrameButtonX%, %NextFrameButtonY%
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
    FLIR批量导出工具 - 快捷键说明

    ESC - 中止程序
    F1  - 显示此帮助

    使用步骤：
    1. 修改脚本中的配置参数（起始帧、结束帧、保存路径）
    2. 使用CoordinateFinder.ahk获取屏幕坐标
    3. 将获取的坐标填入脚本中
    4. 打开FLIR ResearchIR软件和Profile窗口
    5. 手动切换到起始帧
    6. 运行此脚本

    工作原理：
    - 脚本会保存当前帧数据
    - 然后点击右箭头切换到下一帧
    - 重复此过程直到完成所有帧
    )
    return
}
