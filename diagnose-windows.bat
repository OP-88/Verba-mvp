@echo off
echo ================================================
echo Verba Diagnostics for Windows
echo ================================================
echo.

echo [1] Checking if app.exe is running...
tasklist | findstr /i "app.exe" >nul
if %ERRORLEVEL% EQU 0 (
    echo    OK - Backend process found
    tasklist | findstr /i "app.exe"
) else (
    echo    ERROR - Backend process NOT running
)
echo.

echo [2] Testing backend connection on localhost:8000...
curl -s http://localhost:8000/ >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    OK - Backend responding on localhost:8000
    curl -s http://localhost:8000/ | findstr "status"
) else (
    echo    ERROR - Cannot connect to localhost:8000
)
echo.

echo [3] Testing backend connection on 127.0.0.1:8000...
curl -s http://127.0.0.1:8000/ >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    OK - Backend responding on 127.0.0.1:8000
) else (
    echo    ERROR - Cannot connect to 127.0.0.1:8000
)
echo.

echo [4] Checking if port 8000 is in use...
netstat -ano | findstr ":8000"
if %ERRORLEVEL% EQU 0 (
    echo    Port 8000 is being used by:
    netstat -ano | findstr ":8000"
) else (
    echo    Port 8000 is NOT in use
)
echo.

echo [5] Installation location check...
where app.exe 2>nul
if %ERRORLEVEL% EQU 0 (
    echo    Found app.exe at:
    where app.exe
) else (
    echo    app.exe not in PATH
)
echo.

echo [6] Checking Windows Firewall...
netsh advfirewall show allprofiles state | findstr "State"
echo.

echo ================================================
echo Diagnostics Complete
echo ================================================
echo.
echo Please share these results for debugging.
pause
