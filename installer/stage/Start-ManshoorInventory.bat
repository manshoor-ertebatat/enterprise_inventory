@echo off
title Manshoor Inventory
cd /d "%~dp0"

echo ==========================================
echo       Manshoor Inventory
echo ==========================================
echo.

echo Checking Docker...
docker version >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Docker Desktop is not running or Docker is not installed.
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

echo Docker is ready.
echo.

docker image inspect manshoor-inventory:v1.0.2 >nul 2>&1

if errorlevel 1 (
    echo Loading Manshoor Inventory image...
    echo This may take a few seconds.
    echo.

    docker load -i "manshoor-inventory-v1.0.2.tar"

    if errorlevel 1 (
        echo.
        echo ERROR: Could not load Manshoor Inventory image.
        echo.
        pause
        exit /b 1
    )

    echo.
    echo Image loaded successfully.
    echo.
)

echo Starting Manshoor Inventory...
echo.

docker compose up -d

if errorlevel 1 (
    echo.
    echo ERROR: Could not start Manshoor Inventory.
    echo.
    pause
    exit /b 1
)

echo.
echo Waiting for Manshoor Inventory to become ready...
echo.

set /a attempts=0

:WAIT_LOOP
set /a attempts+=1

powershell -NoProfile -Command "try { $r=Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:5003' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1

if not errorlevel 1 goto READY

if %attempts% GEQ 30 goto TIMEOUT

timeout /t 2 /nobreak >nul
goto WAIT_LOOP

:READY
echo.
echo ==========================================
echo   Manshoor Inventory is ready!
echo ==========================================
echo.
echo Opening browser...
echo.

start "" "http://localhost:5003"

exit /b 0

:TIMEOUT
echo.
echo ERROR: Manshoor Inventory did not become ready.
echo.
echo Please check Docker Desktop and container status.
echo.
echo Container:
docker ps --filter "name=enterprise_inventory_v2"
echo.
pause
exit /b 1
