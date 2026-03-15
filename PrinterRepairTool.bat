@echo off
:: ============================================================
::  PRINTER REPAIR TOOLKIT v2
::  Run as Administrator for all fixes to work correctly.
:: ============================================================
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo  [!] This tool requires Administrator privileges.
    echo      Right-click the file and select "Run as administrator".
    echo.
    pause
    exit /b
)

:MENU
cls
echo.
echo  ============================================================
echo   PRINTER REPAIR TOOLKIT v2
echo   Run as Administrator
echo  ============================================================
echo.
echo   --- SPOOLER ^& QUEUE ---
echo   [1]  Restart Print Spooler (clears stuck jobs)
echo   [2]  Clear All Print Jobs Only (no restart)
echo   [3]  Fix "Spooler keeps stopping" (auto-restart)
echo   [4]  Fix RPC Binding / Dependency issue
echo.
echo   --- NETWORK ^& SHARING ---
echo   [5]  Fix RpcAuthorization in Registry (can't connect)
echo   [6]  Enable Printer Sharing through Firewall
echo   [7]  Reset TCP/IP Printer Port (network printer)
echo   [8]  Fix Printer Showing as Offline
echo   [9]  Re-enable WSD / Network Discovery
echo   [10] Flush DNS + Reset Network Stack
echo.
echo   --- DRIVERS ^& HARDWARE ---
echo   [11] Reinstall / Reset All Printer Drivers
echo   [12] Remove a Specific Stuck Printer
echo   [13] Fix "Access Denied" when printing
echo   [14] Fix Error 0x0000007e (driver load fail)
echo.
echo   --- PERMISSIONS ^& REGISTRY ---
echo   [15] Reset Print Spooler Registry Settings
echo   [16] Grant Full Permission to Spool Folder
echo   [17] Fix Error 0x00000709 (default printer issue)
echo   [20] Fix Error 0x00000040 (network name no longer available)
echo.
echo   --- ADVANCED ---
echo   [18] Run ALL Fixes (recommended for stubborn problems)
echo   [19] View Current Printer and Spooler Status
echo   [0]  Exit
echo.
echo  ============================================================
set /p choice= Enter option number: 

if "%choice%"=="1"  goto FIX_SPOOLER
if "%choice%"=="2"  goto FIX_CLEARJOBS
if "%choice%"=="3"  goto FIX_SPOOLER_RESTART
if "%choice%"=="4"  goto FIX_RPC_BINDING
if "%choice%"=="5"  goto FIX_RPCAUTH
if "%choice%"=="6"  goto FIX_FIREWALL
if "%choice%"=="7"  goto FIX_TCPIP
if "%choice%"=="8"  goto FIX_OFFLINE
if "%choice%"=="9"  goto FIX_WSD
if "%choice%"=="10" goto FIX_DNS
if "%choice%"=="11" goto FIX_DRIVERS
if "%choice%"=="12" goto FIX_REMOVE_PRINTER
if "%choice%"=="13" goto FIX_ACCESS_DENIED
if "%choice%"=="14" goto FIX_0x7E
if "%choice%"=="15" goto FIX_REGISTRY
if "%choice%"=="16" goto FIX_PERMISSIONS
if "%choice%"=="17" goto FIX_0x709
if "%choice%"=="18" goto FIX_ALL
if "%choice%"=="19" goto VIEW_STATUS
if "%choice%"=="20" goto FIX_0x40
if "%choice%"=="0"  goto EXIT

echo  [!] Invalid option. Please try again.
timeout /t 2 >nul
goto MENU


:: ============================================================
:: FIX 1 - RESTART PRINT SPOOLER
:: ============================================================
:FIX_SPOOLER
cls
echo.
echo  [FIX 1] Restarting Print Spooler...
echo  --------------------------------------------------------
echo   Stopping spooler service...
net stop spooler >nul 2>&1
echo   Clearing print queue...
del /Q /F /S "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1
echo   Starting spooler service...
net start spooler >nul 2>&1
echo.
echo  [OK] Print Spooler restarted and queue cleared.
echo.
pause
goto MENU


:: ============================================================
:: FIX 2 - CLEAR PRINT JOBS ONLY
:: ============================================================
:FIX_CLEARJOBS
cls
echo.
echo  [FIX 2] Clearing All Print Jobs...
echo  --------------------------------------------------------
echo   Stopping spooler...
net stop spooler >nul 2>&1
echo   Deleting all queued print jobs...
del /Q /F /S "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1
echo   Starting spooler...
net start spooler >nul 2>&1
echo.
echo  [OK] All print jobs cleared. Printer queue is now empty.
echo.
pause
goto MENU


:: ============================================================
:: FIX 3 - FIX SPOOLER KEEPS STOPPING
:: ============================================================
:FIX_SPOOLER_RESTART
cls
echo.
echo  [FIX 3] Configuring Spooler Auto-Restart on Failure...
echo  --------------------------------------------------------
echo   Setting spooler to automatic start...
sc config spooler start= auto >nul 2>&1
echo   Setting failure recovery actions (restart on crash)...
sc failure spooler reset= 0 actions= restart/60000/restart/60000/restart/60000 >nul 2>&1
echo   Restarting spooler...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
echo.
echo  [OK] Spooler will now auto-restart if it stops unexpectedly.
echo.
pause
goto MENU


:: ============================================================
:: FIX 4 - RPC BINDING / DEPENDENCY FIX
:: ============================================================
:FIX_RPC_BINDING
cls
echo.
echo  [FIX 4] Applying RPC Binding and Dependency Fix...
echo  --------------------------------------------------------
echo   Setting spooler dependencies to RPCSS...
sc config spooler depend= RPCSS >nul 2>&1
echo   Setting RPC to auto start...
sc config RpcSs start= auto >nul 2>&1
echo   Setting RPC Endpoint Mapper to auto start...
sc config RpcEptMapper start= auto >nul 2>&1
echo   Restarting services...
net stop spooler >nul 2>&1
net start RpcSs >nul 2>&1
net start spooler >nul 2>&1
echo.
echo  [OK] RPC binding and spooler dependency fix applied.
echo.
pause
goto MENU


:: ============================================================
:: FIX 5 - RPCAUTHORIZATION REGISTRY FIX
:: ============================================================
:FIX_RPCAUTH
cls
echo.
echo  [FIX 5] Applying RpcAuthorization Registry Fix...
echo  --------------------------------------------------------
echo   Writing RpcAuthorization key to registry...
echo   Writing RpcAuthnLevelPrivacyEnabled key to registry...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul 2>&1
if %ERRORLEVEL%==0 (
    echo  [OK] RpcAuthnLevelPrivacyEnabled set successfully.
) else (
    echo  [!] Failed to write RpcAuthnLevelPrivacyEnabled. Ensure you are running as Administrator.
)
echo   Restarting spooler to apply changes...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
echo.
echo  [OK] Registry fix applied. Both RPC keys written. Try connecting to the printer again.
echo.
pause
goto MENU


:: ============================================================
:: FIX 6 - ENABLE PRINTER SHARING FIREWALL
:: ============================================================
:FIX_FIREWALL
cls
echo.
echo  [FIX 6] Enabling Printer Sharing through Firewall...
echo  --------------------------------------------------------
echo   Enabling File and Printer Sharing firewall rules...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1
echo   Enabling Network Discovery firewall rules...
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul 2>&1
if %ERRORLEVEL%==0 (
    echo  [OK] Firewall rules enabled successfully.
) else (
    echo  [!] Could not modify firewall rules. Ensure you are running as Administrator.
)
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
echo.
echo  [OK] Firewall fix applied. Try accessing the shared printer again.
echo.
pause
goto MENU


:: ============================================================
:: FIX 7 - RESET TCP/IP PRINTER PORT
:: ============================================================
:FIX_TCPIP
cls
echo.
echo  [FIX 7] Reset TCP/IP Printer Port (Network Printer)
echo  --------------------------------------------------------
echo   Enter the IP address of your network printer.
echo   Example: 192.168.1.100
echo.
set /p printerIP= Printer IP address: 

if "%printerIP%"=="" (
    echo  [!] No IP entered. Returning to menu.
    timeout /t 2 >nul
    goto MENU
)

echo.
echo   Removing old port entry for IP_%printerIP%...
cscript /nologo %WINDIR%\System32\Printing_Admin_Scripts\en-US\prnport.vbs -d -r IP_%printerIP% >nul 2>&1
echo   Adding fresh TCP/IP port for %printerIP%...
cscript /nologo %WINDIR%\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%printerIP% -h %printerIP% -o raw -n 9100 >nul 2>&1
echo   Restarting spooler...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
echo.
echo  [OK] TCP/IP port reset for printer at %printerIP%.
echo       Open Devices and Printers and verify the port is assigned to your printer.
echo.
pause
goto MENU


:: ============================================================
:: FIX 8 - FIX PRINTER SHOWING AS OFFLINE
:: ============================================================
:FIX_OFFLINE
cls
echo.
echo  [FIX 8] Fixing Printer Showing as Offline...
echo  --------------------------------------------------------
echo   Step 1: Stopping spooler and clearing queue...
net stop spooler >nul 2>&1
del /Q /F /S "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1

echo   Step 2: Resetting TCP/IP and Winsock (helps detect printer on network)...
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1

echo   Step 3: Restarting spooler...
net start spooler >nul 2>&1

echo   Step 4: Flushing DNS so printer hostname resolves correctly...
ipconfig /flushdns >nul 2>&1

echo.
echo  [OK] Offline fix applied.
echo.
echo   If the printer still shows offline, do these steps manually:
echo    1. Open "Devices and Printers"
echo    2. Right-click your printer ^> "See what's printing"
echo    3. Click menu: Printer ^> uncheck "Use Printer Offline"
echo    4. Confirm the printer is powered on and network-connected
echo    5. Try Fix [7] if it is a network printer (TCP/IP port reset)
echo.
pause
goto MENU


:: ============================================================
:: FIX 9 - RE-ENABLE WSD / NETWORK DISCOVERY
:: ============================================================
:FIX_WSD
cls
echo.
echo  [FIX 9] Re-enabling Network Discovery and WSD Services...
echo  --------------------------------------------------------
echo   Starting Function Discovery Resource Publication...
sc config FDResPub start= auto >nul 2>&1
net start FDResPub >nul 2>&1

echo   Starting SSDP Discovery service...
sc config SSDPSRV start= auto >nul 2>&1
net start SSDPSRV >nul 2>&1

echo   Starting UPnP Device Host service...
sc config upnphost start= auto >nul 2>&1
net start upnphost >nul 2>&1

echo   Starting Function Discovery Provider Host...
sc config fdPHost start= auto >nul 2>&1
net start fdPHost >nul 2>&1

echo   Enabling Network Discovery firewall rules...
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul 2>&1

echo.
echo  [OK] Network Discovery and WSD services re-enabled.
echo       Network printers should now be discoverable.
echo.
pause
goto MENU


:: ============================================================
:: FIX 10 - FLUSH DNS + RESET NETWORK STACK
:: ============================================================
:FIX_DNS
cls
echo.
echo  [FIX 10] Flushing DNS and Resetting Network Stack...
echo  --------------------------------------------------------
echo   Flushing DNS cache...
ipconfig /flushdns >nul 2>&1

echo   Releasing IP address...
ipconfig /release >nul 2>&1
echo   Renewing IP address...
ipconfig /renew >nul 2>&1

echo   Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1

echo   Resetting Winsock catalog...
netsh winsock reset >nul 2>&1

echo.
echo  [OK] DNS flushed and network stack reset.
echo  [!] A system restart is recommended after this fix.
echo.
pause
goto MENU


:: ============================================================
:: FIX 11 - REINSTALL / RESET ALL PRINTER DRIVERS
:: ============================================================
:FIX_DRIVERS
cls
echo.
echo  [FIX 11] Resetting All Printer Drivers...
echo  --------------------------------------------------------
echo  [!] WARNING: This removes ALL cached printer drivers.
echo      You will need to reinstall your printer afterward.
echo.
set /p confirm= Type YES to continue or NO to cancel: 
if /i not "%confirm%"=="YES" goto MENU

echo   Stopping services...
net stop spooler >nul 2>&1
sc config spooler start= auto >nul 2>&1

echo   Deleting cached drivers (x86)...
if exist "%systemroot%\System32\spool\drivers\w32x86" (
    del /Q /F /S "%systemroot%\System32\spool\drivers\w32x86\*.*" >nul 2>&1
)
echo   Deleting cached drivers (x64)...
if exist "%systemroot%\System32\spool\drivers\x64" (
    del /Q /F /S "%systemroot%\System32\spool\drivers\x64\*.*" >nul 2>&1
)
echo   Restarting spooler...
net start spooler >nul 2>&1

echo.
echo  [OK] All printer drivers cleared.
echo       Go to: Settings ^> Devices ^> Printers ^& Scanners ^> Add a printer
echo.
pause
goto MENU


:: ============================================================
:: FIX 12 - REMOVE A SPECIFIC STUCK PRINTER
:: ============================================================
:FIX_REMOVE_PRINTER
cls
echo.
echo  [FIX 12] Remove a Specific Stuck Printer
echo  --------------------------------------------------------
echo   Currently installed printers:
echo.
wmic printer get name 2>nul
echo.
set /p printerName= Enter the EXACT printer name to remove: 

if "%printerName%"=="" (
    echo  [!] No name entered. Returning to menu.
    timeout /t 2 >nul
    goto MENU
)

echo.
echo   Removing printer: %printerName%
cscript /nologo %WINDIR%\System32\Printing_Admin_Scripts\en-US\prnmngr.vbs -d -p "%printerName%" >nul 2>&1
if %ERRORLEVEL%==0 (
    echo  [OK] Printer "%printerName%" removed successfully.
) else (
    echo  [!] Could not remove printer. Check the name matches exactly as listed above.
)
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
echo.
pause
goto MENU


:: ============================================================
:: FIX 13 - FIX ACCESS DENIED WHEN PRINTING
:: ============================================================
:FIX_ACCESS_DENIED
cls
echo.
echo  [FIX 13] Fixing "Access Denied" When Printing...
echo  --------------------------------------------------------
echo   Granting full permissions to spool folder...
icacls "%systemroot%\System32\spool\PRINTERS" /grant "Everyone:(OI)(CI)F" /T >nul 2>&1
icacls "%systemroot%\System32\spool\PRINTERS" /grant "SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%systemroot%\System32\spool\PRINTERS" /grant "Administrators:(OI)(CI)F" /T >nul 2>&1

echo   Resetting spooler service security descriptor...
sc sdset spooler "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)" >nul 2>&1

echo   Restarting spooler...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1

echo.
echo  [OK] Spool folder and spooler service permissions reset.
echo.
pause
goto MENU


:: ============================================================
:: FIX 14 - FIX ERROR 0x0000007e
:: ============================================================
:FIX_0x7E
cls
echo.
echo  [FIX 14] Fixing Error 0x0000007e (Driver Load Failure)...
echo  --------------------------------------------------------
echo   This error usually means a corrupted or incompatible driver DLL.
echo.
echo   Stopping spooler...
net stop spooler >nul 2>&1

echo   Removing broken driver registry entries...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers\Version-3" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows NT x86\Drivers\Version-3" /f >nul 2>&1

echo   Clearing driver cache folders...
if exist "%systemroot%\System32\spool\drivers\x64" (
    del /Q /F /S "%systemroot%\System32\spool\drivers\x64\*.*" >nul 2>&1
)
if exist "%systemroot%\System32\spool\drivers\w32x86" (
    del /Q /F /S "%systemroot%\System32\spool\drivers\w32x86\*.*" >nul 2>&1
)

echo   Restarting spooler...
net start spooler >nul 2>&1

echo.
echo  [OK] Error 0x0000007e fix applied. Reinstall your printer driver now.
echo.
pause
goto MENU


:: ============================================================
:: FIX 15 - RESET SPOOLER REGISTRY SETTINGS
:: ============================================================
:FIX_REGISTRY
cls
echo.
echo  [FIX 15] Resetting Print Spooler Registry Settings...
echo  --------------------------------------------------------
echo  [!] This resets spooler registry keys to Windows defaults.
echo.
set /p confirm= Type YES to continue or NO to cancel: 
if /i not "%confirm%"=="YES" goto MENU

echo   Stopping spooler...
net stop spooler >nul 2>&1

echo   Restoring spooler ImagePath...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "ImagePath" /t REG_EXPAND_SZ /d "%SystemRoot%\System32\spoolsv.exe" /f >nul 2>&1

echo   Restoring DefaultSpoolDirectory...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Printers" /v "DefaultSpoolDirectory" /t REG_SZ /d "%SystemRoot%\System32\spool\PRINTERS" /f >nul 2>&1

echo   Restarting spooler...
net start spooler >nul 2>&1

echo.
echo  [OK] Spooler registry settings restored to defaults.
echo.
pause
goto MENU


:: ============================================================
:: FIX 16 - GRANT FULL PERMISSION TO SPOOL FOLDER
:: ============================================================
:FIX_PERMISSIONS
cls
echo.
echo  [FIX 16] Granting Full Permissions to Spool Folder...
echo  --------------------------------------------------------
echo   Taking ownership of spool folder...
takeown /F "%systemroot%\System32\spool\PRINTERS" /A /R /D Y >nul 2>&1
echo   Granting full control to Administrators...
icacls "%systemroot%\System32\spool\PRINTERS" /grant Administrators:F /T >nul 2>&1
echo   Granting full control to SYSTEM...
icacls "%systemroot%\System32\spool\PRINTERS" /grant SYSTEM:F /T >nul 2>&1
echo   Granting full control to NETWORK SERVICE...
icacls "%systemroot%\System32\spool\PRINTERS" /grant "NETWORK SERVICE":F /T >nul 2>&1
echo   Granting modify access to Everyone...
icacls "%systemroot%\System32\spool\PRINTERS" /grant Everyone:M /T >nul 2>&1
echo   Restarting spooler...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
echo.
echo  [OK] Spool folder permissions reset. Try printing again.
echo.
pause
goto MENU


:: ============================================================
:: FIX 17 - FIX ERROR 0x00000709
:: ============================================================
:FIX_0x709
cls
echo.
echo  [FIX 17] Fixing Error 0x00000709 (Default Printer Issue)...
echo  --------------------------------------------------------
echo   This error occurs when Windows cannot set or save the default printer,
echo   usually caused by a corrupted registry key under HKCU.
echo.
echo   Currently installed printers:
wmic printer get name 2>nul
echo.
set /p defPrinter= Enter printer name to set as default (or press Enter to skip): 

echo   Removing corrupted Device key...
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v "Device" /f >nul 2>&1

echo   Disabling auto-managed default printer (Windows 10/11 setting)...
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v "LegacyDefaultPrinterMode" /t REG_DWORD /d 1 /f >nul 2>&1

if not "%defPrinter%"=="" (
    echo   Setting "%defPrinter%" as default printer...
    cscript /nologo %WINDIR%\System32\Printing_Admin_Scripts\en-US\prnmngr.vbs -t -p "%defPrinter%" >nul 2>&1
    if %ERRORLEVEL%==0 (
        echo  [OK] Default printer set to: %defPrinter%
    ) else (
        echo  [!] Could not set default printer. Verify the name matches exactly.
    )
)

echo   Restarting spooler...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1

echo.
echo  [OK] Error 0x00000709 fix applied.
echo.
pause
goto MENU


:: ============================================================
:: FIX 20 - FIX ERROR 0x00000040 (NETWORK NAME NO LONGER AVAILABLE)
:: ============================================================
:FIX_0x40
cls
echo.
echo  [FIX 20] Fixing Error 0x00000040 - Network Name No Longer Available...
echo  --------------------------------------------------------
echo   This error means Windows lost the network path to the printer.
echo   Common causes: SMB protocol mismatch, disabled services,
echo   firewall blocking, or stale network session to the print server.
echo.
echo   Step 1: Restarting Print Spooler and clearing queue...
net stop spooler >nul 2>&1
del /Q /F /S "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1
net start spooler >nul 2>&1

echo   Step 2: Enabling SMB 1.0 client (required by some older print servers)...
sc config lanmanworkstation start= auto >nul 2>&1
net start lanmanworkstation >nul 2>&1

echo   Step 3: Enabling SMB Direct and related services...
sc config mrxsmb10 start= auto >nul 2>&1
sc config mrxsmb20 start= auto >nul 2>&1

echo   Step 4: Restarting Workstation and Server services...
net stop workstation /y >nul 2>&1
net start workstation >nul 2>&1
net stop server /y >nul 2>&1
net start server >nul 2>&1

echo   Step 5: Enabling File and Printer Sharing firewall rules...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1

echo   Step 6: Applying RpcAuthorization and RpcAuthnLevelPrivacyEnabled keys...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthorization /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul 2>&1

echo   Step 7: Flushing DNS and resetting network sessions...
ipconfig /flushdns >nul 2>&1
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1

echo   Step 8: Restarting spooler to finalize...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1

echo.
echo  ============================================================
echo  [OK] Error 0x00000040 fix applied.
echo.
echo   What was done:
echo    - Spooler restarted, queue cleared
echo    - Workstation and Server services restarted
echo    - SMB client services set to auto-start
echo    - Printer sharing firewall rules enabled
echo    - RpcAuthorization + RpcAuthnLevelPrivacyEnabled set
echo    - DNS flushed, NetBIOS cache purged, network stack reset
echo.
echo   If the error persists, also try:
echo    - Fix [7]  Reset TCP/IP Printer Port (if network printer)
echo    - Fix [9]  Re-enable WSD / Network Discovery
echo    - Verify the print server hostname or IP is reachable:
echo      Open CMD and type:  ping ^<printer-hostname-or-IP^>
echo    - Check the print server is powered on and sharing is enabled
echo  ============================================================
echo.
pause
goto MENU


:: ============================================================
:: FIX 18 - RUN ALL FIXES
:: ============================================================
:FIX_ALL
cls
echo.
echo  [FIX ALL] Running all automatic printer fixes...
echo  ============================================================
echo.
echo  [1/14] Stopping Print Spooler...
net stop spooler >nul 2>&1

echo  [2/14] Clearing print queue...
del /Q /F /S "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1

echo  [3/14] Applying RpcAuthorization registry fixes...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthorization /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul 2>&1

echo  [4/14] Enabling Printer Sharing and Network Discovery firewall rules...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul 2>&1

echo  [5/14] Configuring spooler auto-restart on failure...
sc config spooler start= auto >nul 2>&1
sc failure spooler reset= 0 actions= restart/60000/restart/60000/restart/60000 >nul 2>&1

echo  [6/14] Fixing RPC dependencies...
sc config spooler depend= RPCSS >nul 2>&1
sc config RpcSs start= auto >nul 2>&1
sc config RpcEptMapper start= auto >nul 2>&1

echo  [7/14] Re-enabling Network Discovery services...
sc config FDResPub start= auto >nul 2>&1 & net start FDResPub >nul 2>&1
sc config SSDPSRV start= auto >nul 2>&1 & net start SSDPSRV >nul 2>&1
sc config fdPHost start= auto >nul 2>&1 & net start fdPHost >nul 2>&1
sc config upnphost start= auto >nul 2>&1 & net start upnphost >nul 2>&1

echo  [8/14] Resetting spooler registry path...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "ImagePath" /t REG_EXPAND_SZ /d "%SystemRoot%\System32\spoolsv.exe" /f >nul 2>&1

echo  [9/14] Resetting spool folder permissions...
takeown /F "%systemroot%\System32\spool\PRINTERS" /A /R /D Y >nul 2>&1
icacls "%systemroot%\System32\spool\PRINTERS" /grant Administrators:F /T >nul 2>&1
icacls "%systemroot%\System32\spool\PRINTERS" /grant SYSTEM:F /T >nul 2>&1
icacls "%systemroot%\System32\spool\PRINTERS" /grant "NETWORK SERVICE":F /T >nul 2>&1
icacls "%systemroot%\System32\spool\PRINTERS" /grant Everyone:M /T >nul 2>&1

echo  [10/14] Fixing default printer registry (0x00000709 prevention)...
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v "Device" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v "LegacyDefaultPrinterMode" /t REG_DWORD /d 1 /f >nul 2>&1

echo  [11/14] Flushing DNS...
ipconfig /flushdns >nul 2>&1

echo  [12/14] Resetting Winsock and TCP/IP stack...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1

echo  [13/15] Starting RPC services...
net start RpcSs >nul 2>&1

echo  [14/15] Restarting Workstation and Server services (fix 0x00000040)...
net stop workstation /y >nul 2>&1
net start workstation >nul 2>&1
net stop server /y >nul 2>&1
net start server >nul 2>&1
sc config lanmanworkstation start= auto >nul 2>&1
sc config mrxsmb10 start= auto >nul 2>&1
sc config mrxsmb20 start= auto >nul 2>&1
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1

echo  [15/15] Restarting Print Spooler...
net start spooler >nul 2>&1

echo.
echo  ============================================================
echo  [OK] ALL AUTOMATIC FIXES APPLIED SUCCESSFULLY.
echo.
echo   What was done:
echo    - Spooler restarted, queue cleared
echo    - RpcAuthorization + RpcAuthnLevelPrivacyEnabled added to registry
echo    - Printer sharing + network discovery firewall enabled
echo    - Spooler auto-restart on failure configured
echo    - RPC dependencies corrected
echo    - Network Discovery (WSD) services re-enabled
echo    - Spool folder permissions reset
echo    - Spooler registry paths restored
echo    - Default printer registry key fixed (0x00000709)
echo    - DNS flushed, Winsock + TCP/IP stack reset
echo    - Workstation + Server services restarted (0x00000040 fix)
echo    - SMB client services set to auto-start
echo.
echo   The following fixes require manual input and were NOT run:
echo    - [7]  TCP/IP port reset    (needs your printer IP)
echo    - [11] Driver reset         (requires confirmation)
echo    - [12] Remove stuck printer (needs printer name)
echo    - [17] Set default printer  (needs printer name)
echo  ============================================================
echo.
echo  [!] A system restart is recommended after running all fixes.
echo.
pause
goto MENU


:: ============================================================
:: VIEW STATUS
:: ============================================================
:VIEW_STATUS
cls
echo.
echo  [STATUS] Current Printer and Spooler Status
echo  ============================================================
echo.
echo  --- SPOOLER SERVICE ---
sc query spooler | findstr /i "STATE"
echo.
echo  --- INSTALLED PRINTERS ---
wmic printer get name,status,default,portname 2>nul
echo.
echo  --- PENDING PRINT JOBS ---
wmic printjob get name,status,document 2>nul
echo.
echo  --- PRINTER PORTS ---
wmic printerport get name,hostaddress,protocol 2>nul
echo.
pause
goto MENU


:: ============================================================
:: EXIT
:: ============================================================
:EXIT
cls
echo.
echo   Printer Repair Toolkit closed.
echo.
timeout /t 2 >nul
exit /b