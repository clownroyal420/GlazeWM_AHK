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

global ffm := true          ; Set this to the desired default setting.
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

ToggleTaskbar(1)
#F1::ToggleTaskBar()
ToggleTaskbar(action := -1) ; 1 for hide, 0 for show, -1 for toggle
{
    static ABM_GETSTATE := 0x00000004
    static ABM_SETSTATE := 0x0000000A
    static ABS_AUTOHIDE := 0x1
    static ABS_ALWAYSONTOP := 0x2
    APPBARDATA := Buffer(size := 2 * A_PtrSize + 2 * 4 + 16 + A_PtrSize, 0)
    NumPut("UInt", size, APPBARDATA)
    STATE := DllCall("Shell32\SHAppBarMessage", "UInt", ABM_GETSTATE, "Ptr", APPBARDATA)
    if action = STATE & ABS_AUTOHIDE {
        return
    }
    NumPut('UInt', STATE ^ ABS_AUTOHIDE, APPBARDATA, size - A_PtrSize)
    WinSetTransparent 255*!(STATE ^ ABS_AUTOHIDE), "ahk_class Shell_TrayWnd"
    return DllCall("Shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", APPBARDATA)
}

OnExit(OnExitFunction)
OnExitFunction(ExitReason, ExitCode := 0)
{
    Switch ExitReason
    {
        Case "Exit":
            {
                ToggleTaskbar(0)
                SetFFM( false )
                glazewm("wm-exit")
            }
        Case "Menu":
        {
            ToggleTaskbar(0)
            SetFFM( false )
            glazewm("wm-exit")
        }
        Case "Reload":
            {
                glazewm("wm-reload-config")
            }
    }
}

MonitorXPositioning()
FocusedMonitor()
{
    global MonitorXCoords
    CoordMode("Mouse","Screen")
    MouseGetPos(&X, &Y)
    loop MonitorXCoords.Length {
        if X < Float(MonitorXCoords[A_Index]) {
            Return A_Index
        }
    }
}
MonitorXPositioning()
{
    global MonitorXCoords
    XCoords := ""
    loop MonitorGetCount()
    {
        MonitorGet(A_Index, , , &Right)
        XCoords .= Right "`n"
    }
    XCoords := Sort(RTrim(XCoords,'`n'),'N')
    Return MonitorXCoords := StrSplit(Sort(XCoords,"N"),"`n")
}

glazewm(command)
{
	RunWait("C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe command " command, ,"Hide")
}

#h::focuswindow("left")
#j::focuswindow("down")
#k::focuswindow("up")
#l::focuswindow("right")
focuswindow(direction)
{
    CoordMode('Mouse', 'Screen')
    glazewm("focus --direction " direction)
    WinGetPos(&X, &Y, &W, &H, "A")
    MouseMove(X+W-25,Y+H-25)
}

#+h::movewindow("left")
#+j::movewindow("down")
#+k::movewindow("up")
#+l::movewindow("right")
movewindow(direction)
{

    CoordMode('Mouse','Screen')
    hwnd := WinGetID("A")
    glazewm("move --direction " direction)
    sleep 50
    WinGetPos(&X, &Y, &W, &H, "ahk_id " hwnd)
    MouseMove(X+W-25,Y+H-25)
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

; Auto-Start GlazeWM if not already started
If !ProcessExist("glazewm.exe") {
    RunWait("C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe start -c config.yaml", ,"Hide")
    RunWait("python.exe " "AutoTile.py", , "Hide")
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