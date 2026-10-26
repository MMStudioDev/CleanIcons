@echo off
setlocal
title CleanIcons - Remove Shortcut Arrow and Admin Shield

:: ------------------------------------------------------------
:: CleanIcons - hides the shortcut arrow and the administrator
:: shield overlay on icons. Works on Windows 10 and Windows 11.
:: Overlay 29 = shortcut arrow (uses shell32.dll,-50)
:: Overlay 77 = administrator shield (uses custom blank.ico)
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
set "MARK_ICO=\CleanIcons\blank.ico"
set "MARK_SYS=shell32.dll,-50"

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
call :remove_arrow
call :refresh
goto :done
:opt2
call :remove_shield
call :refresh
goto :done
:opt3
call :remove_arrow
call :remove_shield
call :refresh
goto :done
:opt4
call :restore_arrow
call :refresh
goto :done
:opt5
call :restore_shield
call :refresh
goto :done
:opt6
call :restore_arrow
call :restore_shield
call :refresh
goto :done

:remove_arrow
echo.
echo Removing shortcut arrows...
reg add "%KEY%" /v 29 /t REG_SZ /d "%windir%\System32\shell32.dll,-50" /f >nul || goto :failed
exit /b

:remove_shield
echo.
echo Creating blank icon for administrator shield...
call :makeicon
if not exist "%ICO%" goto :failed
echo Removing administrator shield...
reg add "%KEY%" /v 77 /t REG_SZ /d "%ICO%,0" /f >nul || goto :failed
exit /b

:restore_arrow
echo.
echo Restoring default shortcut arrows...
reg delete "%KEY%" /v 29 /f >nul 2>&1
exit /b

:restore_shield
echo.
echo Restoring default administrator shield...
reg delete "%KEY%" /v 77 /f >nul 2>&1
call :cleanup
exit /b

:done
echo.
echo Done. Selected overlay changes applied.
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
if "%1"=="29" reg query "%KEY%" /v 29 2>nul | find /i "%MARK_SYS%" >nul && set "%2=HIDDEN"
if "%1"=="77" reg query "%KEY%" /v 77 2>nul | find /i "%MARK_ICO%" >nul && set "%2=HIDDEN"
exit /b

:: --- Write a transparent multi-size icon (16/24/32/48) to %ICO% for Shield ---
:makeicon
if not exist "%DIR%" mkdir "%DIR%"
powershell -NoProfile -Command "$s=16,24,32,48;$b=New-Object IO.MemoryStream;$w=New-Object IO.BinaryWriter($b);$w.Write([uint16]0);$w.Write([uint16]1);$w.Write([uint16]$s.Count);$o=6+16*$s.Count;foreach($n in $s){$m=[int][math]::Ceiling($n/32)*4;$l=40+$n*$n*4+$m*$n;$w.Write([byte]$n);$w.Write([byte]$n);$w.Write([byte]0);$w.Write([byte]0);$w.Write([uint16]1);$w.Write([uint16]32);$w.Write([uint32]$l);$w.Write([uint32]$o);$o+=$l};foreach($n in $s){$m=[int][math]::Ceiling($n/32)*4;$w.Write([uint32]40);$w.Write([int]$n);$w.Write([int](2*$n));$w.Write([uint16]1);$w.Write([uint16]32);$w.Write([uint32]0);$w.Write([uint32]0);$w.Write([int]0);$w.Write([int]0);$w.Write([uint32]0);$w.Write([uint32]0);$px=New-Object byte[] ($n*$n*4);$px[3]=1;$w.Write($px);$w.Write([byte[]](@(255)*($m*$n)))};[IO.File]::WriteAllBytes($env:ICO,$b.ToArray())"
exit /b

:: --- Delete the blank icon once overlay 77 no longer uses it ---
:cleanup
set "INUSE="
reg query "%KEY%" /v 77 2>nul | find /i "%MARK_ICO%" >nul && set "INUSE=1"
if not defined INUSE if exist "%DIR%" rmdir /s /q "%DIR%"
exit /b

:: --- Restart Explorer so it reloads the overlays, and clear the icon cache ---
:refresh
echo Restarting Explorer and clearing icon cache...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
attrib -h -s -r "%localappdata%\IconCache.db" >nul 2>&1
del /f /q "%localappdata%\IconCache.db" >nul 2>&1
del /f /q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
timeout /t 2 /nobreak >nul
tasklist /fi "imagename eq explorer.exe" 2>nul | find /i "explorer.exe" >nul || start "" explorer.exe
exit /b