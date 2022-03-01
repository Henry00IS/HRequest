; ---------------------------------------
;  -- Winamp Library                  --
;  -- copyright © 00laboratories 2013 --
;  -- http://00laboratories.com/      --
; ---------------------------------------
XIncludeFile #PB_Compiler_File + "i" ;- PBHGEN

Enumeration
  #WINAMP_IPC_GETVERSION = 0
  #WINAMP_IPC_GETVERSIONSTRING = 1
  #WINAMP_IPC_ENQUEUEFILE = 100
  #WINAMP_IPC_DELETE = 101
  #WINAMP_IPC_CHDIR = 103
  #WINAMP_IPC_ISPLAYING = 104
  #WINAMP_IPC_GETOUTPUTTIME = 105
  #WINAMP_IPC_JUMPTOTIME = 106
  #WINAMP_IPC_SETPANNING = 123
  #WINAMP_IPC_WRITEPLAYLIST = 120
  #WINAMP_IPC_SETPLAYLISTPOS = 121
  #WINAMP_IPC_SETVOLUME = 122
  #WINAMP_IPC_GETLISTLENGTH = 124
  #WINAMP_IPC_GETLISTPOS = 125
  #WINAMP_IPC_GETPLAYLISTFILE = 211
  #WINAMP_IPC_GETPLAYLISTTITLE = 212
  #WINAMP_IPC_GETPLAYLISTTITLEW = 213
  #WINAMP_IPC_CHANGECURRENTFILE = 245
  #WINAMP_IPC_GET_SHUFFLE = 250
  #WINAMP_IPC_GET_REPEAT = 251
  #WINAMP_IPC_SET_SHUFFLE = 252
  #WINAMP_IPC_SET_REPEAT = 253
  #WINAMP_IPC_GETREGISTEREDVERSION = 770
  
  ; 2016
  #IPC_REGISTER_WINAMP_IPCMESSAGE = 65536
  #ML_IPC_PL_SETRATING = $902
  #ML_IPC_PL_GETRATING = $903
EndEnumeration

#WM_ML_IPC = #WM_USER + $1000
Global MediaLibraryHwnd = 0

; Returns the current Winamp version
Procedure.i Winamp_GetVersion(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GETVERSION)
EndProcedure

; Returns the current Winamp version as string
Procedure.s Winamp_GetVersionString(hwnd.l)
  ProcedureReturn PeekS(SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GETVERSIONSTRING), #PB_Any, #PB_Ascii)
EndProcedure

; Opens the Winamp Preferences and shows the Winamp Pro page
Procedure.i Winamp_GetRegisteredVersion(hwnd.l)
  SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GETREGISTEREDVERSION)
EndProcedure

; ---------------------------------------

Structure enqueueFileWithMetaStruct
  *filename
  *title
  length.i
EndStructure

; Enqueues a file to the playlist
Procedure.i Winamp_EnqueueFile(hwnd.l, filename.s, title.s, length.i)
  eFWMS.enqueueFileWithMetaStruct
  eFWMS\filename = @filename
  eFWMS\title = @title
  eFWMS\length = length
  SendMessage_(hwnd, #WM_USER, @eFWMS, #WINAMP_IPC_ENQUEUEFILE)
EndProcedure

; Clear Winamp's internal playlist
Procedure.i Winamp_Delete(hwnd.l)
  SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_DELETE)
EndProcedure

; Go to previous song (simulating hitting the previous button)
Procedure.i Winamp_Previous(hwnd.l)
  SendMessage_(hwnd, #WM_COMMAND, 40044+0, 0)
EndProcedure

; Pause/Continue playback (simulating hitting the pause button)
Procedure.i Winamp_Pause(hwnd.l)
  SendMessage_(hwnd, #WM_COMMAND, 40044+2, 0)
EndProcedure

; Stop playback (simulating hitting the stop button)
Procedure.i Winamp_Stop(hwnd.l)
  SendMessage_(hwnd, #WM_COMMAND, 40044+3, 0)
EndProcedure

Procedure.i Winamp_Next(hwnd.l)
  SendMessage_(hwnd, #WM_COMMAND, 40044+4, 0)
EndProcedure

; Start playback (simulating hitting the play button)
Procedure.i Winamp_Play(hwnd.l)
  SendMessage_(hwnd, #WM_COMMAND, 40044+1, 0)
EndProcedure

; Make Winamp change to a different directory
Procedure.i Winamp_ChDir(hwnd.l, directory.s)
  cds.COPYDATASTRUCT
  cds\dwData = #WINAMP_IPC_CHDIR
  cds\lpData = @directory
  cds\cbData = Len(directory)+1
  SendMessage_(hwnd, #WM_COPYDATA, 0, @cds)
EndProcedure

; Retrieve whether Winamp is playing a song
Procedure.i Winamp_IsPlaying(hwnd.l)
  status.i = SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_ISPLAYING)
  If status = 1
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; Retrieve whether Winamp is paused
Procedure.i Winamp_IsPaused(hwnd.l)
  status.i = SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_ISPLAYING)
  If status = 3
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; Retrieve current track playing position
Procedure.i Winamp_GetOutputPosition(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GETOUTPUTTIME)
EndProcedure

; Retrieve current track length in seconds
Procedure.i Winamp_GetOutputLengthSeconds(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 1, #WINAMP_IPC_GETOUTPUTTIME)
EndProcedure

; Retrieve current track length in miliseconds
Procedure.i Winamp_GetOutputLengthMiliseconds(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 2, #WINAMP_IPC_GETOUTPUTTIME)
EndProcedure

; Set current track playing position
;   Returns -1 if Winamp is not playing, 1 on end of file, or 0 if it was successful
Procedure.i Winamp_SetOutputPosition(hwnd.l, miliseconds.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, miliseconds, #WINAMP_IPC_JUMPTOTIME)
EndProcedure

; It will set the current position in the playlist
Procedure.i Winamp_SetPlaylistPos(hwnd.l, position.l)
  SendMessage_(hwnd, #WM_USER, position, #WINAMP_IPC_SETPLAYLISTPOS)
EndProcedure

; Change the volume in Winamp (0-255)
Procedure.i Winamp_SetVolume(hwnd.l, volume.l)
  SendMessage_(hwnd, #WM_USER, volume, #WINAMP_IPC_SETVOLUME)
EndProcedure

; Return the volume in Winamp (0-255)
Procedure.i Winamp_GetVolume(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, -666, #WINAMP_IPC_SETVOLUME)
EndProcedure

; Change the panning in Winamp (-127 - +127)
Procedure.i Winamp_SetPanning(hwnd.l, panning.l)
  SendMessage_(hwnd, #WM_USER, panning, #WINAMP_IPC_SETPANNING)
EndProcedure

; Return the panning in Winamp (-127 - +127)
Procedure.i Winamp_GetPanning(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, -666, #WINAMP_IPC_SETPANNING)
EndProcedure

; Return number of tracks in playlist
Procedure.i Winamp_GetPlaylistLength(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GETLISTLENGTH)
EndProcedure

; Return current track position in playlist
Procedure.i Winamp_GetPlaylistPos(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GETLISTPOS)
EndProcedure

; Returns the status of the shuffle option
Procedure.i Winamp_GetOptionShuffle(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GET_SHUFFLE)
EndProcedure

; Returns the status of the repeat option
Procedure.i Winamp_GetOptionRepeat(hwnd.l)
  ProcedureReturn SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_GET_REPEAT)
EndProcedure

; Sets the status of the shuffle option
Procedure.i Winamp_SetOptionShuffle(hwnd.l, enabled.l)
  SendMessage_(hwnd, #WM_USER, enabled, #WINAMP_IPC_SET_SHUFFLE)
EndProcedure

; Sets the status of the repeat option
Procedure.i Winamp_SetOptionRepeat(hwnd.l, enabled.l)
  SendMessage_(hwnd, #WM_USER, enabled, #WINAMP_IPC_SET_REPEAT)
EndProcedure

; Retrieves the filename from a position in the playlist
Procedure.s Winamp_GetPlaylistFile(hwnd.l, position.l)
  ProcedureReturn PeekS(SendMessage_(hwnd, #WM_USER, position, #WINAMP_IPC_GETPLAYLISTFILE), #PB_Any, #PB_Ascii)
EndProcedure

; Retrieves the title from a position in the playlist
Procedure.s Winamp_GetPlaylistTitle(hwnd.l, position.l)
  ProcedureReturn PeekS(SendMessage_(hwnd, #WM_USER, position, #WINAMP_IPC_GETPLAYLISTTITLE), #PB_Any, #PB_Ascii)
EndProcedure

Procedure.s Winamp_GetPlaylistTitleW(hwnd.l, position.l)
  ProcedureReturn PeekS(SendMessage_(hwnd, #WM_USER, position, #WINAMP_IPC_GETPLAYLISTTITLEW), #PB_Any, #PB_UTF8)
EndProcedure

; Change the current playlist file
Procedure.i Winamp_SetPlaylistFile(hwnd.l, filename.s)
  SendMessage_(hwnd, #WM_USER, @filename, #WINAMP_IPC_CHANGECURRENTFILE)
EndProcedure

; Export the playlist to disk at '<winampdir>\\Winamp.m3u'
Procedure.i Winamp_WritePlaylist(hwnd.l)
  SendMessage_(hwnd, #WM_USER, 0, #WINAMP_IPC_WRITEPLAYLIST)
EndProcedure

; Structure ExtendedFileInfoStruct
;   *filename
;   *metadata
;   *ret
;   retlen.l
; EndStructure

Procedure winamp_library_pb_ToAscii(a$)
  buffer = AllocateMemory(Len(a$) + 1) 
  If buffer
    PokeS(buffer, a$, -1, #PB_Ascii)
  EndIf
  ProcedureReturn buffer
EndProcedure

Structure PlSetRating
  plentry.l
  rating.l
EndStructure
    
Procedure GetMLHwnd(hwnd.l)
  If MediaLibraryHwnd <> 0 : ProcedureReturn : EndIf
  
  *str = winamp_library_pb_ToAscii("LibraryGetWnd") ; memory leak (14 bytes) - can't free it because Winamp will crash.
  libhwndipc.l = SendMessage_(hwnd, #WM_USER, *str, #IPC_REGISTER_WINAMP_IPCMESSAGE)
  ;FreeMemory(*str)
  MediaLibraryHwnd = SendMessage_(hwnd, #WM_USER, -1, libhwndipc)
EndProcedure

Procedure.l Winamp_GetRating(hwnd.l, plentry.l) : GetMLHwnd(hwnd)
  ProcedureReturn SendMessage_(MediaLibraryHwnd, #WM_ML_IPC, plentry, #ML_IPC_PL_GETRATING)
EndProcedure

Procedure.l Winamp_SetRating(hwnd.l, plentry.l, rating.l) : GetMLHwnd(hwnd)
  plSR.PlSetRating
  plSR\plentry = plentry
  plSR\rating = rating
  SendMessage_(MediaLibraryHwnd, #WM_ML_IPC, @plSR, #ML_IPC_PL_SETRATING)
EndProcedure

; Procedure.s Winamp_GetExtendedFileInfo(hwnd.l, filename.s, metadata.s)
;   eFIS.ExtendedFileInfoStruct
;   eFIS\filename = winamp_library_pb_ToAscii(filename)
;   eFIS\metadata = winamp_library_pb_ToAscii(metadata)
;   eFIS\ret = AllocateMemory(64)
;   eFIS\retlen = 64
;   SendMessage_(hwnd, #WM_USER, @eFIS, #WINAMP_IPC_GET_EXTENDED_FILE_INFO)
;   
;   Res$ = PeekS(eFIS\ret, 1, #PB_Ascii)
;   FreeMemory(eFIS\filename)
;   FreeMemory(eFIS\metadata)
;   FreeMemory(eFIS\ret)
;   ;MessageRequester("hrequestA", Str(eFIS\ret))
;   ;MessageRequester("hrequestB", Str(eFIS\retlen))
;   ProcedureReturn Res$
; EndProcedure


; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 216
; FirstLine = 196
; Folding = -------
; EnableXP