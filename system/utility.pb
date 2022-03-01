XIncludeFile #PB_Compiler_File + "i" ;- PBHGEN

; Some Forum Stuff

Procedure.s SpecialFolderLocation(csidl.l)
   Protected location.s,pidl.l
   If SHGetSpecialFolderLocation_(#Null,csidl,@pidl)=#ERROR_SUCCESS
      location.s=Space(#MAX_PATH)
      If SHGetPathFromIDList_(pidl,@location.s)
         If Right(location.s,1)<>"\"
            location.s+"\"
         EndIf
      EndIf
      If pidl
         CoTaskMemFree_(pidl) ; Instead of messing with com imalloc free and whatnot.
      EndIf
   EndIf
   ProcedureReturn Trim(location.s)
 EndProcedure
 
; awesome henry

Procedure.s GetParentDirectory(FullPath$)
  InitialPath$ = GetPathPart(FullPath$)
  ProcedureReturn StringField(InitialPath$, CountString(InitialPath$, "\"), "\")
EndProcedure

Procedure.i BuildRegistry00()
  If Not Registry_DoesSubKeyExist(#HKEY_CURRENT_USER,"Software\00laboratories\winamp_hrequest")
    Registry_CreateSubKey(#HKEY_CURRENT_USER, "Software\00laboratories\winamp_hrequest")
  EndIf
EndProcedure

Procedure.s GetRegistryKey(hkey.l, subKey$, valueName$, defaultValue$)
  If Not Registry_DoesSubKeyExist(hkey, subKey$)
    Registry_CreateSubKey(hkey, subKey$)
  EndIf

  result$ = Registry_GetValueAsString(hkey, subKey$, valueName$)
  If Registry_GetLastErrorCode() = #ERROR_SUCCESS
    ProcedureReturn result$
  Else
    Registry_SetStringValue(hkey, subKey$, valueName$, defaultValue$)
    ProcedureReturn defaultValue$
  EndIf

EndProcedure
; IDE Options = PureBasic 4.60 (Windows - x86)
; Folding = -
; EnableXP