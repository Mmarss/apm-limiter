; APM Limiter
; Version 1.5
; 2024-08-05



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



; #Warn
#SingleInstance Force

ActionBank      := 0
ActionBankCap   := 10
ActionInterval  := 0
ActionsToggle   := 0 ; Nonzero toggle allows the script to run
IsPaused        := 1 ; Start paused
IsChatting      := 0
PauseText       := "ıı"
IsLocked        := true
window_title    := "APM Limiter"
control_actions := "control_actions"

A_TrayMenu.Add() ; Add separator line
A_TrayMenu.Add("Lock Position", OnMenuToggleLockPosition)
A_TrayMenu.Check("Lock Position")

ContextMenu := Menu()
ContextMenu.Add("Lock Position", OnMenuToggleLockPosition)
ContextMenu.Check("Lock Position")

MenuApmOptions := Menu()
MenuApmOptions.Add("10", OnMenuSetApmLimit)
MenuApmOptions.Add("20", OnMenuSetApmLimit)
MenuApmOptions.Add("40", OnMenuSetApmLimit)
MenuApmOptions.Add("60", OnMenuSetApmLimit)
MenuApmOptions.Add("100", OnMenuSetApmLimit)
A_TrayMenu.Add("APM Limit", MenuApmOptions)
ContextMenu.Add("APM Limit", MenuApmOptions)

MenuActionLimitOptions := Menu()
MenuActionLimitOptions.Add("1", OnMenuSetActionLimit)
MenuActionLimitOptions.Add("2", OnMenuSetActionLimit)
MenuActionLimitOptions.Add("5", OnMenuSetActionLimit)
MenuActionLimitOptions.Add("10", OnMenuSetActionLimit)
MenuActionLimitOptions.Add("30", OnMenuSetActionLimit)
MenuActionLimitOptions.Add("60", OnMenuSetActionLimit)
MenuActionLimitOptions.Add("100", OnMenuSetActionLimit)
A_TrayMenu.Add("Action Bank Cap", MenuActionLimitOptions)
ContextMenu.Add("Action Bank Cap", MenuActionLimitOptions)

ContextMenu.Add("Exit", Exit)

ActionBankGui := Gui("+AlwaysOnTop +ToolWindow -Caption")
ActionBankGui.BackColor := "333333"
ActionBankGui.SetFont("s42 bold cWhite")
ActionBankGui.Add("Text", "x4 y4 w112 Center vActionBankText", ActionBank)
ActionBankGui.SetFont("s12 bold cWhite")
ActionBankGui.Add("Text", "x103 y2 w12 h18 Center vPauseText", PauseText)
ActionBankGui.Show("x6 y150 w120 h72")

OnMessage(0x0201, WM_LBUTTONDOWN)
OnMessage(0x0204, WM_RBUTTONDOWN)

WM_LBUTTONDOWN(*) {
  global IsLocked
  if (!IsLocked) {
    PostMessage("0xA1", 2)
  }
}

WM_RBUTTONDOWN(*) {
  ContextMenu.Show()
}

Exit(*) {
  ExitApp()
}

OnMenuToggleLockPosition(*) {
  global IsLocked
  IsLocked := !IsLocked
  A_TrayMenu.ToggleCheck("Lock Position")
  ContextMenu.ToggleCheck("Lock Position")
}

OnMenuSetApmLimit(ItemName, *) {
  UpdateApmLimit(ItemName + 0)
}

OnMenuSetActionLimit(ItemName, *) {
  global ActionBankCap
  ActionBankCap := ItemName + 0
}

UpdateGui() {
  global ActionBankGui, PauseText, IsPaused, IsChatting, ActionBankCap

  ActionBankGui["ActionBankText"].Text := ActionBank
  ActionBankGui["PauseText"].Text := PauseText

  if (IsPaused || IsChatting) {
    ActionBankGui.BackColor := "333333"
    ActionBankGui["ActionBankText"].SetFont("s42 bold cWhite")
  } else if (ActionBank == 0) {
    ActionBankGui.BackColor := "FF0000"
    ActionBankGui["ActionBankText"].SetFont("s42 bold cBlack")
  } else if (ActionBank == ActionBankCap) {
    ActionBankGui.BackColor := "000000"
    ActionBankGui["ActionBankText"].SetFont("s42 bold cYellow")
  } else {
    ActionBankGui.BackColor := "000000"
    ActionBankGui["ActionBankText"].SetFont("s42 bold cWhite")
  }
}

Timer_NewAction() {
  UpdateAction(+1)
  UpdateGui()
}

UpdateTimers() {
  global IsPaused, ActionInterval
  if (!IsPaused) {
    SetTimer(Timer_NewAction, ActionInterval)
  } else {
    SetTimer(Timer_NewAction, 0)
  }
}

UpdatePauseText() {
  global PauseText, IsChatting, IsPaused
  if (IsChatting) {
    PauseText := "↩" ; Arrow down left
  } else {
    if (IsPaused) {
      PauseText := "ıı"
    } else {
      PauseText := "▶" ; Play symbol
    }
  }
}

UpdateAction(Delta:=-1) {
  global ActionBank, ActionBankCap
  ActionBank += Delta
  if (ActionBank > ActionBankCap) {
    ActionBank := ActionBankCap
  }
}

UpdateApmLimit(ApmLimit:=60) {
  global ActionInterval
  ActionInterval := 1000*60/ApmLimit
  UpdateTimers()
}

UpdateApmLimit()

~F3::
~F12::
~Pause::
{
  global IsPaused, ActionsToggle
  IsPaused := !IsPaused
  ActionsToggle := !(IsPaused || IsChatting)
  UpdateTimers()
  UpdatePauseText()
  UpdateGui()
}

~Enter::
~NumpadEnter::
{
  global IsChatting, ActionsToggle
  IsChatting := !IsChatting
  ActionsToggle := !(IsPaused || IsChatting)
  UpdateTimers()
  UpdatePauseText()
  UpdateGui()
}

#HotIf ActionsToggle and ActionBank <= 0
; Block key presses
;*LButton::
;*RButton::
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
{
  return
}

#HotIf ActionsToggle and ActionBank > 0
; Allow input but count actions
;~*LButton::
;~*RButton::
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
{
  UpdateAction()
  UpdateGui()
}
