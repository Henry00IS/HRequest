; ---------------------------------------
;  -- Timer Library                   --
;  -- copyright © 00laboratories 2013 --
;  -- http://00laboratories.com/      --
; ---------------------------------------
XIncludeFile #PB_Compiler_File + "i" ;- PBHGEN

Structure Timer
  Time.l
EndStructure

; Resets the timer to its initial state
Procedure Timer_Reset(*Timer.Timer)
  *Timer\Time = ElapsedMilliseconds()
EndProcedure

; Return whether the timer is beyond a specific time
Procedure Timer_Past(*Timer.Timer, miliseconds.l)
  If ElapsedMilliseconds() - *Timer\Time > miliseconds
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure
; IDE Options = PureBasic 4.60 (Windows - x86)
; CursorPosition = 19
; Folding = -
; EnableXP