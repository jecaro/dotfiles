#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
sendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; Remap  caps lock for esc
CapsLock::Esc
; Delete dead keys ^ ` and ~
SC01A::SendRaw % "^ "   
<^>!è::SendRaw % "`` "
<^>!é::SendRaw % "~ "
