﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, ignore
#Persistent
SetBatchLines, -1

if A_IsCompiled
debug:=0
Else
debug:=1

version:="0.0.4"
if A_Args.Length() > 0
{
	for n, param in A_Args
	{
		RegExMatch(param, "--out=(\w+)", outName)
		if(outName1=="version") {
			f := FileOpen("version.txt","w")
			f.Write(version)
			f.Close()
			ExitApp
		}
	}
}


#Include menu.ahk

UAC()

IniRead, lastUpdate, setting.ini, update, last, 0
today:=A_MM . A_DD
if(lastUpdate!=today) {
	MsgBox,,Update,Getting Update`n获取最新版本,2
	update()
} else {
	; MsgBox, already updated today
	ttm("Genshin Fishing automata Start`nv" version "`n原神钓鱼人偶启动")
}

#Include, Gdip_ImageSearch.ahk
#Include, Gdip.ahk

pToken := Gdip_Startup()

DllCall("QueryPerformanceFrequency", "Int64P", freq)
freq/=1000
genshin_window_exist()
{
	genshinHwnd := WinExist("ahk_exe GenshinImpact.exe")
	if not genshinHwnd
	{
		genshinHwnd := WinExist("ahk_exe YuanShen.exe")
	}
	return genshinHwnd
}
CoordMode, Pixel, Client
state:="unknown"
statePredict:="unknown"
stateUnknownStart:=0
SetTimer, test, -100
Return

ttm(txt, delay=1500)
{
	ToolTip, % txt
	SetTimer, kttm, % -delay
	Return
	kttm:
	ToolTip,
	Return
}

tt(txt, delay=2000)
{
	ToolTip, % txt, 1, 1
	SetTimer, ktt, % -delay
	Return
	ktt:
	ToolTip,
	Return
}
; 图标位置
; 右下角 w 82.5% h 87.5%
; Bar
; w 25%~75%
; h 0%~30%
; 浮漂
; w 25%~75%
; h 由 bar 参数 barY-10 ~ barY+30

genshin_hwnd := genshin_window_exist()
if(genshin_hwnd)
{
	; pBitmap:=Gdip_BitmapFromHWND(genshin_hwnd)
	; Gdip_SaveBitmapToFile(pBitmap, "output.jpg")
	; MsgBox, DONE

	hdc := GetDC(genshin_hwnd)
	CreateCompatibleDC(hdc)
	; Gdip_GraphicsFromHDC
	; Gdip_CreateBitmapFromHBITMAP
	; Gdip_SetBitmapToClipboard
}

getState:
ImageSearch, X, Y, winW*0.825, winH*0.875, winW, winH, *32 *TransFuchsia assets\ready.png
if(!ErrorLevel){
	state:="ready"
	statePredict:=state
	stateUnknownStart := 0
	return
}
ImageSearch, X, Y, winW*0.825, winH*0.875, winW, winH, *32 *TransFuchsia assets\reel.png
if(!ErrorLevel){
	state:="reel"
	statePredict:=state
	stateUnknownStart := 0
	return
}
ImageSearch, X, Y, winW*0.825, winH*0.875, winW, winH, *32 *TransFuchsia assets\casting.png
if(!ErrorLevel){
	state:="casting"
	statePredict:=state
	stateUnknownStart := 0
	return
}
state:="unknown"
if(stateUnknownStart == 0) {
	stateUnknownStart := A_TickCount
}
if(statePredict!="unknown" && A_TickCount - stateUnknownStart>=2000){
	statePredict:="unknown"
	Click, Up
}
Return

test:
genshin_hwnd := genshin_window_exist()
if(!genshin_hwnd){
	SetTimer, test, -800
	Return
}
if(WinExist("A") != genshin_hwnd)
{
	SetTimer, test, -500
	Return
}
WinGetPos, _, _, winW, winH, ahk_id %genshin_hwnd%
if(statePredict=="unknown" || statePredict=="ready")
{
	Gosub, getState
	if(statePredict!="unknown"){
		tt("state = " state "`nstatePredict = " statePredict "`n" winW "," winH)
	}
	if(statePredict=="reel"){
		SetTimer, test, -40
	} else {
		barY := 0
		SetTimer, test, -800
	}
	Return
} else if(statePredict=="casting") {
	Gosub, getState
	tt("state = " statePredict)
	if(statePredict=="reel") {
		Click, Down
		SetTimer, test, -40
	} else{
		SetTimer, test, -200
	}
	Return
} else if(statePredict=="reel") {
	DllCall("QueryPerformanceCounter", "Int64P",  startTime)
	if(!barY) {
		ImageSearch, _, barY, 0.33*winW, 0, 0.66*winW, 0.3*winH, *20 *TransFuchsia assets\bar.png
		if(ErrorLevel){
			barY := 0
		} else {
			Click, Up
			avrDetectTime:=[]
			leftX:=0
			rightX:=0
			curX:=0
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)
	} else {
		if(leftX > 0) {
			ImageSearch, leftX, leftY, leftX-25, barY-10, leftX+25+12, barY+30, *16 *TransFuchsia assets\left.png
		} else {
			ImageSearch, leftX, leftY, 0.33*winW, barY-10, 0.66*winW, barY+30, *16 *TransFuchsia assets\left.png
		}
		if(ErrorLevel){
			leftX := 0
			leftY := "Null"
		} else {
			leftPredictX := 2*leftX - leftXOld
			leftXOld := leftX
		}
		
		if(rightX > 0) {
			ImageSearch, rightX, rightY, rightX-25, barY-10, rightX+25+12, barY+30, *16 *TransFuchsia assets\right.png
		} else {
			ImageSearch, rightX, rightY, 0.33*winW, barY-10, 0.66*winW, barY+30, *16 *TransFuchsia assets\right.png
		}
		if(ErrorLevel){
			rightX := 0
			rightY := "Null"
		} else {
			rightPredictX := 2*rightX - rightXOld
			rightXOld := rightX
		}

		if(curX > 0) {
			ImageSearch, curX, curY, curX-50, barY-10, curX+50+11, barY+30, *16 *TransFuchsia assets\cur.png
		} else {
			ImageSearch, curX, curY, 0.33*winW, barY-10, 0.66*winW, barY+30, *16 *TransFuchsia assets\cur.png
		}
		if(ErrorLevel){
			curX := 0
			curY := "Null"
		} else {
			curPredictX := 2*curX - curXOld
			curXOld := curX
		}
		if(leftY == "Null" && rightY == "Null" && curY == "Null") {
			Gosub, getState
			Click, Up
		} else {
			if(leftX+rightX < leftXOld+rightXOld) {
				k := 0.2
			} else if(leftX+rightX > leftXOld+rightXOld) {
				k:= 0.8
			} else {
				k = 0.4
			}
			if(curPredictX<(k*rightPredictX + (1-k)*leftPredictX)){
				Click, Down
			} else {
				Click, Up
			}
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)

		detectTime:=(endTime-startTime)//freq
		if(avrDetectTime.Length()<8){
			avrDetectTime.Push(detectTime)
		} else {
			avrDetectTime.Pop()
			avrDetectTime.Push(detectTime)
		}
		sum := 0
		For index, value in avrDetectTime
			sum += value
		
		avrDetectMs := sum//avrDetectTime.Length()

		tt("barY = " barY "`n" "leftX = " leftX "`n" "rightX = " rightX "`n" "curX = " curX "`n" "barMove = " (leftX+rightX)-(leftXOld+rightXOld) "`n" state "`n" avrDetectMs "ms")
	}
	lastTime:=(endTime-startTime)//freq
	if(lastTime>60) {
		SetTimer, test, -10
	} else {
		SetTimer, test, % lastTime-70
	}
	Return
}

Return

donate:
Run, https://ko-fi.com/xianii
Return
pages:
Run, https://github.com/Nigh/Genshin-fishing
Return
exit:
ExitApp
donothing:
Return

#If debug
F5::ExitApp
F6::Reload
#If

update(){
	global
	req := ComObjCreate("Msxml2.XMLHTTP")
	; https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/version.txt
	; https://github.com/Nigh/Genshin-fishing/releases/latest/download/version.txt
	req.open("GET", "https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/version.txt", true)
	req.onreadystatechange := Func("updateReady")
	req.send()
}
updateReady(){
	global req, version
    if (req.readyState != 4)  ; Not done yet.
        return
    if (req.status == 200){ ; OK.
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", verNow)
		RegExMatch(req.responseText, "(\d+)\.(\d+)\.(\d+)", verNew)
		if(verNow1*10000+verNow2*100+verNow3<verNew1*10000+verNew2*100+verNew3) {
			MsgBox, 0x24, Download, % "Found new version " req.responseText ", download?`n`n发现新版本 " req.responseText " 是否下载?"
			IfMsgBox Yes
			{
				UrlDownloadToFile, https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/GenshinFishing.zip, ./GenshinFishing.zip
				if(ErrorLevel) {
					MsgBox, 16,, % "Download failed`n下载失败"
				} else {
					MsgBox, ,, % "File saved as GenshinFishing.zip`n更新下载完成 GenshinFishing.zip`n`nProgram will exit now`n软件即将退出", 2
					IniWrite, % A_MM A_DD, setting.ini, update, last
					ExitApp
				}
			}
		} else {
			MsgBox, ,, % "Current version: v" version "`n`nIt is the latest version`n`n软件已是最新版本", 2
			IniWrite, % A_MM A_DD, setting.ini, update, last
		}
	} else {
        MsgBox, 16,, % "Update failed`n`n更新失败`n`nStatus=" req.status
	}
}
UAC()
{
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		ExitApp
	}
}