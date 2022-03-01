;
;- 'registry_library.pb' Header, generated at 18:01:06 11/02/2013.
;

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
;/////////////////////////////////////////////////////////////////////////////////
;-INTERNAL FUNCTIONS.
;-====================
;/////////////////////////////////////////////////////////////////////////////////
Declare Registry_INTERNAL_SetError(errorCode)
;/////////////////////////////////////////////////////////////////////////////////
;-'PUBLIC' FUNCTIONS.
;-===================
;-Error functions.
;-------------------------
;/////////////////////////////////////////////////////////////////////////////////
Declare.i Registry_GetLastErrorCode()
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
Declare.s Registry_GetLastErrorDescription()
;/////////////////////////////////////////////////////////////////////////////////
;-Registry functions.
;------------------------------
;/////////////////////////////////////////////////////////////////////////////////
;The following function creates a new registry key and sets the error code as appropriate.
;If successful, returns either #REG_CREATED_NEW_KEY   or REG_OPENED_EXISTING_KEY to indicate that the key already existed.
Declare.i Registry_CreateSubKey(hKey, subKey$)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function deletes the specified key and all values and sets the error code as appropriate.
;If blnDeleteAllDescendantKeys is non-zero, all descendants of the given key are deleted.
;Otherwise, on Win NT systems, this function will fail if the specified key has subkeys.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Declare.i Registry_DeleteSubKey(hKey, subKey$, blnDeleteAllDescendantKeys = #False)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function deletes the specified key/value entry and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Declare.i Registry_DeleteSubKeyValue(hKey, subKey$, valueName$)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function returns #True or #False as appropriate.
Declare.i Registry_DoesSubKeyExist(hKey, subKey$)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function attempts to retrieve the specified value and sets the error code as appropriate.
;*type can hold the address of a variable to receive the type of data held with the registry key/value.
;Returns zero if the value is not of #REG_DWORD or #REG_QWORD format.
Declare.q Registry_GetIntegerValue(hKey, subKey$, valueName$, *type.INTEGER = 0)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function attempts to retrieve the specified value and sets the error code as appropriate.
;Any value retrieved from the registry is converted to a string.
;*type can hold the address of a variable to receive the type of data held with the registry key/value.
;In the case that a #REG_EXPAND_SZ string is returned, the user can use the ExpandEnvironmentStrings_() api function to expand the
;embedded environment variables.
Declare.s Registry_GetValueAsString(hKey, subKey$, valueName$, *type.INTEGER = 0)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the DWORD value for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Declare.i Registry_SetLongValue(hKey, subKey$, valueName$, value.l)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the name for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Declare.i Registry_SetNullValue(hKey, subKey$, valueName$)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the QWORD value for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Declare.i Registry_SetQuadValue(hKey, subKey$, valueName$, value.q)
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;The following function sets the string value for the specified key/value and sets the error code as appropriate.
;Returns #ERROR_SUCCESS or some Win error code which can be queried through the error functions.
Declare.i Registry_SetStringValue(hKey, subKey$, valueName$, value$)
;/////////////////////////////////////////////////////////////////////////////////
; IDE Options = PureBasic 4.60 (Windows - x86)
; Folding = ---
; EnableXP
