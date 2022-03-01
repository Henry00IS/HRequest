; ---------------------------------------
;  -- copyright © 00laboratories 2016 --
;  -- http://00laboratories.com/      --
; ---------------------------------------
IncludeFile #PB_Compiler_File + "i" ;- PBHGEN

;--------------------------------------------------------------------------------------------------

Structure __Network_ReceiveData
  *Buffer
  Size.l
EndStructure

;--------------------------------------------------------------------------------------------------

Global __WebServer_Port.l     = Val(GetRegistryKey(#HKEY_CURRENT_USER, "Software\00laboratories\winamp_hrequest", "WebsitePort", "8080"))
Global __WebServer_Password$  = GetRegistryKey(#HKEY_CURRENT_USER, "Software\00laboratories\winamp_hrequest", "WebsitePassword", "password")
Global __WebServer.l          = #Null

Structure __WebServer_Session
  SessionId.s
  Expire.q
EndStructure

; Global NewList __WebServer_Sessions.__WebServer_Session()
; 
; ;--------------------------------------------------------------------------------------------------
; ; Creates a new session for a user.
; Procedure WebServer_CreateSession()
;   AddElement(__WebServer_Sessions())
;   __WebServer_Sessions()\Expire = Date()
;   SessionId$ = Str(__WebServer_Sessions()\Expire)
;   __WebServer_Sessions()\SessionId = Fingerprint(@SessionId$, Len(SessionId$), #PB_Cipher_MD5, #PB_Ascii)
; EndProcedure

;--------------------------------------------------------------------------------------------------
; Starts the listening webserver and network environment etc.
Procedure.l WebServer_Initialize()
  
  ; initialize the networking environment.
  InitNetwork()
  
  ; start listening on the customizable port.
  __WebServer = CreateNetworkServer(#PB_Any, __WebServer_Port, #PB_Network_TCP)
EndProcedure

;--------------------------------------------------------------------------------------------------
; Callback from the thread to update the web-server.
Procedure.l WebServer_Update(hwnd.l)
  
  ; check whether there are unhandled networking events.
  Protected WebServer_Event.l  = NetworkServerEvent()
  Protected WebServer_Client.l = EventClient()
  
  ; process networking event.
  Select WebServer_Event
      
    ; new data was sent to the server.
    Case #PB_NetworkEvent_Data
      
      ; download the data.
      Protected NetworkData.__Network_ReceiveData
      WebServer_ReceiveData(WebServer_Client, @NetworkData)
      
      ; success.
      If NetworkData\Buffer <> #Null
        
        ; read the HTTP header.
        Protected HTTP$ = PeekS(NetworkData\Buffer, NetworkData\Size, #PB_Ascii) : FreeMemory(NetworkData\Buffer) ; Free RAM!
        
        ; parse the HTTP header and generate HTML.
        Protected HTML$ = WebServer_ParseRequest(hwnd, WebServer_Client, HTTP$)
        
      EndIf
  EndSelect
  
EndProcedure

;--------------------------------------------------------------------------------------------------
; Send a HTTP 200 OK reply containing HTML.
Procedure WebServer_SendTextHtml(*Client, HTML$)
  SendNetworkString(*Client, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: " + Str(Len(HTML$)) + #CRLF$ + #CRLF$ + HTML$, #PB_Ascii)
EndProcedure

Procedure WebServer_SendTextCss(*Client, CSS$)
  SendNetworkString(*Client, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/css" + #CRLF$ + "Content-Length: " + Str(Len(CSS$)) + #CRLF$ + #CRLF$ + CSS$, #PB_Ascii)
EndProcedure

Procedure WebServer_SendImagePng(*Client, *Buffer)
  Protected Size.l = PeekL(*Buffer) ; the first byte of an embedded file contains the length.
  Protected HTTP$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
  Protected *File = AllocateMemory(Len(HTTP$) + Size)
  PokeS(*File, HTTP$, #PB_Any, #PB_Ascii)
  CopyMemory(*Buffer +4, *File + Len(HTTP$), Size)
  SendNetworkData(*Client, *File, MemorySize(*File))
  FreeMemory(*File)
EndProcedure

Procedure WebServer_SendApplicationJavascript(*Client, JS$)
  SendNetworkString(*Client, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: application/javascript" + #CRLF$ + "Content-Length: " + Str(Len(JS$)) + #CRLF$ + #CRLF$ + JS$, #PB_Ascii)
EndProcedure

Procedure WebServer_SendFontOpentype(*Client, *Buffer)
  Protected Size.l = PeekL(*Buffer) ; the first byte of an embedded file contains the length.
  Protected HTTP$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: font/opentype" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
  Protected *File = AllocateMemory(Len(HTTP$) + Size)
  PokeS(*File, HTTP$, #PB_Any, #PB_Ascii)
  CopyMemory(*Buffer +4, *File + Len(HTTP$), Size)
  SendNetworkData(*Client, *File, MemorySize(*File))
  FreeMemory(*File)
EndProcedure

;--------------------------------------------------------------------------------------------------
; Very advanced receiving procedure for PureBasic.
Procedure WebServer_ReceiveData(*Client, *Out.__Network_ReceiveData)
  Protected ReceivedBytes = 32
  *Out\Buffer = AllocateMemory(32)
  *Out\Size = 32
  
  ; download 32 bytes and continue until we received all of the data.
  Repeat
    ReceivedBytes = ReceiveNetworkData(*Client, *Out\Buffer + (*Out\Size - 32), 32)
    ; <!> connection lost.
    If ReceivedBytes = -1
      *Out\Size = -1
      FreeMemory(*Out\Buffer)
      *Out\Buffer = 0
      Break
    EndIf
    ; <!> more data available.
    If ReceivedBytes = 32
      ; more data is available so download (the remainder or) 32 bytes to the buffer.
      *Out\Size + 32
      *Out\Buffer = ReAllocateMemory(*Out\Buffer, *Out\Size)
    Else
      Break
    EndIf
  ForEver
EndProcedure

;--------------------------------------------------------------------------------------------------

Procedure.s WebServer_ParseRequest(hwnd.l, Client.l, HTTP$)
  Path$ = Left(HTTP$, FindString(HTTP$, #CRLF$))
  
  If FindString(Path$, "/css/bootstrap.min.css")
    WebServer_SendTextCss(Client, PeekS(?website_css_bootstrap_min_css, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/css/bootstrap.min.css.map")
    WebServer_SendTextCss(Client, PeekS(?website_css_bootstrap_min_css_map, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/css/bootstrap-theme.min.css")
    WebServer_SendTextCss(Client, PeekS(?website_css_bootstrap_theme_min_css, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/css/bootstrap-theme.min.css.map")
    WebServer_SendTextCss(Client, PeekS(?website_css_bootstrap_theme_min_css_map, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/css/hover-min.css")
    WebServer_SendTextCss(Client, PeekS(?website_css_hover_min_css, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/css/ladda-themeless.min.css")
    WebServer_SendTextCss(Client, PeekS(?website_css_ladda_themeless_min_css, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/fonts/glyphicons-halflings-regular.eot")
    WebServer_SendFontOpentype(Client, ?website_fonts_glyphicons_halflings_regular_eot)
  ElseIf FindString(Path$, "/fonts/glyphicons-halflings-regular.svg")
    WebServer_SendFontOpentype(Client, ?website_fonts_glyphicons_halflings_regular_svg)
  ElseIf FindString(Path$, "/fonts/glyphicons-halflings-regular.ttf")
    WebServer_SendFontOpentype(Client, ?website_fonts_glyphicons_halflings_regular_ttf)
  ElseIf FindString(Path$, "/fonts/glyphicons-halflings-regular.woff")
    WebServer_SendFontOpentype(Client, ?website_fonts_glyphicons_halflings_regular_woff)
  ElseIf FindString(Path$, "/fonts/glyphicons-halflings-regular.woff2")
    WebServer_SendFontOpentype(Client, ?website_fonts_glyphicons_halflings_regular_woff2)
  ElseIf FindString(Path$, "/img/rating-gold.png")
    WebServer_SendImagePng(Client, ?website_img_rating_gold_png)
  ElseIf FindString(Path$, "/img/rating-silver.png")
    WebServer_SendImagePng(Client, ?website_img_rating_silver_png)
  ElseIf FindString(Path$, "/js/bootstrap.min.js")
    WebServer_SendApplicationJavascript(Client, PeekS(?website_js_bootstrap_min_js, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/js/hrequest.js")
    WebServer_SendApplicationJavascript(Client, PeekS(?website_js_hrequest_js, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/js/jquery.min.js")
    WebServer_SendApplicationJavascript(Client, PeekS(?website_js_jquery_min_js, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/js/ladda.min.js")
    WebServer_SendApplicationJavascript(Client, PeekS(?website_js_ladda_min_js, #PB_Any, #PB_Ascii))
  ElseIf FindString(Path$, "/js/spin.min.js")
    WebServer_SendApplicationJavascript(Client, PeekS(?website_js_spin_min_js, #PB_Any, #PB_Ascii))
    
  ElseIf FindString(Path$, "/database.getSections/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_getSections(Path$))
  ElseIf FindString(Path$, "/database.getSongs/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_getSongs(Path$))
  ElseIf FindString(Path$, "/database.setRating/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_setRating(hwnd, Path$))
  ElseIf FindString(Path$, "/database.addRequest/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_addRequest(Path$))
    
  ElseIf FindString(Path$, "/winamp.previous/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_previous(hwnd, Path$))
  ElseIf FindString(Path$, "/winamp.play/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_play(hwnd, Path$))
  ElseIf FindString(Path$, "/winamp.pause/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_pause(hwnd, Path$))
  ElseIf FindString(Path$, "/winamp.stop/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_stop(hwnd, Path$))
  ElseIf FindString(Path$, "/winamp.next/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_next(hwnd, Path$))
    
  ElseIf FindString(Path$, "/hrequest.main/")
    WebServer_SendTextHtml(Client, WebServer_Ajax_main(hwnd, Path$))
  Else
    WebServer_SendTextHtml(Client, WebServer_CreateWebsite())
  EndIf
    
EndProcedure

;--------------------------------------------------------------------------------------------------
; Creates the foundation for the entire page.
Procedure.s WebServer_CreateWebsite()
  ProcedureReturn PeekS(?website_design_htm, #PB_Any, #PB_Ascii)
EndProcedure

Macro Quote : Chr(34) : EndMacro

;--------------------------------------------------------------------------------------------------
; Retrieves a list of all sections.
Procedure.s WebServer_Ajax_getSections(Path$)
  Protected Result$ = "["
  ; iterate all of the sections in the database.
  ForEach __Database_Sections()
    Result$ + "{" + Quote + "id" + Quote + ":" + Str(__Database_Sections()\SectionId) + "," + Quote + "name" + Quote + ":" + Quote + EscapeString(__Database_Sections()\SongDirectory, #PB_String_EscapeXML) + Quote + "},"
  Next
  ProcedureReturn Left(Result$, Len(Result$) - 1) + "]"
EndProcedure

;--------------------------------------------------------------------------------------------------
; Retrieves a list of all songs in a section.
Procedure.s WebServer_Ajax_getSongs(Path$)
  Protected SectionId.l = Val(StringField(Path$, 3, "/"))
  Protected Result$ = "["
  Protected FoundSongs.a = #False
  ; iterate all of the sections in the database.
  ForEach __Database_Sections()
    ; find the desired section.
    If __Database_Sections()\SectionId = SectionId
      ; iterate all of the songs in the section.
      ForEach __Database_Sections()\Songs()
        FoundSongs = #True
        Result$ + "{" + Quote + "id" + Quote + ":" + Str(__Database_Sections()\Songs()\PlaylistIndex) + "," + Quote + "name" + Quote + ":" + Quote + EscapeString(__Database_Sections()\Songs()\SongTitle, #PB_String_EscapeXML) + Quote + "," + Quote + "rating" + Quote + ":" + Quote + Str(__Database_Sections()\Songs()\SongRating) + Quote + "},"
      Next
      Break
    EndIf
  Next
  ; must have found some songs for this string manipulation to work.
  If FoundSongs
    ProcedureReturn Left(Result$, Len(Result$) - 1) + "]"
  EndIf
  ; return empty array.
  ProcedureReturn "[]"
EndProcedure

;--------------------------------------------------------------------------------------------------
; Sets the rating of a song
Procedure.s WebServer_Ajax_setRating(hwnd.l, Path$)
  Protected SongId.l = Val(StringField(Path$, 3, "/"))
  Protected Rating.l = Val(StringField(Path$, 4, "/"))
  Winamp_SetRating(hwnd, SongId, Rating)
  ; find the song in the database.
  ForEach __Database_Sections()
    ForEach __Database_Sections()\Songs()
      If __Database_Sections()\Songs()\PlaylistIndex = SongId
        __Database_Sections()\Songs()\SongRating = Rating
        Break 2
      EndIf
    Next
  Next
  ; return empty array.
  ProcedureReturn "[]"
EndProcedure

;--------------------------------------------------------------------------------------------------

Procedure.s WebServer_Ajax_addRequest(Path$)
  Protected SongId.l = Val(StringField(Path$, 3, "/"))
  Database_RequestAdd(SongId)
  ; make the famous noise.
  Beep_(7000,300)
  ; return empty array.
  ProcedureReturn "[]"
EndProcedure

;--------------------------------------------------------------------------------------------------

Procedure.s WebServer_Ajax_previous(hwnd.l, Path$)
  Winamp_Previous(hwnd)
  ProcedureReturn "[]"
EndProcedure

Procedure.s WebServer_Ajax_play(hwnd.l, Path$)
  Winamp_Play(hwnd)
  ProcedureReturn "[]"
EndProcedure

Procedure.s WebServer_Ajax_pause(hwnd.l, Path$)
  Winamp_Pause(hwnd)
  ProcedureReturn "[]"
EndProcedure

Procedure.s WebServer_Ajax_stop(hwnd.l, Path$)
  Winamp_Stop(hwnd)
  ProcedureReturn "[]"
EndProcedure

Procedure.s WebServer_Ajax_next(hwnd.l, Path$)
  Winamp_Next(hwnd)
  ProcedureReturn "[]"
EndProcedure

;--------------------------------------------------------------------------------------------------
; Create a list of all the active requests.
Procedure.s WebServer_generateRequestsListJson(hwnd)
  Protected Result$ = "["
  Protected FoundSongs.a = #False
  ; iterate all of the requests in the database.
  ForEach __Database_Requests()
    FoundSongs = #True
    Result$ + "{" + Quote + "id" + Quote + ":" + Str(__Database_Requests()\RequestId) + "," + Quote + "name" + Quote + ":" + Quote + EscapeString(Winamp_GetPlaylistTitle(hwnd, __Database_Requests()\PlaylistIndex), #PB_String_EscapeXML) + Quote + "," + Quote + "rating" + Quote + ":" + Quote + Str(Winamp_GetRating(hwnd, __Database_Requests()\PlaylistIndex)) + Quote + "},"
  Next
  ; must have found some songs for this string manipulation to work.
  If FoundSongs
    ProcedureReturn Left(Result$, Len(Result$) - 1) + "]"
  EndIf
  ; return empty array.
  ProcedureReturn "[]"
EndProcedure

;--------------------------------------------------------------------------------------------------
Global WebServer_Ajax_main_PreviousSong.l = -1
Global WebServer_Ajax_main_CurrentSectionId.l = -1
Global WebServer_Ajax_main_CurrentSectionName$ = ""
;--------------------------------------------------------------------------------------------------
; The main update loop with the server. We can give out tasks to the client here.
Procedure.s WebServer_Ajax_main(hwnd.l, Path$)
  Protected Result$ = "[{"
  Protected CurrentSong.l = Winamp_GetPlaylistPos(hwnd)
  
  ; make sure songs are loaded just so winamp doesn't crash on us.
  If CurrentSong = -1 Or Winamp_GetPlaylistLength(hwnd) <= 0
    Result$ + Quote + "task" + Quote + ":" + Quote + "error" + Quote
    
  ; general update with all statistics.
  Else
    
    ; if the song has changed (only executed once).
    If CurrentSong <> WebServer_Ajax_main_PreviousSong
      WebServer_Ajax_main_PreviousSong = CurrentSong
      WebServer_Ajax_main_CurrentSectionId = -1
      WebServer_Ajax_main_CurrentSectionName$ = ""
      ; find the section the song resides in.
      ForEach __Database_Sections()
        ForEach __Database_Sections()\Songs()
          If __Database_Sections()\Songs()\PlaylistIndex = CurrentSong
            WebServer_Ajax_main_CurrentSectionId = __Database_Sections()\SectionId
            WebServer_Ajax_main_CurrentSectionName$ = __Database_Sections()\SongDirectory
            Break 2
          EndIf
        Next
      Next
    EndIf
    
    Result$ + Quote + "task" + Quote + ":" + Quote + "update" + Quote + ","
    Result$ + Quote + "sectionId" + Quote + ":" + Quote + Str(WebServer_Ajax_main_CurrentSectionId) + Quote + ","
    Result$ + Quote + "sectionName" + Quote + ":" + Quote + WebServer_Ajax_main_CurrentSectionName$ + Quote + ","
    Result$ + Quote + "songId" + Quote + ":" + Quote + Str(CurrentSong) + Quote + ","
    Result$ + Quote + "songPosition" + Quote + ":" + Quote + Str(Winamp_GetOutputPosition(hwnd) / 1000) + Quote + ","
    Result$ + Quote + "songLength" + Quote + ":" + Quote + Winamp_GetOutputLengthSeconds(hwnd) + Quote + ","
    Result$ + Quote + "songRating" + Quote + ":" + Quote + Str(Winamp_GetRating(hwnd, CurrentSong)) + Quote + ","
    
    Result$ + Quote + "songName" + Quote + ":" + Quote + EscapeString(Winamp_GetPlaylistTitle(hwnd, CurrentSong), #PB_String_EscapeXML) + Quote + ","
    
    Result$ + Quote + "requestsId" + Quote + ":" + Quote + Str(__Database_RequestsId) + Quote + ","
    Result$ + Quote + "requests" + Quote + ":" + WebServer_generateRequestsListJson(hwnd)
  EndIf

  ProcedureReturn Result$ + "}]"
EndProcedure

UndefineMacro Quote
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 320
; FirstLine = 320
; Folding = ----
; EnableXP