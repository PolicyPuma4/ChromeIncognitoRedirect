; Created by https://github.com/PolicyPuma4
; Official repository https://github.com/PolicyPuma4/ChromeIncognitoRedirect

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;@Ahk2Exe-ExeName ChromeIncognitoRedirect.exe
;@Ahk2Exe-SetMainIcon chrome_IDR_X003_INCOGNITO.ico

EnvGet, LOCALAPPDATA, LOCALAPPDATA
EnvGet, PROGRAMS, PROGRAMFILES
FLAG := A_Args[1]

INSTALL_PATH := LOCALAPPDATA "\Programs\ChromeIncognitoRedirect"
INSTALL_FULL_PATH := INSTALL_PATH "\ChromeIncognitoRedirect.exe"
if (not FLAG)
{
  REGISTERED_APPLICATIONS := {"HKEY_CURRENT_USER": "SOFTWARE\RegisteredApplications", "HKEY_LOCAL_MACHINE": "SOFTWARE\RegisteredApplications"}
  for TREE, KEY in REGISTERED_APPLICATIONS
  {
    Loop, Reg, % TREE "\" KEY
    {
      if (InStr(A_LoopRegName, "Google Chrome.", true) != 1)
      {
        continue
      }

      RegRead, KEY_VALUE, % TREE "\" KEY, % A_LoopRegName
      CHROME_CAPABILITIES := TREE "\" KEY_VALUE
      break
    }
  }

  if (not CHROME_CAPABILITIES)
  {
    MsgBox, Unable to find Google Chrome capabilities.
    ExitApp
  }

  FileCreateDir, % INSTALL_PATH
  FileCopy, % A_ScriptFullPath, % INSTALL_FULL_PATH

  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect, DisplayIcon, % """" INSTALL_FULL_PATH """"
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect, DisplayName, ChromeIncognitoRedirect
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect, InstallLocation, % """" INSTALL_PATH """"
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect, NoModify, 0x00000001
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect, NoRepair, 0x00000001
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect, UninstallString, % """" INSTALL_FULL_PATH """ uninstall"

  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RegisteredApplications, ChromeIncognitoRedirect, Software\Clients\StartMenuInternet\ChromeIncognitoRedirect\Capabilities

  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\ChromeIncognitoRedirectHTML,, ChromeIncognitoRedirect HTML Document
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\ChromeIncognitoRedirectHTML\Application, ApplicationName, ChromeIncognitoRedirect
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\ChromeIncognitoRedirectHTML\Application, ApplicationDescription, Redirects opened URLs and files in an incognito Google Chrome window.
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\ChromeIncognitoRedirectHTML\shell\open\command, , % """" INSTALL_FULL_PATH """ redirect ""`%1"""

  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect,, ChromeIncognitoRedirect
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\Capabilities, ApplicationDescription, Redirects opened URLs and files in an incognito Google Chrome window.
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\Capabilities, ApplicationIcon, % """" INSTALL_FULL_PATH """"
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\Capabilities, ApplicationName, ChromeIncognitoRedirect
  
  FILE_ASSOCIATIONS := []
  Loop, Reg, % CHROME_CAPABILITIES "\FileAssociations"
  {
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\Capabilities\FileAssociations, % A_LoopRegName, ChromeIncognitoRedirectHTML
  }

  URL_ASSOCIATIONS := []
  Loop, Reg, % CHROME_CAPABILITIES "\URLAssociations"
  {
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\Capabilities\URLAssociations, % A_LoopRegName, ChromeIncognitoRedirectHTML
  }
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\DefaultIcon, , % """" INSTALL_FULL_PATH """"
  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect\shell\open\command, , % """" INSTALL_FULL_PATH """ run"

  MsgBox, Install complete.

  ExitApp
}

if (FLAG = "uninstall")
{
  RegDelete, HKEY_CURRENT_USER\SOFTWARE\RegisteredApplications, ChromeIncognitoRedirect

  RegDelete, HKEY_CURRENT_USER\SOFTWARE\Classes\ChromeIncognitoRedirectHTML

  RegDelete, HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\ChromeIncognitoRedirect

  RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce, ChromeIncognitoRedirect, % """C:\Windows\System32\cmd.exe"" /c rmdir /q /s """ INSTALL_PATH """"

  RegDelete, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ChromeIncognitoRedirect

  MsgBox, Uninstall complete.

  ExitApp
}

CHROME_PATHS := [LOCALAPPDATA "\Google\Chrome\Application\chrome.exe", PROGRAMS "\Google\Chrome\Application\chrome.exe"]
for _, PATH in CHROME_PATHS
{
  if (FileExist(PATH))
  {
    CHROME := PATH
    break
  }
}
SplitPath, CHROME,, CHROME_PATH
if (not CHROME)
{
  MsgBox, Unable to find Google Chrome.
  ExitApp
}

if (FLAG = "run")
{
  Run, % CHROME " --profile-directory=""Default"" --incognito --no-default-browser-check", % CHROME_PATH

  ExitApp
}

ADDRESS := A_Args[2]
if (FLAG = "redirect")
{
  Run, % CHROME " --profile-directory=""Default"" --incognito --no-default-browser-check """ ADDRESS """", % CHROME_PATH

  ExitApp
}
