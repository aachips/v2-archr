@echo off
setlocal
cd /d "%~dp0"

if not exist "%~dp0PAT.txt" (
  if not defined AIRTABLE_PAT if not defined AIRTABLE_TOKEN (
    echo ERROR: No Airtable PAT found.
    echo Set AIRTABLE_PAT or add it to "%~dp0PAT.txt".
    exit /b 1
  )
)

if not "%~1"=="" (
  node "%~dp0local-airtable-template-generator.js" %*
  exit /b %errorlevel%
)

echo Local Airtable Template Generator
echo.
set /p "TEMPLATE_PATH=HTML template path: "
set /p "RECORD_ID=Default Airtable record ID: "
set /p "RECORD_MAP=Record-map JSON file (optional): "
set /p "OUTPUT_PATH=Output directory (optional): "

if not defined TEMPLATE_PATH (
  echo ERROR: Template path is required.
  exit /b 1
)
if not defined RECORD_ID (
  echo ERROR: Airtable record ID is required.
  exit /b 1
)

set "COMMAND_ARGS=--template "%TEMPLATE_PATH%" --record-id "%RECORD_ID%" --format both"
if defined RECORD_MAP set "COMMAND_ARGS=%COMMAND_ARGS% --record-map "%RECORD_MAP%""
if defined OUTPUT_PATH set "COMMAND_ARGS=%COMMAND_ARGS% --output "%OUTPUT_PATH%""

echo.
node "%~dp0local-airtable-template-generator.js" %COMMAND_ARGS%
set "RESULT=%errorlevel%"
echo.
if "%RESULT%"=="0" echo Generation finished successfully.
if not "%RESULT%"=="0" echo Generation failed. Exit code: %RESULT%
pause
exit /b %RESULT%
