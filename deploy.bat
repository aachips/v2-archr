@echo off
REM deploy.bat — Rebuild Vue portal and deploy to portal/ on Windows (Laragon)
REM Run from repo root: C:\laragon\www\v2-archr
REM
REM Usage: deploy.bat
REM   Or with migration: deploy.bat path\to\migration.sql

setlocal

set REPO=C:\laragon\www\v2-archr
set VUE=%REPO%\vue-view
set PORTAL=%REPO%\portal

echo === [1/3] Building Vue app ===
cd /d "%VUE%"
call npm run build
if errorlevel 1 (
    echo ERROR: npm run build failed
    exit /b 1
)

echo === [2/3] Deploying dist/ to portal/ ===
cd /d "%REPO%"
rmdir /s /q "%PORTAL%\assets" 2>nul
mkdir "%PORTAL%\assets"
robocopy "%VUE%\dist\assets" "%PORTAL%\assets" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
copy /Y "%VUE%\dist\portal.html" "%PORTAL%\portal.html" >nul
copy /Y "%VUE%\dist\intake.html" "%PORTAL%\intake.html" >nul
copy /Y "%VUE%\dist\volunteer-intake.html" "%PORTAL%\volunteer-intake.html" >nul
copy /Y "%VUE%\dist\favicon.ico" "%PORTAL%\favicon.ico" >nul

echo === [3/3] Deploy complete ===
echo Portal served from %PORTAL%\

REM Optional: run a SQL migration if provided
if not "%~1"=="" (
    if exist "%~1" (
        echo === Running SQL migration: %~1 ===
        "C:\laragon\bin\postgresql\postgresql\bin\psql.exe" -U postgres -d archr -f "%~1"
        if errorlevel 1 (
            echo WARNING: Migration may have failed
        ) else (
            echo Migration complete.
        )
    ) else (
        echo WARNING: Migration file not found: %~1
        echo Skipping migration.
    )
)

echo === Done! ===
endlocal
