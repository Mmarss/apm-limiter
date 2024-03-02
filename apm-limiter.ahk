; APM Limiter
; Version 1.4
; 2024-03-02



; Copyright (C) 2024  Mmarss

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.



; Usage:
; Toggle pause with F3, F12 or Pause
; Chat with Enter, which semi-pauses
; Control options with the right-click menu or tray menu



#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

Actions = 0
ActionBankCap = 10
; Nonzero toggle allows the script to run
ActionsToggle = 0
IsPaused = 1 ; Start paused
IsChatting = 0
PauseText = ıı
IsLocked = true
window_title = "APM Limiter"
control_actions = "control_actions"

Menu, Tray, Add ; Add separator line
Menu, Tray, Add, Lock Position, ToggleLockPosition
Menu, Tray, Check, Lock Position
Menu, MenuApmOptions, Add, 10, SetApmLimit10
Menu, MenuApmOptions, Add, 20, SetApmLimit20
Menu, MenuApmOptions, Add, 40, SetApmLimit40
Menu, MenuApmOptions, Add, 60, SetApmLimit60
Menu, MenuApmOptions, Add, 100, SetApmLimit100
Menu, Tray, Add, APM Limit, :MenuApmOptions
Menu, MenuActionLimitOptions, Add, 1, SetActionLimit1
Menu, MenuActionLimitOptions, Add, 2, SetActionLimit2
Menu, MenuActionLimitOptions, Add, 5, SetActionLimit5
Menu, MenuActionLimitOptions, Add, 10, SetActionLimit10
Menu, MenuActionLimitOptions, Add, 30, SetActionLimit30
Menu, MenuActionLimitOptions, Add, 60, SetActionLimit60
Menu, MenuActionLimitOptions, Add, 100, SetActionLimit100
Menu, Tray, Add, Action Bank Cap, :MenuActionLimitOptions

Menu, ContextMenu, Add, Lock Position, ToggleLockPosition
Menu, ContextMenu, Check, Lock Position
Menu, MenuApmOptions, Add, 10, SetApmLimit10
Menu, MenuApmOptions, Add, 20, SetApmLimit20
Menu, MenuApmOptions, Add, 40, SetApmLimit40
Menu, MenuApmOptions, Add, 60, SetApmLimit60
Menu, MenuApmOptions, Add, 100, SetApmLimit100
Menu, ContextMenu, Add, APM Limit, :MenuApmOptions
Menu, MenuActionLimitOptions, Add, 1, SetActionLimit1
Menu, MenuActionLimitOptions, Add, 2, SetActionLimit2
Menu, MenuActionLimitOptions, Add, 5, SetActionLimit5
Menu, MenuActionLimitOptions, Add, 10, SetActionLimit10
Menu, MenuActionLimitOptions, Add, 30, SetActionLimit30
Menu, MenuActionLimitOptions, Add, 60, SetActionLimit60
Menu, MenuActionLimitOptions, Add, 100, SetActionLimit100
Menu, ContextMenu, Add, Action Bank Cap, :MenuActionLimitOptions
Menu, ContextMenu, Add, Exit, Exit

Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Color, 333333
;Gui, +LastFound
;WinSet, TransColor, 000000
Gui, Font, s42 bold cWhite
Gui, Add, Text, x4 y4 w112 Center vActions, %Actions%
Gui, Font, s12 bold cWhite
Gui, Add, Text, x103 y2 w12 h18 Center vPauseText, %PauseText%
Gui, Show, x6 y150 w120 h72

OnMessage(0x0201, "WM_LBUTTONDOWN")
OnMessage(0x0204, "WM_RBUTTONDOWN")

WM_LBUTTONDOWN(wParam, lParam) {
  global IsLocked
  if (!IsLocked) {
    PostMessage, 0xA1, 2,,, A
  }
}

WM_RBUTTONDOWN(wParam, lParam) {
  Menu, ContextMenu, Show
}

ToggleLockPosition() {
  global IsLocked
  IsLocked := !IsLocked
  Menu, Tray, ToggleCheck, Lock Position
  Menu, ContextMenu, ToggleCheck, Lock Position
}

UpdateGui() {
  global Actions, PauseText, IsPaused, IsChatting, ActionBankCap
  GuiControl, Text, Actions, %Actions%
  GuiControl, Text, PauseText, %PauseText%
  if (IsPaused || IsChatting) {
    Gui, Color, 333333
    Gui, Font, s42 bold cWhite
    GuiControl, Font, Actions
  } else if (Actions == 0) {
    Gui, Color, FF0000
    Gui, Font, s42 bold cBlack
    GuiControl, Font, Actions
  } else if (Actions == ActionBankCap) {
    Gui, Color, 000000
    Gui, Font, s42 bold cYellow
    GuiControl, Font, Actions
  } else {
    Gui, Color, 000000
    Gui, Font, s42 bold cWhite
    GuiControl, Font, Actions
  }
}

UpdateTimers() {
  global IsPaused
  if (!IsPaused) {
    SetTimer, Timer_NewAction, On
  } else {
    SetTimer, Timer_NewAction, Off
  }
}

UpdatePauseText() {
  global PauseText, IsChatting, IsPaused
  if (IsChatting) {
    PauseText = ↩ ; Arrow down left
  } else {
    if (IsPaused) {
      PauseText = ıı
    } else {
      PauseText = ▶ ; Play symbol
    }
  }
}

UpdateAction(Delta:=-1) {
  global Actions, ActionBankCap
  Actions += Delta
  if (Actions > ActionBankCap) {
    Actions := ActionBankCap
  }
}

UpdateApmLimit(Limit:=60) {
  Duration := 1000*60/Limit
  SetTimer, Timer_NewAction, %Duration%
}

UpdateApmLimit()

if (IsPaused) {
  SetTimer, Timer_NewAction, Off
}

~F3 Up::
~F12 Up::
~Pause Up::
  IsPaused := !IsPaused
  ActionsToggle := !(IsPaused || IsChatting)
  UpdateTimers()
  UpdatePauseText()
  UpdateGui()
  Return

~Enter Up::
~NumpadEnter Up::
  IsChatting := !IsChatting
  ActionsToggle := !(IsPaused || IsChatting)
  UpdateTimers()
  UpdatePauseText()
  UpdateGui()
  Return

#If Actions and ActionsToggle
; Allow input but count actions
~*LButton::
~*RButton::
~*MButton::
~*XButton1::
~*XButton2::
~*WheelDown::
~*WheelUp::
~*WheelLeft::
~*WheelRight::
~*A::
~*B::
~*C::
~*D::
~*E::
~*F::
~*G::
~*H::
~*I::
~*J::
~*K::
~*L::
~*M::
~*N::
~*O::
~*P::
~*Q::
~*R::
~*S::
~*T::
~*U::
~*V::
~*W::
~*X::
~*Y::
~*Z::
~*`::
~*SC002:: ; 1
~*SC003:: ; 2
~*SC004:: ; 3
~*SC005:: ; 4
~*SC006:: ; 5
~*SC007:: ; 6
~*SC008:: ; 7
~*SC009:: ; 8
~*SC00A:: ; 9
~*SC00B:: ; 0
~*-::
~*=::
~*\::
~*Space::
~*Tab::
~*CapsLock::
~*Escape::
~*Backspace::
;~*Enter:: ; Enter key has special effect
~*F1::
~*F2::
;~*F3:: ; Pause key has special effect
~*F4::
~*F5::
~*F6::
~*F7::
~*F8::
~*F9::
~*F10::
~*F11::
;~*F12:: ; F12 is an extra pause key
~*Delete::
~*Insert::
~*Home::
~*End::
~*PgUp::
~*PgDn::
~*Up::
~*Down::
~*Left::
~*Right::
~*Numpad0::
~*NumpadIns::
~*Numpad1::
~*NumpadEnd::
~*Numpad2::
~*NumpadDown::
~*Numpad3::
~*NumpadPgDn::
~*Numpad4::
~*NumpadLeft::
~*Numpad5::
~*NumpadClear::
~*Numpad6::
~*NumpadRight::
~*Numpad7::
~*NumpadHome::
~*Numpad8::
~*NumpadUp::
~*Numpad9::
~*NumpadPgUp::
~*NumpadDot::
~*NumpadDel::
~*NumpadDiv::
~*NumpadMult::
~*NumpadAdd::
~*NumpadSub::
;~*NumpadEnter:: ; Enter key has special effect
  UpdateAction()
  UpdateGui()
  Return

#If not Actions and ActionsToggle
; Block key presses
*LButton::
*RButton::
*MButton::
*XButton1::
*XButton2::
*WheelDown::
*WheelUp::
*WheelLeft::
*WheelRight::
*A::
*B::
*C::
*D::
*E::
*F::
*G::
*H::
*I::
*J::
*K::
*L::
*M::
*N::
*O::
*P::
*Q::
*R::
*S::
*T::
*U::
*V::
*W::
*X::
*Y::
*Z::
*`::
*SC002:: ; 1
*SC003:: ; 2
*SC004:: ; 3
*SC005:: ; 4
*SC006:: ; 5
*SC007:: ; 6
*SC008:: ; 7
*SC009:: ; 8
*SC00A:: ; 9
*SC00B:: ; 0
*-::
*=::
*\::
*Space::
*Tab::
*CapsLock::
*Escape::
*Backspace::
;*Enter:: ; Enter key has special effect
*F1::
*F2::
;*F3:: ; Pause key has special effect
*F4::
*F5::
*F6::
*F7::
*F8::
*F9::
*F10::
*F11::
;*F12:: ; F12 key is extra pause
*Delete::
*Insert::
*Home::
*End::
*PgUp::
*PgDn::
*Up::
*Down::
*Left::
*Right::
*Numpad0::
*NumpadIns::
*Numpad1::
*NumpadEnd::
*Numpad2::
*NumpadDown::
*Numpad3::
*NumpadPgDn::
*Numpad4::
*NumpadLeft::
*Numpad5::
*NumpadClear::
*Numpad6::
*NumpadRight::
*Numpad7::
*NumpadHome::
*Numpad8::
*NumpadUp::
*Numpad9::
*NumpadPgUp::
*NumpadDot::
*NumpadDel::
*NumpadDiv::
*NumpadMult::
*NumpadAdd::
*NumpadSub::
;*NumpadEnter:: ; Enter key has special effect
  Return

Exit

Exit:
  ExitApp
  Return

Timer_NewAction:
  UpdateAction(+1)
  UpdateGui()
  Return

SetApmLimit10:
  UpdateApmLimit(10)
  Return

SetApmLimit20:
  UpdateApmLimit(20)
  Return

SetApmLimit40:
  UpdateApmLimit(40)
  Return

SetApmLimit60:
  UpdateApmLimit(60)
  Return

SetApmLimit100:
  UpdateApmLimit(100)
  Return

SetActionLimit1:
  ActionBankCap := 1
  Return

SetActionLimit2:
  ActionBankCap := 2
  Return

SetActionLimit5:
  ActionBankCap := 5
  Return

SetActionLimit10:
  ActionBankCap := 10
  Return

SetActionLimit30:
  ActionBankCap := 30
  Return

SetActionLimit60:
  ActionBankCap := 60
  Return

SetActionLimit100:
  ActionBankCap := 100
  Return