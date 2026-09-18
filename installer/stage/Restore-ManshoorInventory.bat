@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Manshoor Inventory - Restore

cd /d "%~dp0"

echo ==========================================
echo     Manshoor Inventory - Restore
echo ==========================================
echo.

echo Checking Docker...
docker version >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Docker Desktop is not running or Docker is not installed.
    echo.
    pause
    exit /b 1
)

echo Docker is ready.
echo.

echo Checking Manshoor Inventory image...

docker image inspect manshoor-inventory:v1.0.2 >nul 2>&1

if errorlevel 1 (
    echo Image not found. Loading embedded image...
    echo.

    if not exist "manshoor-inventory-v1.0.2.tar" (
        echo.
        echo ERROR: Embedded Docker image was not found.
        echo.
        pause
        exit /b 1
    )

    docker load -i "manshoor-inventory-v1.0.2.tar"

    if errorlevel 1 (
        echo.
        echo ERROR: Could not load Manshoor Inventory image.
        echo.
        pause
        exit /b 1
    )

    echo.
    echo Docker image loaded successfully.
)

echo.

if not exist "backups" (
    echo ERROR: Backup folder not found:
    echo %cd%\backups
    echo.
    pause
    exit /b 1
)

if not exist "instance" (
    echo ERROR: Instance folder not found:
    echo %cd%\instance
    echo.
    pause
    exit /b 1
)

echo Available backup files:
echo.

set /a count=0

for /f "delims=" %%F in ('dir /b /a-d /o-d "backups\*.db" 2^>nul') do (
    set /a count+=1
    set "backup_!count!=%%F"
    echo !count!^) %%F
)

if %count% EQU 0 (
    echo.
    echo No backup files were found.
    echo.
    pause
    exit /b 1
)

echo.
set /p "choice=Enter backup number to restore: "

if not defined choice (
    echo.
    echo Invalid selection.
    echo.
    pause
    exit /b 1
)

set "selected=!backup_%choice%!"

if not defined selected (
    echo.
    echo Invalid backup number.
    echo.
    pause
    exit /b 1
)

echo.
echo Selected backup:
echo %cd%\backups\%selected%
echo.

echo.
echo Checking backup integrity...
echo.

docker run --rm ^
  -v "%cd%\backups:/backups" ^
  manshoor-inventory:v1.0.2 ^
  python -c "import sqlite3,sys; p='/backups/%selected%'; c=sqlite3.connect(p); r=c.execute('PRAGMA integrity_check;').fetchone()[0]; c.close(); print(r); sys.exit(0 if r=='ok' else 1)"

if errorlevel 1 (
    echo.
    echo ERROR: The selected backup is invalid or corrupted.
    echo.
    echo Restore cancelled.
    echo.
    pause
    exit /b 1
)

echo.
echo Backup integrity check passed.
echo.

echo WARNING:
echo Current database will be replaced by the selected backup.
echo.

set /p "confirm=Continue? Type YES to continue: "

if /I not "%confirm%"=="YES" (
    echo.
    echo Operation cancelled.
    echo.
    pause
    exit /b 0
)

echo.
echo Stopping Manshoor Inventory...

docker compose stop

if errorlevel 1 (
    echo.
    echo ERROR: Could not stop Manshoor Inventory.
    echo.
    pause
    exit /b 1
)

echo.
echo Creating emergency backup of current database...

if not exist "instance\data.db" (
    echo.
    echo ERROR: Current database not found.
    echo.
    echo Starting Manshoor Inventory again...
    docker compose up -d --force-recreate
    pause
    exit /b 1
)

for /f "delims=" %%T in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')"') do set "timestamp=%%T"

set "emergency=backups\before_restore_%timestamp%.db"

cmd.exe /c copy /Y "instance\data.db" "%emergency%" >nul

if errorlevel 1 (
    echo.
    echo ERROR: Could not create emergency backup.
    echo Restore cancelled.
    echo.
    echo Starting Manshoor Inventory again...
    docker compose up -d --force-recreate
    pause
    exit /b 1
)

echo Emergency backup created:
echo %cd%\%emergency%
echo.

echo Restoring database...

cmd.exe /c copy /Y "backups\%selected%" "instance\data.db" >nul

if errorlevel 1 (
    echo.
    echo ERROR: Database restore failed.
    echo.
    echo Starting Manshoor Inventory again...
    docker compose up -d --force-recreate
    pause
    exit /b 1
)

echo.
echo Starting Manshoor Inventory...

docker compose up -d --force-recreate

if errorlevel 1 (
    echo.
    echo ERROR: Could not start Manshoor Inventory.
    echo.
    echo The emergency backup is available at:
    echo %cd%\%emergency%
    echo.
    pause
    exit /b 1
)

echo.
echo Waiting for Manshoor Inventory...
echo.

set /a attempts=0

:WAIT_LOOP

set /a attempts+=1

powershell -NoProfile -Command "if ((Test-NetConnection -ComputerName 127.0.0.1 -Port 5003 -WarningAction SilentlyContinue).TcpTestSucceeded) { exit 0 } else { exit 1 }" >nul 2>&1

if not errorlevel 1 goto READY

if %attempts% GEQ 60 goto TIMEOUT

timeout /t 2 /nobreak >nul
goto WAIT_LOOP

:READY

echo.
echo ==========================================
echo   Restore completed successfully!
echo ==========================================
echo.
echo Restored backup:
echo %selected%
echo.
echo Emergency backup:
echo %emergency%
echo.
echo Opening Manshoor Inventory...
echo.

start "" "http://localhost:5003"

pause
exit /b 0

:TIME
