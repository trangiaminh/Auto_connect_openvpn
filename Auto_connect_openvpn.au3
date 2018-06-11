#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=AutoIt_Main_v10_48x48_RGB-A.ico
#AutoIt3Wrapper_Outfile=Auto_connect_openvpn.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Auto connect OpenVPN. Made by Tran Gia Minh!
#AutoIt3Wrapper_Res_Description=Auto connect OpenVPN. Made by Tran Gia Minh!
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;*****************************************
;Auto_OpenVPN.au3 by TGMinh
;Created with ISN AutoIt Studio v. 1.06
;*****************************************
#include <Array.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include "lib\_GAuth.au3.au3"

Global $g_bRunning = False
Global $g_fileSetting = "setting.txt"

Global $g_openvpn_programName = "openvpn.exe"
Global $g_openvpnGUI_programName = "openvpn-gui.exe"

Global $g_SETTING_INDEX_ZBARIMG_CMD = 0
Global $g_SETTING_INDEX_PROGRAM_OPENVPNGUI = 1
Global $g_SETTING_INDEX_OVPN_FILENAME = 2
Global $g_SETTING_INDEX_ACCNAME = 3
Global $g_SETTING_INDEX_PASS = 4
Global $g_SETTING_INDEX_SECRETKEY = 5
Global $g_SETTING_TOTAL_ROWS = 6
Global $g_arraySettings[$g_SETTING_TOTAL_ROWS]

Global $g_TITLE_WND_OPENVPN_USER_PASS = "[REGEXPTITLE:OpenVPN - User Authentication.*]"
Global $g_CONTROL_TXT_USERNAME = "[CLASS:Edit; INSTANCE:1]"
Global $g_CONTROL_TXT_PASS = "[CLASS:Edit; INSTANCE:2]"
Global $g_CONTROL_BTN_OK = "[CLASS:Button; INSTANCE:2]"

Global $g_TITLE_APP = "Auto connect OpenVPN"
Global $g_AUTHOR = "Made by Tran Gia Minh!"

HotKeySet("!a", "StartAutoConnect")
HotKeySet("!s", "StopAutoConnect")
HotKeySet("!u", "InputUserName")
HotKeySet("!p", "InputPassword")
HotKeySet("!k", "InputSecretKey")
HotKeySet("!i", "ImportFromImageQR")
HotKeySet("!{F1}", "ShowHelp")
HotKeySet("!q", "Quit")

LoadSetting()
Local $toolTipText = $g_TITLE_APP & @CRLF & "Alt+F1: Show help" & @CRLF & $g_AUTHOR
TraySetToolTip($toolTipText)
TrayTip($g_TITLE_APP, $toolTipText, 10)
Sleep(1000)
StartAutoConnect()

While 1
	Sleep(100)
WEnd

Func StartAutoConnect()
	If Not $g_bRunning Then
		If CheckSetting() Then
			TrayTip($g_TITLE_APP, "Start auto connect OpenVPN", 10)
			TraySetToolTip($toolTipText & @CRLF & "Running ...")
			$g_bRunning = True
			While $g_bRunning
				$hWnd = WinGetHandle($g_TITLE_WND_OPENVPN_USER_PASS)
				If Not @error Then
					FillUserPass($hWnd)
					ProcessWait($g_openvpn_programName, 5)
				Else
					If Not ProcessExists($g_openvpn_programName) Then
						CloseOpenVPNGUI()
						If Not ProcessExists($g_openvpnGUI_programName) Then
							StartOpenVPNGUIWithConfig()
						EndIf
					EndIf
				EndIf
				Sleep(500)
			WEnd
		EndIf
		$g_bRunning = False
		TrayTip($g_TITLE_APP, "Stop auto connect OpenVPN!", 10)
		TraySetToolTip($toolTipText & @CRLF & "Stop auto connect OpenVPN!")
	EndIf
EndFunc   ;==>StartAutoConnect

Func StopAutoConnect()
	$g_bRunning = False
EndFunc   ;==>StopAutoConnect

Func StartOpenVPNGUIWithConfig()
	ShellExecute($g_arraySettings[$g_SETTING_INDEX_PROGRAM_OPENVPNGUI], '--connect "' & $g_arraySettings[$g_SETTING_INDEX_OVPN_FILENAME] & '"', "", "open", @SW_HIDE)
	Sleep(2000)
	ProcessWait($g_openvpn_programName, 3)
EndFunc   ;==>StartOpenVPNGUIWithConfig

Func CloseOpenVPNGUI()
	For $i = 1 To 3
		If Not ProcessExists($g_openvpnGUI_programName) Then
			Return True
		Else
			ProcessClose($g_openvpnGUI_programName)
			If Not @error Then
				Return True
			EndIf
		EndIf
		Sleep(1000)
	Next
	Return False
EndFunc   ;==>CloseOpenVPNGUI

Func FillUserPass($hWnd)
	ControlSetText($hWnd, "", $g_CONTROL_TXT_USERNAME, $g_arraySettings[$g_SETTING_INDEX_ACCNAME])
	Local $pass = $g_arraySettings[$g_SETTING_INDEX_PASS]
	If $pass = "" Then
		Local $secExpired = Mod(@SEC, 30)
		ConsoleWrite('$secExpired: ' & $secExpired & @CRLF)
		If $secExpired <= 4 And $secExpired > 0 Then
			Sleep($secExpired * 1000)
		EndIf
		$pass = _GenerateTOTP($g_arraySettings[$g_SETTING_INDEX_SECRETKEY])
	EndIf
	ConsoleWrite("Pass: " & $pass & @CRLF)
	ControlSetText($hWnd, "", $g_CONTROL_TXT_PASS, $pass)
	ControlClick($hWnd, "", $g_CONTROL_BTN_OK)
	TrayTip($g_TITLE_APP, "Filled user and pass.", 3)
	Sleep(7000)
EndFunc   ;==>FillUserPass

Func LoadSetting()
	Local $aArray = FileReadToArray($g_fileSetting)
	If Not @error And UBound($aArray) = $g_SETTING_TOTAL_ROWS Then
		$g_arraySettings = $aArray
	EndIf
EndFunc   ;==>LoadSetting

Func SaveSetting()
	Local $hFileOpen = FileOpen($g_fileSetting, 2)
	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred while opening file " & $g_fileSetting & ".")
		Return False
	EndIf
	For $i = 0 To $g_SETTING_TOTAL_ROWS - 1
		FileWriteLine($hFileOpen, $g_arraySettings[$i])
	Next
	FileClose($hFileOpen)
	Return True
EndFunc   ;==>SaveSetting

Func CheckSetting()
	If Not IsArray($g_arraySettings) Then
		Local $array[$g_SETTING_TOTAL_ROWS]
		$g_arraySettings = $array
	EndIf
	If $g_arraySettings[$g_SETTING_INDEX_ZBARIMG_CMD] = "" Then
		ChooseCmdQrReader()
		Sleep(1000)
	EndIf
	If $g_arraySettings[$g_SETTING_INDEX_PROGRAM_OPENVPNGUI] = "" Then
		ChooseProgramOpenVPNGUI()
		Sleep(1000)
	EndIf
	If $g_arraySettings[$g_SETTING_INDEX_OVPN_FILENAME] = "" Then
		ChooseConfigOVPN()
		Sleep(1000)
	EndIf
	If $g_arraySettings[$g_SETTING_INDEX_ACCNAME] = "" Then
		InputUserName()
		Sleep(1000)
	EndIf
	If $g_arraySettings[$g_SETTING_INDEX_PASS] = "" And $g_arraySettings[$g_SETTING_INDEX_SECRETKEY] = "" Then
		ConfigPassOrSecret()
		Sleep(1000)
	EndIf
	If $g_arraySettings[$g_SETTING_INDEX_ZBARIMG_CMD] <> "" And $g_arraySettings[$g_SETTING_INDEX_PROGRAM_OPENVPNGUI] <> "" And $g_arraySettings[$g_SETTING_INDEX_OVPN_FILENAME] <> "" And $g_arraySettings[$g_SETTING_INDEX_ACCNAME] <> "" And ($g_arraySettings[$g_SETTING_INDEX_PASS] <> "" Or $g_arraySettings[$g_SETTING_INDEX_SECRETKEY] <> "") Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CheckSetting

Func ChooseConfigOVPN()
	MsgBox($MB_SYSTEMMODAL, "Choose config OVPN", "Config VPN, which is selected, must be added in OpenVPN and ran before!")
	$sFilePath = ShowChooseFileDialog("Select config OVPN", "OVPN file (*.ovpn)")
	If $sFilePath Then
		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		Local $aPathSplit = _PathSplit($sFilePath, $sDrive, $sDir, $sFileName, $sExtension)
		$g_arraySettings[$g_SETTING_INDEX_OVPN_FILENAME] = $sFileName & $sExtension
		Local $msg = 'OVPN file name: ' & $g_arraySettings[$g_SETTING_INDEX_OVPN_FILENAME]
		ConsoleWrite($msg & @CRLF)
		TrayTip($g_TITLE_APP, $msg, 3)
		SaveSetting()
	EndIf
EndFunc   ;==>ChooseConfigOVPN

Func ChooseProgramOpenVPNGUI()
	$sFilePath = 'c:\Program Files\OpenVPN\bin\' & $g_openvpnGUI_programName
	If Not FileExists($sFilePath) Then
		$sFilePath = 'c:\Program Files (x86)\OpenVPN\bin\' & $g_openvpnGUI_programName
		If Not FileExists($sFilePath) Then
			$sFilePath = ShowChooseFileDialog("Select " & $g_openvpnGUI_programName & " file", $g_openvpnGUI_programName & "(" & $g_openvpnGUI_programName & ")")
		EndIf
	EndIf
	If $sFilePath Then
		$g_arraySettings[$g_SETTING_INDEX_PROGRAM_OPENVPNGUI] = $sFilePath
		Local $msg = 'Path ' & $g_openvpnGUI_programName & ': ' & $g_arraySettings[$g_SETTING_INDEX_PROGRAM_OPENVPNGUI]
		ConsoleWrite($msg & @CRLF)
		TrayTip($g_TITLE_APP, $msg, 3)
		SaveSetting()
	EndIf
EndFunc   ;==>ChooseProgramOpenVPNGUI

Func ChooseCmdQrReader()
	$sFilePath = @ScriptDir & '\bin\zbarimg.exe'
	If Not FileExists($sFilePath) Then
		$sFilePath = ShowChooseFileDialog("Select zbarimg.exe file", "ZbarImage (zbarimg.exe)")
	EndIf
	If $sFilePath Then
		$sFilePath = StringReplace($sFilePath, @ScriptDir & "\", "")
		$g_arraySettings[$g_SETTING_INDEX_ZBARIMG_CMD] = $sFilePath
		Local $msg = 'Path zbarimg.exe: ' & $g_arraySettings[$g_SETTING_INDEX_ZBARIMG_CMD]
		ConsoleWrite($msg & @CRLF)
		TrayTip($g_TITLE_APP, $msg, 3)
		SaveSetting()
	EndIf
EndFunc   ;==>ChooseCmdQrReader

Func InputUserName()
	Do
		$g_arraySettings[$g_SETTING_INDEX_ACCNAME] = InputBox("User name (OpenVPN)", "Please enter user name of OpenVPN account", "")
	Until $g_arraySettings[$g_SETTING_INDEX_ACCNAME] <> ""
	Local $msg = 'User name (OpenVPN): ' & $g_arraySettings[$g_SETTING_INDEX_ACCNAME]
	ConsoleWrite($msg & @CRLF)
	TrayTip($g_TITLE_APP, "Input username successfully!", 3)
	SaveSetting()
EndFunc   ;==>InputUserName

Func ConfigPassOrSecret()
	Do
		$choose = Int(InputBox("Input password / secret key", "1. Input password of OpenVPN account." & @CRLF & "2. Input secret key to generate password (Google Authenticator)" & @CRLF & "3. Import secret key from QR code (Google Authenticator)" & @CRLF & @CRLF & "Which one do you choose?", "1", "", 350))
	Until $choose >= 1 And $choose <= 3
	Switch $choose
		Case 1
			InputPassword()
		Case 2
			InputSecretKey()
		Case 3
			ImportFromImageQR()
	EndSwitch
EndFunc   ;==>ConfigPassOrSecret

Func InputPassword()
	Do
		$g_arraySettings[$g_SETTING_INDEX_PASS] = InputBox("Password (OpenVPN)", "Please enter password of OpenVPN account", "")
	Until $g_arraySettings[$g_SETTING_INDEX_PASS] <> ""
	Local $msg = 'Password (OpenVPN): ' & $g_arraySettings[$g_SETTING_INDEX_PASS]
	ConsoleWrite($msg & @CRLF)
	TrayTip($g_TITLE_APP, "Input password successfully!", 3)
	$g_arraySettings[$g_SETTING_INDEX_SECRETKEY] = ""
	SaveSetting()
EndFunc   ;==>InputPassword

Func InputSecretKey()
	Do
		$g_arraySettings[$g_SETTING_INDEX_SECRETKEY] = InputBox("Secret key", "Please enter secret key to generate password (Google Authenticator)", "")
	Until $g_arraySettings[$g_SETTING_INDEX_SECRETKEY] <> ""
	Local $msg = 'Secret key: ' & $g_arraySettings[$g_SETTING_INDEX_SECRETKEY]
	ConsoleWrite($msg & @CRLF)
	TrayTip($g_TITLE_APP, "Input secret key successfully!", 3)
	$g_arraySettings[$g_SETTING_INDEX_PASS] = ""
	SaveSetting()
EndFunc   ;==>InputSecretKey

Func ImportFromImageQR()
	$sFilePath = ShowChooseFileDialog("Select a image file", "Images (*.jpg;*.png;*.tiff)|All (*.*)")
	If $sFilePath Then
		Local $msg = 'Path QR code image: ' & $sFilePath
		ConsoleWrite($msg & @CRLF)
		TrayTip($g_TITLE_APP, $msg, 3)
		Local $sKey = GetSecretKeyFromImageQR($sFilePath)
		ConsoleWrite('Secret key: ' & $sKey & @CRLF)
		If StringLen($sKey) > 0 Then
			$g_arraySettings[$g_SETTING_INDEX_SECRETKEY] = $sKey
			$g_arraySettings[$g_SETTING_INDEX_PASS] = ""
			SaveSetting()
		EndIf
	EndIf
EndFunc   ;==>ImportFromImageQR

Func ShowChooseFileDialog($sMessage, $sFilters = "All (*.*)", $bMultiSelect = False, $sCurrentPath = @ScriptDir & "\")
	Local $iFlag = $FD_FILEMUSTEXIST
	If $bMultiSelect Then
		$iFlag += $FD_MULTISELECT
	EndIf
	Local $sFileSelectedPaths = FileOpenDialog($sMessage, $sCurrentPath, $sFilters, $iFlag)
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "", "No file was selected.")
		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)
	Else
		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)

		Local $aSelectedPaths = StringSplit($sFileSelectedPaths, "|", 2)
		If UBound($aSelectedPaths) > 0 Then
			If $bMultiSelect Then
				Return $aSelectedPaths
			Else
				Return $aSelectedPaths[0]
			EndIf
		EndIf
	EndIf
	Return Null
EndFunc   ;==>ShowChooseFileDialog

Func GetSecretKeyFromImageQR($sFilePath)
	Local $sFileQrText = 'qr.txt'
	Local $sFileCmd = "read_qr_code.bat"
	Local $sCmd = '"' & $g_arraySettings[$g_SETTING_INDEX_ZBARIMG_CMD] & '" -q "' & $sFilePath & '" >' & $sFileQrText
	FileWrite($sFileCmd, $sCmd)
	Local $msg = "Execute " & $sFileCmd & ": " & $sCmd
	ConsoleWrite($msg & @CRLF)
	TrayTip($g_TITLE_APP, $msg, 3)
	RunWait($sFileCmd, @ScriptDir, @SW_HIDE)
	If Not @error Then
		Local $qrText = FileRead($sFileQrText)
		ConsoleWrite("Qr text: " & $qrText)
		FileDelete($sFileQrText)
		FileDelete($sFileCmd)
		$aMatches = StringRegExp($qrText, "otpauth:\/\/totp\/(.*)\?secret=(.*)", 1)
		If Not @error And UBound($aMatches) > 1 Then
			Return $aMatches[1]
		EndIf
	EndIf
	Return ""
EndFunc   ;==>GetSecretKeyFromImageQR

Func ShowHelp()
	Local $msg = $g_TITLE_APP & " - " & $g_AUTHOR & @CRLF & @CRLF & "Alt+A: Start auto connect OpenVPN" & @CRLF & "Alt+S: Stop auto connect OpenVPN" & @CRLF & "Alt+U: Input username of OpenVPN account" & @CRLF & "Alt+P: Input password of OpenVPN account" & @CRLF & "Alt+K: Input secret key to generate password (Google Authenticator)" & @CRLF & "Alt+I: Import secret key from QR code (Google Authenticator)" & @CRLF & "Alt+Q: Quit"
	MsgBox($MB_SYSTEMMODAL, $g_TITLE_APP & " - Help", $msg)
EndFunc   ;==>ShowHelp

Func Quit()
	TrayTip($g_TITLE_APP, "Goodbye!!!", 3)
	Sleep(2000)
	Exit
EndFunc   ;==>Quit
