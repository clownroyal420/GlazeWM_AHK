#Requires AutoHotkey v2.0.2
#SingleInstance Force
TraySetIcon "logo.ico"

~Home:: ; Doubletapping Home will reload the script.
{
    if (A_PriorHotkey != A_ThisHotkey or A_TimeSincePriorHotkey > DllCall("GetDoubleClickTime"))
    {
        ; Too much time between presses, so this isn't a double-press.
        KeyWait "Home"
        return
    }
    Reload
}

global ffm := false         ; Set this to the desired default setting.
global ffmDelay := 100      ; Focus-Follows-Mouse delay in milliseconds
SetFFM( ffm )
SetFFM( EnableDisable )
{
    global ffm := EnableDisable
    DllCall("SystemParametersInfoW", "UInt", 0x1001, "UInt", 0, "Ptr", ffm)
    DllCall("SystemParametersInfoW", "UInt", 0x2003, "UInt", 0, "Ptr", ffmDelay)
}
~Ctrl::
{
    global ffm
    ffmlv := ffm
    SetFFM( false )
    KeyWait "Ctrl"
    SetFFM( ffmlv )
}

If !ProcessExist("glazewm.exe") {
    RunWait("C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe start -c config.yaml", ,"Hide")
    RunWait("python.exe " A_Appdata "\glzr\glazewm\AutoTile.py", , "Hide")
}

WinSetTransparent 0, "ahk_class Shell_TrayWnd"

OnExit(OnExitFunction)
OnExitFunction(ExitReason, ExitCode := 0)
{
    Switch ExitReason
    {
        Case "Exit":
            {
                WinSetTransparent 255, "ahk_class Shell_TrayWnd"
                glazewm("wm-exit")
            }
        Case "Menu":
        {
            WinSetTransparent 255, "ahk_class Shell_TrayWnd"
            glazewm("wm-exit")
        }
        Case "Reload":
            {
                glazewm("wm-reload-config")
            }
    }
}

glazewm(command)
{
	RunWait("C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe command " command, ,"Hide")
}
FocusedMonitor()
{
    CoordMode("Mouse","Screen")
    MonitorCount := MonitorGetCount()
    loop MonitorCount {
        MonitorIndex := MonitorCount - A_Index + 1
        MouseGetPos(&X, &Y)
        MonitorGet(MonitorIndex, &Left, &Top, &Right, &Bottom)
        if X > Left and X < Right {
            Return A_Index
        }
    }
}

#h::glazewm("focus --direction left")
#j::glazewm("focus --direction down")
#k::glazewm("focus --direction up")
#l::glazewm("focus --direction right")

#+h::glazewm("move --direction left")
#+j::glazewm("move --direction down")
#+k::glazewm("move --direction up")
#+l::glazewm("move --direction right")

; #x::glazewm("toggle-tiling-direction")
; SetTimer AutoTile, 1000
Autotile()
{
    Try {
        WinGetPos(,,&Width,&Height,"A")
        TilingDirection := Width>Height ? "horizontal" : "vertical"
        glazewm(Format("set-tiling-direction {}",TilingDirection))
    }
}

#t::glazewm("toggle-floating --centered")

#1::glazewm("focus --workspace " 1 + 100*FocusedMonitor())
#2::glazewm("focus --workspace " 2 + 100*FocusedMonitor())
#3::glazewm("focus --workspace " 3 + 100*FocusedMonitor())
#4::glazewm("focus --workspace " 4 + 100*FocusedMonitor())
#5::glazewm("focus --workspace " 5 + 100*FocusedMonitor())
#6::glazewm("focus --workspace " 6 + 100*FocusedMonitor())
#7::glazewm("focus --workspace " 7 + 100*FocusedMonitor())
#8::glazewm("focus --workspace " 8 + 100*FocusedMonitor())
#9::glazewm("focus --workspace " 9 + 100*FocusedMonitor())
#WheelUp::
#^h::glazewm("focus --prev-active-workspace")
#WheelDown::
#^l::glazewm("focus --next-active-workspace")

#+1::glazewm("move --workspace " 1 + 100*FocusedMonitor()),glazewm("focus --workspace " 1 + 100*FocusedMonitor())
#+2::glazewm("move --workspace " 2 + 100*FocusedMonitor()),glazewm("focus --workspace " 2 + 100*FocusedMonitor())
#+3::glazewm("move --workspace " 3 + 100*FocusedMonitor()),glazewm("focus --workspace " 3 + 100*FocusedMonitor())
#+4::glazewm("move --workspace " 4 + 100*FocusedMonitor()),glazewm("focus --workspace " 4 + 100*FocusedMonitor())
#+5::glazewm("move --workspace " 5 + 100*FocusedMonitor()),glazewm("focus --workspace " 5 + 100*FocusedMonitor())
#+6::glazewm("move --workspace " 6 + 100*FocusedMonitor()),glazewm("focus --workspace " 6 + 100*FocusedMonitor())
#+7::glazewm("move --workspace " 7 + 100*FocusedMonitor()),glazewm("focus --workspace " 7 + 100*FocusedMonitor())
#+8::glazewm("move --workspace " 8 + 100*FocusedMonitor()),glazewm("focus --workspace " 8 + 100*FocusedMonitor())
#+9::glazewm("move --workspace " 9 + 100*FocusedMonitor()),glazewm("focus --workspace " 9 + 100*FocusedMonitor())
#+WheelUp::
#^+h::glazewm("move --prev-active-workspace"),glazewm("focus --prev-active-workspace")
#+WheelDown::
#^+l::glazewm("move --next-active-workspace"),glazewm("focus --next-active-workspace")

#^!h::glazewm("move-workspace --direction left")
#^!j::glazewm("move-workspace --direction down")
#^!k::glazewm("move-workspace --direction up")
#^!l::glazewm("move-workspace --direction right")

#p::glazewm("wm-toggle-pause")
#f::glazewm("toggle-fullscreen")
#m::glazewm("toggle-minimized")
#c::glazewm("close")
#HotIf WinActive("ahk_exe Revu.exe")
#c::
{
    RunWait("`"C:\Program Files\Bluebeam Software\Bluebeam Revu\20\Revu\PbMngr5.exe`" /Unregister")
    glazewm("close")
}
#HotIf

!Space::glazewm("wm-cycle-focus")

#HotIf !WinExist("ahk_class TopLevelWindowForOverflowXamlIsland")   ; Usually I like to have the taskbar hidden.
<#b::                                                               ; Win-B is the standard shortcut to select the system tray overflow items.
{                                                                   ; By pinning zero items other than wifi & such, we can get to our system tray apps with WIN-B
    global ffm
    ffm_LV := ffm
    SetFFM(false)
    Send "{Blind}{LWin down}{b}{LWin up}{Space}"
    WinWaitNotActive("System tray overflow window.")
    KeyWait "LWin"
    KeyWait "b"
    SetFFM(ffm_LV)
}
>#b::                                                               ; Win-B is the standard shortcut to select the system tray overflow items.
{                                                                   ; By pinning zero items other than wifi & such, we can get to our system tray apps with WIN-B
    global ffm
    ffm_LV := ffm
    SetFFM(false)
    Send "{Blind}{LWin down}{b}{LWin up}{Space}"
    WinWaitNotActive("System tray overflow window.")
    KeyWait "RWin"
    KeyWait "b"
    SetFFM(ffm_LV)
}
#HotIf WinExist("ahk_class TopLevelWindowForOverflowXamlIsland")
#b::Send "{Esc}"
#HotIf

; FlowLauncher
#HotIf !WinExist("Flow.Launcher")
#Space::FlowLauncher("open")
#HotIf WinExist("Flow.Launcher")
#Space::FlowLauncher("close")
#HotIf
FlowLauncher( action )
{
    if StrCompare( action, "open" )=0
    {
        global ffm
        ffmlv := ffm
        SetFFM(false)
        Run( EnvGet("HOMEPATH") '\AppData\Local\FlowLauncher\Flow.Launcher.exe')
        WinWait("Flow.Launcher")
        WinWaitNotActive("ahk_exe Flow.Launcher.exe")
        SetFFM(ffmlv)
        Return
    }
    if StrCompare( action, "close")=0
    {
        if !WinActive("ahk_exe Flow.Launcher.exe")
        {
            WinActivate("ahk_exe Flow.Launcher.exe")
        } else {
            Send "{Escape}"
        }
        Return
    }
}

; yasb status bar
if !ProcessExist("yasb.exe") {
    RunWait('yasbc.exe start',,"Hide")
}
#F2::
{
    if ProcessExist("yasb.exe") {
        RunWait('yasbc.exe stop',,"Hide")
    } else {
        RunWait('yasbc.exe start',,"Hide")
    }
}