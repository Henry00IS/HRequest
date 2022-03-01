; ---------------------------------------
;  -- Winamp Plugin                   --
;  -- copyright © 00laboratories 2013 --
;  -- http://00laboratories.com/      --
; ---------------------------------------
XIncludeFile #PB_Compiler_File + "i" ;- PBHGEN

#GPPHDR_VER = $10

Structure winampGeneralPurposePlugin
  version.i             ; version of the plug-in structure
  *description          ; name/title of the plug-in
  proc_init.l           ; pointer to the initialize procedure
  proc_conf.l           ; pointer to the config procedure
  proc_quit.l           ; pointer to the quit procedure
  hwndParent.l          ; hwnd of the Winamp client main window
  hDllInstance.l        ; hinstance of this plugin dll
EndStructure

Global WinampPlugin.winampGeneralPurposePlugin
WinampPlugin\version = #GPPHDR_VER

DeclareC.i WinampPlugin_Init()
DeclareC.i WinampPlugin_Conf()
DeclareC.i WinampPlugin_Quit()

WinampPlugin\proc_init = @WinampPlugin_Init()
WinampPlugin\proc_conf = @WinampPlugin_Conf()
WinampPlugin\proc_quit = @WinampPlugin_Quit()

ProcedureCDLL.l winampGetGeneralPurposePlugin()
  If WinampPlugin\description = 0
    MessageRequester("winamp_plugin", "please provide a description")
  EndIf
  ProcedureReturn @WinampPlugin
EndProcedure
; IDE Options = PureBasic 6.00 Beta 4 (Windows - x86)
; CursorPosition = 13
; Folding = -
; EnableXP