; ---------------------------------------
;  -- HRequest                        --
;  -- copyright © 00laboratories 2013 --
;  -- http://00laboratories.com/      --
; ---------------------------------------
XIncludeFile #PB_Compiler_File + "i" ;- PBHGEN

XIncludeFile "system/registry_library.pb"

XIncludeFile "system/winamp_plugin.pb"
XIncludeFile "system/winamp_library.pb"

XIncludeFile "system/timer_library.pb"

XIncludeFile "system/utility.pb"

XIncludeFile "system/database.pb"
XIncludeFile "system/webserver.pb"

;--------------------------------------------------------------------------------------------------

WinampPlugin\description = @"00laboratories music request system"

ProcedureC.i WinampPlugin_Init()
  BuildRegistry00() ; Build Registry Entries
  CreateThread(@WinampPlugin_Loop(), WinampPlugin\hwndParent)
EndProcedure

ProcedureC.i WinampPlugin_Conf()
  RunProgram(GetCurrentDirectory() + "Plugins\00laboratories\HRequestConfig.exe")
EndProcedure

ProcedureC.i WinampPlugin_Quit()
  
EndProcedure

;--------------------------------------------------------------------------------------------------

; the main processing thread.
Procedure.i WinampPlugin_Loop(hwnd.l)
  Static.l LastSong.l = -1
  Protected CurrentSong.l = -1
  
  ; initialize the database before starting the web-server.
  Database_PlaylistGenerate(hwnd)
  
  ; initialize the web-server.
  WebServer_Initialize()
  
  ; the main processing loop.
  Repeat
    
    ; update the web-server.
    WebServer_Update(hwnd)
    
    ; update the current song.
    CurrentSong = Winamp_GetPlaylistPos(hwnd)
    If CurrentSong <> LastSong
      LastSong = CurrentSong
      
      ; if there is a request
      If ListSize(__Database_Requests()) > 0
        FirstElement(__Database_Requests())
        
        LastSong = __Database_Requests()\PlaylistIndex
        Winamp_SetPlaylistPos(hwnd, __Database_Requests()\PlaylistIndex)
        Winamp_Play(hwnd)
        
        Database_RequestRemove()
      EndIf
      
    EndIf
    
    ; 100 requests per second.
    Delay(10)
    
  ForEver
;   
;   
;   
;   
;   Global NewList Requests.WA_Request()
;   PreviousPlaylistIndex.l = Winamp_GetPlaylistPos(hwnd)
;   TotalRequests.l = 0
;   
;   ; ---------------------------------------
;   ;  -- HTML WEBSERVER                  --
;   ; ---------------------------------------
;   InitNetwork()
;   
;   Port.l = Val(GetRegistryKey(#HKEY_CURRENT_USER, "Software\00laboratories\winamp_hrequest", "WebsitePort", "8080"))
;   Password$ = GetRegistryKey(#HKEY_CURRENT_USER, "Software\00laboratories\winamp_hrequest", "WebsitePassword", "password")
;   WSERVER.l = CreateNetworkServer(#PB_Any, Port, #PB_Network_TCP)
;   
;   While #True
;     
;     WSERVER_EVENT.l = NetworkServerEvent()
;     WSERVER_CLIENT.l = EventClient()
;     
;     Select WSERVER_EVENT
;         
;       ; New client has connected to the server
;       Case 1
;         
;       ; Data received from client
;       Case 2
;         
;         *RData = AllocateMemory(1024)
;         ReceiveNetworkData(WSERVER_CLIENT, *RData, 1024)
;         RData$ = PeekS(*RData, 1024, #PB_Ascii)
;         FreeMemory(*RData)
;         
;         If FindString(RData$, "/A/")
;           Line$ = Left(RData$, FindString(RData$, #CRLF$)) ; Get top line of request
;           Pass$ = StringField(Line$, 4, "/")
;           Line$ = StringField(Line$, 3, "/")
;           
;           If Pass$ = Password$
;             HTML$ = WinampPlugin_HTML_Section(hwnd, Val(Line$))
;             SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: " + Str(Len(HTML$)) + #CRLF$ + #CRLF$ + HTML$, #PB_Ascii)
;           Else
;             SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: 17" + #CRLF$ + #CRLF$ + "Invalid Password!", #PB_Ascii)
;           EndIf
;         ElseIf FindString(RData$, "/B/")
;           Line$ = Left(RData$, FindString(RData$, #CRLF$)) ; Get top line of request
;           Pass$ = StringField(Line$, 4, "/")
;           Line$ = StringField(Line$, 3, "/")
;           
;           If Pass$ = Password$
;             AddElement(Requests())
;             Requests()\PlaylistIndex = Val(Line$)
;             Requests()\InternalOrder = TotalRequests
;             TotalRequests +1
;             
;             Beep_(7000,300)
;           EndIf
;           
;           SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: 1" + #CRLF$ + #CRLF$ + "1", #PB_Ascii)
;         ElseIf FindString(RData$, "/C/")
;           Line$ = Left(RData$, FindString(RData$, #CRLF$)) ; Get top line of request
;           Pass$ = StringField(Line$, 4, "/")
;           Line$ = StringField(Line$, 3, "/")
;           
;           If Pass$ = Password$
;             Select Line$
;               Case "1" ; Previous Song
;                 Winamp_Previous(hwnd)
;               Case "2" ; Play Song
;                 Winamp_Play(hwnd)
;               Case "3" ; Pause/Continue Song
;                 Winamp_Pause(hwnd)
;               Case "4" ; Stop Song
;                 Winamp_Stop(hwnd)
;               Case "5" ; Next Song
;                 Winamp_Next(hwnd)
;             EndSelect
;           EndIf
;           
;           SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: 1" + #CRLF$ + #CRLF$ + "1", #PB_Ascii)
;         ElseIf FindString(RData$, "/D/")
;           Line$ = Left(RData$, FindString(RData$, #CRLF$)) ; Get top line of request
;           Pass$ = StringField(Line$, 3, "/")
;           
;           If Pass$ = Password$
;             HTML$ = WinampPlugin_HTML_Requests(hwnd)
;             SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: " + Str(Len(HTML$)) + #CRLF$ + #CRLF$ + HTML$, #PB_Ascii)
;           Else
;             SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: 17" + #CRLF$ + #CRLF$ + "Invalid Password!", #PB_Ascii)
;           EndIf
;           
;         ElseIf FindString(RData$, "/E/")
;           Line$ = Left(RData$, FindString(RData$, #CRLF$)) ; Get top line of request
;           Pass$ = StringField(Line$, 4, "/")
;           Song$ = StringField(Line$, 3, "/")
;           Rati$ = StringField(Line$, 5, "/")
;           
;           If Pass$ = Password$
;             Winamp_SetRating(hwnd, Val(Song$), Val(Rati$))
;             SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: 1" + #CRLF$ + #CRLF$ + "1", #PB_Ascii)
;           EndIf
;           
;         ElseIf FindString(RData$, "/img_previous")
;           SendImage_Previous(WSERVER_CLIENT)
;         ElseIf FindString(RData$, "/img_play")
;           SendImage_Play(WSERVER_CLIENT)
;         ElseIf FindString(RData$, "/img_pause")
;           SendImage_Pause(WSERVER_CLIENT)
;         ElseIf FindString(RData$, "/img_stop")
;           SendImage_Stop(WSERVER_CLIENT)
;         ElseIf FindString(RData$, "/img_next")
;           SendImage_Next(WSERVER_CLIENT)
;         ElseIf FindString(RData$, "/img_trackercur")
;           SendImage_Trackercur(WSERVER_CLIENT)
;         ElseIf FindString(RData$, "/img_tracker")
;           SendImage_Tracker(WSERVER_CLIENT)
;         Else
;           HTML$ = WinampPlugin_HTML_Home(hwnd)
;           SendNetworkString(WSERVER_CLIENT, "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Content-Length: " + Str(Len(HTML$)) + #CRLF$ + #CRLF$ + HTML$, #PB_Ascii)
;         EndIf
;         
;       ; Client disconnected from the server
;       Case 4
;         
;         
;     EndSelect
;     
;     
;     ; ---------------------------------------
;     ;  -- REQUEST SYSTEM                  --
;     ; ---------------------------------------
;     PlaylistPos.l = Winamp_GetPlaylistPos(hwnd)
;     
;     SortStructuredList(Requests(), #PB_Sort_Ascending, OffsetOf(WA_Request\InternalOrder), #PB_Long)
;     If FirstElement(Requests())
;       If PreviousPlaylistIndex <> PlaylistPos
;         
;         Winamp_SetPlaylistPos(hwnd, Requests()\PlaylistIndex)
;         Winamp_Play(hwnd)
;         PlaylistPos = Requests()\PlaylistIndex
;         
;         DeleteElement(Requests())
;         
;       EndIf
;     EndIf
;     
;     PreviousPlaylistIndex = PlaylistPos
;     
;     Delay(100)
;   Wend
  
EndProcedure

; Structure WA_Song
;   SongTitle.s
;   PlaylistIndex.l
;   SongFilePath.s
;   SongRating.l
; EndStructure
; 
; Structure WA_Section
;   SongDirectory.s
;   SectionIndex.l
;   List Songs.WA_Song()
; EndStructure
; 
; Procedure.s WinampPlugin_HTML_Home(hwnd.l)
;   
;   ; HTML Header
;   HTML$ = PeekS(?c_head, #PB_Any, #PB_Ascii)
; 
;   NewList SortedSections.WA_Section()
;   WinampPlugin_GetPlaylist(hwnd.l, SortedSections())
;   
;   ForEach SortedSections()
;     LINE$ = PeekS(?c_wind, #PB_Any, #PB_Ascii)
;     LINE$ = ReplaceString(LINE$, "[:SECTIONID:]", Str(SortedSections()\SectionIndex))
;     LINE$ = ReplaceString(LINE$, "[:CAPTION:]", SortedSections()\SongDirectory)
;     
;     HTML$ + LINE$
;   Next
;   
;   HTML$ + PeekS(?c_hend, #PB_Any, #PB_Ascii)
;   
;   ProcedureReturn HTML$
; EndProcedure
; 
; Procedure.s WinampPlugin_HTML_Section(hwnd.l, section.l)
;   
;   HTML$ = ""
;   
;   NewList SortedSections.WA_Section()
;   WinampPlugin_GetPlaylist(hwnd.l, SortedSections())
;   
;   SelectElement(SortedSections(), section -1) ; 0 indexed
;   
;   HTML$ + "				<table class=" + Chr(34) + "win_table" + Chr(34) + " border=" + Chr(34) + "1" + Chr(34) + ">"
;   
;   ForEach SortedSections()\Songs()
;     
;     Rating$ = "<table><tr>"
;     For i=1 To 5
;       IsStarSet$ = "star-unset"
;       If i <= SortedSections()\Songs()\SongRating
;         IsStarSet$ = "star-set"
;       EndIf
;       Rating$ + "<td id=" + Chr(34) + Str(SortedSections()\Songs()\PlaylistIndex) + "-" + Str(i) + Chr(34) + " class=" + Chr(34) + IsStarSet$ + Chr(34) + "><a href=" + Chr(34) + "javascript:hrequest.rate(" + Str(SortedSections()\Songs()\PlaylistIndex) + ", " + Str(i) + ");" + Chr(34) + ">" + "</a></td>"
;     Next
;     Rating$ + "</tr></table>"
;     
;     HTML$ + "					<tr><td><a href=" + Chr(34) + "javascript:hrequest.request(" + Str(SortedSections()\Songs()\PlaylistIndex) + ");" + Chr(34) + ">" + SortedSections()\Songs()\SongTitle + "</a></td><td>" + Rating$ + "</td></tr>"
;   Next
;   
;   HTML$ + "				</table>"
;   
;   ProcedureReturn HTML$
; EndProcedure
; 
; Procedure.s WinampPlugin_HTML_Requests(hwnd.l)
;   
;   HTML$ = ""
;   
;   ; Part [0]: Requests
;   SortStructuredList(Requests(), 0, OffsetOf(WA_Request\InternalOrder), #PB_Long)
;   HTML$ + "				<table class=" + Chr(34) + "win_table" + Chr(34) + " border=" + Chr(34) + "1" + Chr(34) + ">"
;   ForEach Requests()
;     HTML$ + "					<tr><td>" + Winamp_GetPlaylistTitle(hwnd, Requests()\PlaylistIndex) + "</td></tr>"
;   Next
;   HTML$ + "				</table>"
;   
;   ; Part [1.1]: Live Song Title
;   HTML$ + "[:SPLIT:]"
;   HTML$ + Winamp_GetPlaylistTitle(hwnd, Winamp_GetPlaylistPos(hwnd))
;   
;   ; Part [1.2]: Output Times
;   HTML$ + "[:]"
;   Pos1.l = Winamp_GetOutputPosition(hwnd)
;   Pos2.l = Winamp_GetOutputLengthSeconds(hwnd)
;   If Pos1 < 0 : Pos1 = 0 : EndIf
;   If Pos2 < 0 : Pos2 = 0 : EndIf
;   HTML$ + Str(Pos1) + "[:]" + Str(Pos2)
;   
;   ProcedureReturn HTML$
; EndProcedure
; 
; Procedure.l SendImage_Previous(WSERVER_CLIENT.l)
;   Size.l = 5061
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_previous, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; Procedure.l SendImage_Play(WSERVER_CLIENT.l)
;   Size.l = 3981
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_play, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; Procedure.l SendImage_Pause(WSERVER_CLIENT.l)
;   Size.l = 2363
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_pause, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; Procedure.l SendImage_Stop(WSERVER_CLIENT.l)
;   Size.l = 2322
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_stop, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; Procedure.l SendImage_Next(WSERVER_CLIENT.l)
;   Size.l = 5369
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_next, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; Procedure.l SendImage_Tracker(WSERVER_CLIENT.l)
;   Size.l = 5760
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_tracker, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; Procedure.l SendImage_Trackercur(WSERVER_CLIENT.l)
;   Size.l = 3089
;   HTML$ = "HTTP/1.0 200 OK" + #CRLF$ + "Content-Type: image/png" + #CRLF$ + "Content-Length: " + Str(Size) + #CRLF$ + #CRLF$
;   *Buffer = AllocateMemory(Len(HTML$) + Size)
;   PokeS(*Buffer, HTML$, #PB_Any, #PB_Ascii)
;   CopyMemory(?img_trackercur, *Buffer + Len(HTML$), Size)
;   SendNetworkData(WSERVER_CLIENT, *Buffer, Len(HTML$) + Size)
;   FreeMemory(*Buffer)
; EndProcedure
; 
; DataSection
;   HRequestConfig:
;   IncludeBinary "resources\HRequestConfig.exe"
;   c_head:
;   IncludeBinary "resources\c_head.htm"
;   c_hend:
;   IncludeBinary "resources\c_hend.htm"
;   c_wind:
;   IncludeBinary "resources\c_wind.htm"
;   img_next:
;   IncludeBinary "resources\img_next.png"
;   img_pause:
;   IncludeBinary "resources\img_pause.png"
;   img_play:
;   IncludeBinary "resources\img_play.png"
;   img_previous:
;   IncludeBinary "resources\img_previous.png"
;   img_stop:
;   IncludeBinary "resources\img_stop.png"
;   img_tracker:
;   IncludeBinary "resources\img_tracker.png"
;   img_trackercur:
;   IncludeBinary "resources\img_trackercur.png"
; EndDataSection

DataSection
  website_design_htm: : IncludeBinary "website\design.htm" : Data.a 0 ; Null Terminator
  website_css_bootstrap_min_css: : IncludeBinary "website\css\bootstrap.min.css" : Data.a 0 ; Null Terminator
  website_css_bootstrap_min_css_map: : IncludeBinary "website\css\bootstrap.min.css.map" : Data.a 0 ; Null Terminator
  website_css_bootstrap_theme_min_css: : IncludeBinary "website\css\bootstrap-theme.min.css" : Data.a 0 ; Null Terminator
  website_css_bootstrap_theme_min_css_map: : IncludeBinary "website\css\bootstrap-theme.min.css.map" : Data.a 0 ; Null Terminator
  website_css_hover_min_css: : IncludeBinary "website\css\hover-min.css" : Data.a 0 ; Null Terminator
  website_css_ladda_themeless_min_css: : IncludeBinary "website\css\ladda-themeless.min.css" : Data.a 0 ; Null Terminator
  website_fonts_glyphicons_halflings_regular_eot: : Data.l 20127 : IncludeBinary "website\fonts\glyphicons-halflings-regular.eot" : Data.a 0 ; Null Terminator
  website_fonts_glyphicons_halflings_regular_svg: : Data.l 108738 : IncludeBinary "website\fonts\glyphicons-halflings-regular.svg" : Data.a 0 ; Null Terminator
  website_fonts_glyphicons_halflings_regular_ttf: : Data.l 45404 : IncludeBinary "website\fonts\glyphicons-halflings-regular.ttf" : Data.a 0 ; Null Terminator
  website_fonts_glyphicons_halflings_regular_woff: : Data.l 23424 : IncludeBinary "website\fonts\glyphicons-halflings-regular.woff" : Data.a 0 ; Null Terminator
  website_fonts_glyphicons_halflings_regular_woff2: : Data.l 18028 : IncludeBinary "website\fonts\glyphicons-halflings-regular.woff2" : Data.a 0 ; Null Terminator
  website_img_rating_gold_png: : Data.l 2382 : IncludeBinary "website\img\rating-gold.png" : Data.a 0 ; Null Terminator
  website_img_rating_silver_png: : Data.l 1473 : IncludeBinary "website\img\rating-silver.png" : Data.a 0 ; Null Terminator
  website_js_bootstrap_min_js: : IncludeBinary "website\js\bootstrap.min.js" : Data.a 0 ; Null Terminator
  website_js_hrequest_js: : IncludeBinary "website\js\hrequest.js" : Data.a 0           ; Null Terminator
  website_js_jquery_min_js: : IncludeBinary "website\js\jquery.min.js" : Data.a 0 ; Null Terminator
  website_js_ladda_min_js: : IncludeBinary "website\js\ladda.min.js" : Data.a 0 ; Null Terminator
  website_js_spin_min_js: : IncludeBinary "website\js\spin.min.js" : Data.a 0 ; Null Terminator
EndDataSection
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 62
; FirstLine = 53
; Folding = -
; EnableXP