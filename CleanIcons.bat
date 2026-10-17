@echo off
setlocal
title CleanIcons - Remove Shortcut Arrow and Admin Shield

:: ------------------------------------------------------------
:: CleanIcons - hides the shortcut arrow and the administrator
:: shield overlay on icons. Works on Windows 10 and Windows 11.
:: Overlay 29 = shortcut arrow, overlay 77 = administrator shield
:: ------------------------------------------------------------

:: --- Make sure we are running as administrator ---
set "SELF=%~f0"
fltmc >nul 2>&1 && goto :start
if /i "%~1"=="elevated" goto :noadmin

echo Requesting administrator rights...
powershell -NoProfile -Command "Start-Process -FilePath '%SELF:'=''%' -ArgumentList 'elevated' -Verb RunAs" >nul 2>&1
if errorlevel 1 goto :noadmin
exit /b

:noadmin
echo.
echo CleanIcons needs administrator rights to change these settings.
echo Right-click CleanIcons.bat and choose "Run as administrator".
pause
exit /b 1

:start
set "KEY=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
set "DIR=%ProgramData%\CleanIcons"
set "ICO=%DIR%\blank.ico"
set "MARK=\CleanIcons\blank.ico"

:: --- Move over from older versions of this script, if they were used ---
set "MIGRATE="
for %%P in (BareIcons DeArrow OverlayOff) do if exist "%ProgramData%\%%P" set "MIGRATE=1"
if not defined MIGRATE goto :detect

call :makeicon
for %%V in (29 77) do call :repoint %%V
for %%P in (BareIcons DeArrow OverlayOff) do if exist "%ProgramData%\%%P" rmdir /s /q "%ProgramData%\%%P"
call :cleanup

:detect
:: --- Detect Windows version (build 22000 or higher is Windows 11) ---
set "BUILD=0"
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul ^| find "CurrentBuild"') do set "BUILD=%%A"
set "WINVER=Windows 10"
if %BUILD% GEQ 22000 set "WINVER=Windows 11"

:menu
cls
echo ====================================================
echo   CleanIcons - Remove Shortcut Arrow and Admin Shield
echo ====================================================
echo   Detected : %WINVER% build %BUILD%
call :getstate 29 ARROW
call :getstate 77 SHIELD
echo   Arrows   : %ARROW%
echo   Shield   : %SHIELD%
echo.
echo   [1] Remove shortcut arrows
echo   [2] Remove administrator shield
echo   [3] Remove both
echo   [4] Restore shortcut arrows
echo   [5] Restore administrator shield
echo   [6] Restore both
echo   [7] Exit
echo.
choice /c 1234567 /n /m "Choose an option: "
if errorlevel 7 exit /b 0
if errorlevel 6 goto :opt6
if errorlevel 5 goto :opt5
if errorlevel 4 goto :opt4
if errorlevel 3 goto :opt3
if errorlevel 2 goto :opt2
if errorlevel 1 goto :opt1
goto :menu

:opt1
set "TARGETS=29"
goto :remove
:opt2
set "TARGETS=77"
goto :remove
:opt3
set "TARGETS=29 77"
goto :remove
:opt4
set "TARGETS=29"
goto :restore
:opt5
set "TARGETS=77"
goto :restore
:opt6
set "TARGETS=29 77"
goto :restore

:remove
echo.
echo Creating blank icon...
call :makeicon
if not exist "%ICO%" goto :failed

echo Updating registry...
for %%V in (%TARGETS%) do reg add "%KEY%" /v %%V /t REG_SZ /d "%ICO%,0" /f >nul || goto :failed

call :refresh
echo.
echo Done. Selected overlays removed.
echo If they still appear, restart your PC.
pause
goto :menu

:restore
echo.
echo Restoring default overlays...
for %%V in (%TARGETS%) do reg delete "%KEY%" /v %%V /f >nul 2>&1
call :cleanup

call :refresh
echo.
echo Done. Selected overlays restored.
pause
goto :menu

:failed
echo.
echo Something went wrong. Please run the script again as administrator.
pause
goto :menu

:: --- getstate <overlay> <variable>: VISIBLE, HIDDEN (by us) or CUSTOM (set by something else) ---
:getstate
set "%2=VISIBLE"
reg query "%KEY%" /v %1 >nul 2>&1 || exit /b
set "%2=CUSTOM"
reg query "%KEY%" /v %1 2>nul | find /i "%MARK%" >nul && set "%2=HIDDEN"
exit /b

:: --- Write a fully transparent 16x16 icon to %ICO% ---
:makeicon
if not exist "%DIR%" mkdir "%DIR%"
powershell -NoProfile -Command "$h=[byte[]](0,0,1,0,1,0,16,16,0,0,1,0,32,0,104,4,0,0,22,0,0,0); $d=[byte[]](40,0,0,0,16,0,0,0,32,0,0,0,1,0,32,0)+(New-Object byte[] 24); $z=New-Object byte[] 1024; $m=[byte[]](@(255)*64); [IO.File]::WriteAllBytes($env:ICO,[byte[]]($h+$d+$z+$m))"
exit /b

:: --- Point a value that used an older version's icon at the current one ---
:repoint
for %%P in (BareIcons DeArrow OverlayOff) do reg query "%KEY%" /v %1 2>nul | find /i "ProgramData\%%P" >nul && reg add "%KEY%" /v %1 /t REG_SZ /d "%ICO%,0" /f >nul
exit /b

:: --- Delete the blank icon once nothing uses it any more ---
:cleanup
set "INUSE="
for %%V in (29 77) do reg query "%KEY%" /v %%V 2>nul | find /i "%MARK%" >nul && set "INUSE=1"
if not defined INUSE if exist "%DIR%" rmdir /s /q "%DIR%"
exit /b

:: --- Restart Explorer so it reloads the overlays, and clear the icon cache ---
:refresh
echo Restarting Explorer and clearing the icon cache...
taskkill /f /im explorer.exe >nul 2>&1
attrib -h -s -r "%localappdata%\IconCache.db" >nul 2>&1
del /f /q "%localappdata%\IconCache.db" >nul 2>&1
del /f /q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
:: Windows normally brings Explorer back by itself (without admin rights).
:: Only start it by hand if that did not happen.
timeout /t 4 /nobreak >nul
tasklist /fi "imagename eq explorer.exe" 2>nul | find /i "explorer.exe" >nul || start "" explorer.exe
exit /b
