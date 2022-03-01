; ---------------------------------------
;  -- copyright © 00laboratories 2016 --
;  -- http://00laboratories.com/      --
; ---------------------------------------
IncludeFile #PB_Compiler_File + "i" ;- PBHGEN

;--------------------------------------------------------------------------------------------------

Procedure UniqueId() : Static id.q = 0 : id + 1 : ProcedureReturn id : EndProcedure

;--------------------------------------------------------------------------------------------------

Structure __Database_Request    ; a requested song that is to be played next.
  PlaylistIndex.l               ; the position in the playlist.
  RequestId.l                   ; to sort the requests in order.
EndStructure

Structure __Database_Song       ; a song in the playlist.
  PlaylistIndex.l               ; the position in the playlist.
  SongTitle.s                   ; the title of the song.
  ;SongFilePath.s                ; the complete file path of the song. (save RAM, do we really need this?)
  SongRating.l                  ; the rating of the song (0=not rated) from 1 through 5.
EndStructure

Structure __Database_Section    ; an album of sorts that catagorizes songs on the website.
  SongDirectory.s               ; the directory name of the section. (saves RAM, this is already the key so it's cleared after sorting)
  SectionId.l                   ; the id of the section.
  List Songs.__Database_Song()  ; the songs inside of this section.
EndStructure

;--------------------------------------------------------------------------------------------------

Global __Database_RequestsId.q = -1
Global NewList __Database_Requests.__Database_Request()
Global NewList __Database_Sections.__Database_Section()

;--------------------------------------------------------------------------------------------------
; Adds a song to the list of requests and returns the request id.
Procedure.l Database_RequestAdd(PlaylistIndex.l)
  AddElement(__Database_Requests())
  __Database_Requests()\PlaylistIndex = PlaylistIndex
  __Database_Requests()\RequestId = UniqueId()
  __Database_RequestsId = UniqueId()
  ProcedureReturn __Database_Requests()\RequestId
EndProcedure

;--------------------------------------------------------------------------------------------------
; Removes a request with the specified request id. Returns #True on success, #False if not found.
Procedure Database_RequestRemove()
  DeleteElement(__Database_Requests())
  __Database_RequestsId = UniqueId()
EndProcedure

;--------------------------------------------------------------------------------------------------
; Retrieves the playlist from Winamp with all required data and builds our internal data structure.
Procedure Database_PlaylistGenerate(hwnd.l)
  
  ; clear the database prior to generating it.
  Database_PlaylistClear()
  
  Protected NewMap UnsortedDatabaseSections.__Database_Section()
  
  ; get the playlist size from winamp.
  Protected PlayListIndex.l  = 0
  Protected PlayListLength.l = Winamp_GetPlaylistLength(hwnd)
  
  ; iterate every entry in the playlist.
  For PlayListIndex = 0 To PlayListLength - 1
    
    ; get the song information from winamp.
    Protected SongFilePath$  = Winamp_GetPlaylistFile(hwnd, PlayListIndex)
    Protected SongDirectory$ = GetParentDirectory(SongFilePath$)
    Protected SongTitle$     = Winamp_GetPlaylistTitle(hwnd, PlayListIndex)
    Protected SongRating     = Winamp_GetRating(hwnd, PlayListIndex)
    
    ; every song must have at least a rating of 1.
    If SongRating = 0 : Winamp_SetRating(hwnd, PlayListIndex, 1) : SongRating = 1 : EndIf
    
    ; create a section for the directory the song resides in if it does not yet exist.
    If Not FindMapElement(UnsortedDatabaseSections(), SongDirectory$)
      ; create the section.
      AddMapElement(UnsortedDatabaseSections(), SongDirectory$)
      UnsortedDatabaseSections()\SectionId = UniqueId()
      UnsortedDatabaseSections()\SongDirectory = SongDirectory$
    EndIf
    
    ; add the song to the section.
    AddElement(UnsortedDatabaseSections()\Songs())
    UnsortedDatabaseSections()\Songs()\PlaylistIndex = PlayListIndex
    UnsortedDatabaseSections()\Songs()\SongTitle     = SongTitle$
    UnsortedDatabaseSections()\Songs()\SongRating    = SongRating
  Next
  
  ; iterate all of the unsorted sections in the map.
  ForEach UnsortedDatabaseSections()
    ; create a new section in the list.
    AddElement(__Database_Sections())
    ; swap the values around.
    Swap UnsortedDatabaseSections()\SectionId,     __Database_Sections()\SectionId
    Swap UnsortedDatabaseSections()\SongDirectory, __Database_Sections()\SongDirectory
    CopyList(UnsortedDatabaseSections()\Songs(), __Database_Sections()\Songs())
    ; sort all of the songs in this section.
    SortStructuredList(__Database_Sections()\Songs(), #PB_Sort_Ascending | #PB_Sort_NoCase, OffsetOf(__Database_Song\SongTitle), #PB_String)
  Next
  
  ; delete the unsorted map.
  FreeMap(UnsortedDatabaseSections())
   
  ; sort all of the sections.
  SortStructuredList(__Database_Sections(), #PB_Sort_Ascending | #PB_Sort_NoCase, OffsetOf(__Database_Section\SongDirectory), #PB_String)
  
  ; notify that we are done.
  Beep_(7000,300)
  
EndProcedure

;--------------------------------------------------------------------------------------------------
; Clears all of the playlist information. Called internally prior to generation.
Procedure Database_PlaylistClear()
  ; clear out all of the sections.
  ClearList(__Database_Sections())
EndProcedure

;--------------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 58
; FirstLine = 54
; Folding = -
; Markers = 31
; EnableXP