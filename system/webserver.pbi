;- PBHGEN V5.42 [http://00laboratories.com/]
;- 'webserver.pb' header, generated at 21:52:17 25.09.2016.

CompilerIf #PB_Compiler_Module = ""
Declare.l WebServer_Initialize()
Declare.l WebServer_Update(hwnd.l)
Declare WebServer_SendTextHtml(*Client, HTML$)
Declare WebServer_SendTextCss(*Client, CSS$)
Declare WebServer_SendImagePng(*Client, *Buffer)
Declare WebServer_SendApplicationJavascript(*Client, JS$)
Declare WebServer_SendFontOpentype(*Client, *Buffer)
Declare WebServer_ReceiveData(*Client, *Out)
Declare.s WebServer_ParseRequest(hwnd.l, Client.l, HTTP$)
Declare.s WebServer_CreateWebsite()
Declare.s WebServer_Ajax_getSections(Path$)
Declare.s WebServer_Ajax_getSongs(Path$)
Declare.s WebServer_Ajax_setRating(hwnd.l, Path$)
Declare.s WebServer_Ajax_addRequest(Path$)
Declare.s WebServer_Ajax_previous(hwnd.l, Path$)
Declare.s WebServer_Ajax_play(hwnd.l, Path$)
Declare.s WebServer_Ajax_pause(hwnd.l, Path$)
Declare.s WebServer_Ajax_stop(hwnd.l, Path$)
Declare.s WebServer_Ajax_next(hwnd.l, Path$)
Declare.s WebServer_generateRequestsListJson(hwnd)
Declare.s WebServer_Ajax_main(hwnd.l, Path$)
CompilerEndIf