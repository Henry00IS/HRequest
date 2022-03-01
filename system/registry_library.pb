XIncludeFile #PB_Compiler_File + "i" ;- PBHGEN

;/////////////////////////////////////////////////////////////////////////////////
;*Simple registry functions - Stephen Rodriguez 2009.
;*
;*Purebasic 4.3.
;*
;*Based upon code found at : http://www.purebasic.fr/german/viewtopic.php?p=177460#177460
;*With thanks to mk-soft.
;*
;*The error reporting parts of this code are NOT threadsafe.
;*
;*
;*List of registry functions :
;*============================
;*
;*    Registry_CreateSubKey(hKey, subKey$)
;*                          - Returns either #REG_CREATED_NEW_KEY   or REG_OPENED_EXISTING_KEY.
;*
;*    Registry_DeleteSubKey(hKey, subKey$, blnDeleteAllDescendantKeys = #False)
;*                          - If blnDeleteAllDescendantKeys is non-zero, all descendants of the given key are deleted.
;*                            Otherwise, on Win NT systems, this function will fail if the specified key has subkeys.
;*                          - Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
;*
;*    Registry_DeleteSubKeyValue(hKey, subKey$, valueName$)
;*                          - Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
;*
;*    Registry_DoesSubKeyExist(hKey, subKey$)
;*                          - Returns #True or #False.
;*
;*    Registry_GetIntegerValue(hKey, subKey$, valueName$, *type.INTEGER = 0)
;*                          - '*type' can hold the address of a variable to receive the type of data held with the registry key/value.
;*                          - Returns zero if the value is not of #REG_DWORD or #REG_QWORD format otherwise returns a QUAD value.
;*
;*    Registry_GetValueAsString(hKey, subKey$, valueName$, *type.INTEGER = 0)
;*                          - Any value retrieved from the registry is converted to a string.
;*                            Supports value types : #REG_DWORD, #REG_QWORD, #REG_SZ and #REG_EXPAND_SZ.
;*                            In the case of #REG_EXPAND_SZ, the user can use the ExpandEnvironmentStrings_() api function to expand the
;*                            embedded environment variables.
;*
;*    Registry_SetLongValue(hKey, subKey$, valueName$, value.l)
;*                          - Sets the DWORD value for the specified key/value
;*                          - Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
;*
;*    Registry_SetNullValue(hKey, subKey$, valueName$)
;*                          - Sets the value type for the specified key/value to #REG_NONE.
;*                          - Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
;*
;*    Registry_SetQuadValue(hKey, subKey$, valueName$, value.q)
;*                          - Sets the QWORD value for the specified key/value
;*                          - Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
;*
;*    Registry_SetStringValue(hKey, subKey$, valueName$, value$)
;*                          - Sets the string (#REG_SZ) value for the specified key/value
;*                          - Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
;*
;*List of error reporting functions (not threadsafe) :
;*====================================================
;*
;*    Registry_GetLastErrorCode()
;*
;*    Registry_GetLastErrorDescription()
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;-GLOBALS.
  Global gRegistry_LastErrorCode, gRegistry_LastErrorDescription$
;/////////////////////////////////////////////////////////////////////////////////


;-INTERNAL FUNCTIONS.
;-====================

;/////////////////////////////////////////////////////////////////////////////////
Procedure Registry_INTERNAL_SetError(errorCode)
  Protected *Buffer, len
  len = FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER|#FORMAT_MESSAGE_FROM_SYSTEM, 0, errorCode, 0, @*Buffer, 0, 0)
  If len
    gRegistry_LastErrorDescription$  = PeekS(*Buffer, len)
    LocalFree_(*Buffer)
  Else
    gRegistry_LastErrorDescription$  = "Errorcode: " + Hex(errorCode)
  EndIf
  gRegistry_LastErrorCode = errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;-'PUBLIC' FUNCTIONS.
;-===================

;-Error functions.
;-------------------------

;/////////////////////////////////////////////////////////////////////////////////
Procedure.i Registry_GetLastErrorCode()
  ProcedureReturn gRegistry_LastErrorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
Procedure.s Registry_GetLastErrorDescription()
  ProcedureReturn gRegistry_LastErrorDescription$
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;-Registry functions.
;------------------------------

;/////////////////////////////////////////////////////////////////////////////////
;The following function creates a new registry key and sets the error code as appropriate.
;If successful, returns either #REG_CREATED_NEW_KEY   or REG_OPENED_EXISTING_KEY to indicate that the key already existed.
Procedure.i Registry_CreateSubKey(hKey, subKey$)
  Protected errorCode, lpSecurityAttributes.SECURITY_ATTRIBUTES, hKey1, createKey
  errorCode = RegCreateKeyEx_(hKey, subKey$, 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, @lpSecurityAttributes, @hKey1, @createKey)
  If errorCode = #ERROR_SUCCESS
    RegCloseKey_(hKey1)
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn createKey
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function deletes the specified key and all values and sets the error code as appropriate.
;If blnDeleteAllDescendantKeys is non-zero, all descendants of the given key are deleted.
;Otherwise, on Win NT systems, this function will fail if the specified key has subkeys.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Procedure.i Registry_DeleteSubKey(hKey, subKey$, blnDeleteAllDescendantKeys = #False)
  Protected errorCode, hKey1, newSubkey$, bufferSize
  If blnDeleteAllDescendantKeys = #False
    errorCode = RegDeleteKey_(hKey, subKey$)
  Else
    ;We must enumerate all subkeys of the given key and delete! We do this recursively.
    errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_ENUMERATE_SUB_KEYS, @hKey1)
    If errorCode = #ERROR_SUCCESS
      Repeat
        newSubkey$ = Space(256) : bufferSize = 256
        errorCode = RegEnumKeyEx_(hKey1, 0, @newSubkey$, @bufferSize, 0, 0, 0, 0)
        If errorCode = #ERROR_SUCCESS
          errorCode = Registry_DeleteSubKey(hKey, subKey$+"\"+newSubkey$, #True)
        EndIf
      Until errorCode <> #ERROR_SUCCESS
      RegCloseKey_(hKey1)
      If errorCode = #ERROR_NO_MORE_ITEMS
        errorCode = RegDeleteKey_(hKey, subKey$)
      EndIf
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function deletes the specified key/value entry and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Procedure.i Registry_DeleteSubKeyValue(hKey, subKey$, valueName$)
  Protected errorCode, hKey1
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_ALL_ACCESS, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      errorCode = RegDeleteValue_(hKey1, @valueName$)
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function returns #True or #False as appropriate.
Procedure.i Registry_DoesSubKeyExist(hKey, subKey$)
  Protected result, errorCode, hKey1
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_READ, @hKey1)
  If hKey1
    result = #True 
    RegCloseKey_(hKey1)
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn result
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function attempts to retrieve the specified value and sets the error code as appropriate.
;*type can hold the address of a variable to receive the type of data held with the registry key/value.
;Returns zero if the value is not of #REG_DWORD or #REG_QWORD format.
Procedure.q Registry_GetIntegerValue(hKey, subKey$, valueName$, *type.INTEGER = 0)
  Protected errorCode = #ERROR_SUCCESS, hKey1, bufferSize, type, value.q
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_READ, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      bufferSize = SizeOf(QUAD)
      errorCode = RegQueryValueEx_(hKey1, valueName$, 0, @type, @value, @bufferSize)
      If errorCode = #ERROR_SUCCESS
        If *type
          *type\i = type
        EndIf
        If type <> #REG_DWORD And type <> #REG_QWORD
          value = 0 ;Just in case!
          errorCode = #ERROR_INVALID_DATATYPE
        EndIf
      ElseIf errorCode = #ERROR_MORE_DATA
        If *type
          *type\i = type
        EndIf
        value = 0
        errorCode = #ERROR_INVALID_DATATYPE
      EndIf
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn value
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function attempts to retrieve the specified value and sets the error code as appropriate.
;Any value retrieved from the registry is converted to a string.
;*type can hold the address of a variable to receive the type of data held with the registry key/value.
;In the case that a #REG_EXPAND_SZ string is returned, the user can use the ExpandEnvironmentStrings_() api function to expand the
;embedded environment variables.
Procedure.s Registry_GetValueAsString(hKey, subKey$, valueName$, *type.INTEGER = 0)
  Protected errorCode = #ERROR_SUCCESS, result$, hKey1, bufferSize, type, value.q
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_READ, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      errorCode = RegQueryValueEx_(hKey1, valueName$, 0, @type, 0, @bufferSize)
      If errorCode = #ERROR_SUCCESS
        If *type
          *type\i = type
        EndIf
        Select type
          Case #REG_DWORD, #REG_QWORD
            errorCode = RegQueryValueEx_(hKey1, valueName$, 0, 0, @value, @bufferSize)
            If errorCode = #ERROR_SUCCESS
              result$ = Str(value)
            EndIf
          Case #REG_SZ, #REG_EXPAND_SZ   
            If bufferSize
              value = AllocateMemory(buffersize)
              If value
                errorCode = RegQueryValueEx_(hKey1, valueName$, 0, 0, value, @bufferSize)
                If errorCode = #ERROR_SUCCESS
                  result$ = PeekS(value)
                EndIf
                FreeMemory(value)
              Else
                errorCode = #ERROR_NOT_ENOUGH_MEMORY
              EndIf
            EndIf
        EndSelect
      EndIf
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn result$ 
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the DWORD value for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Procedure.i Registry_SetLongValue(hKey, subKey$, valueName$, value.l)
  Protected errorCode, hKey1
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_ALL_ACCESS, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      errorcode = RegSetValueEx_(hKey1, @valueName$, 0, #REG_DWORD, @value, SizeOf(LONG))
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the name for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Procedure.i Registry_SetNullValue(hKey, subKey$, valueName$)
  Protected errorCode, hKey1
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_ALL_ACCESS, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      errorcode = RegSetValueEx_(hKey1, @valueName$, 0, #REG_NONE, 0, 0)
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the QWORD value for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Procedure.i Registry_SetQuadValue(hKey, subKey$, valueName$, value.q)
  Protected errorCode, hKey1
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_ALL_ACCESS, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      errorcode = RegSetValueEx_(hKey1, @valueName$, 0, #REG_QWORD, @value, SizeOf(QUAD))
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the string value for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Procedure.i Registry_SetStringValue(hKey, subKey$, valueName$, value$)
  Protected errorCode, hKey1
  errorCode = RegOpenKeyEx_(hKey, subKey$, 0, #KEY_ALL_ACCESS, @hKey1)
  If errorCode = #ERROR_SUCCESS
    If hKey1
      errorcode = RegSetValueEx_(hKey1, @valueName$, 0, #REG_SZ, @value$, Len(value$)<<(SizeOf(Character)-1)+SizeOf(CHARACTER))
      RegCloseKey_(hKey1)
    EndIf
  EndIf
  Registry_INTERNAL_SetError(errorCode)
  ProcedureReturn errorCode
EndProcedure
;/////////////////////////////////////////////////////////////////////////////////
; IDE Options = PureBasic 4.60 (Windows - x86)
; Folding = ---
; EnableXP