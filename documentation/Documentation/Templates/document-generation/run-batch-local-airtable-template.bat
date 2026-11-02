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

rem Arguments are passed straight through for command-line use.
if not "%~1"=="" (
  node "%~dp0batch-local-airtable-template-generator.js" %*
  exit /b %errorlevel%
)

echo Batch Local Airtable Template Generator
echo.
echo Press Enter at the first prompt to use batch_local_template_config.json.
echo.
set /p "INPUT_VIEW_URL=Input Airtable view URL: "

if not defined INPUT_VIEW_URL (
  node "%~dp0batch-local-airtable-template-generator.js"
  goto :finish
)

set /p "TEMPLATE_PATH=HTML template path: "
set /p "RECORD_ID_FIELD_URL=Source record-ID field URL (optional): "
set /p "OUTPUT_NAME_FIELD_URL=Output-name field URL (optional): "
set /p "OUTPUT_PATH=Output directory (optional): "

if not defined TEMPLATE_PATH (
  echo ERROR: Template path is required.
  exit /b 1
)

set "COMMAND_ARGS=--input-view-url "%INPUT_VIEW_URL%" --template "%TEMPLATE_PATH%""
if defined RECORD_ID_FIELD_URL set "COMMAND_ARGS=%COMMAND_ARGS% --record-id-field-url "%RECORD_ID_FIELD_URL%""
if defined OUTPUT_NAME_FIELD_URL set "COMMAND_ARGS=%COMMAND_ARGS% --output-name-field-url "%OUTPUT_NAME_FIELD_URL%""
if defined OUTPUT_PATH set "COMMAND_ARGS=%COMMAND_ARGS% --output "%OUTPUT_PATH%""

echo.
node "%~dp0batch-local-airtable-template-generator.js" %COMMAND_ARGS%

:finish
set "RESULT=%errorlevel%"
echo.
if "%RESULT%"=="0" echo Batch generation finished successfully.
if not "%RESULT%"=="0" echo Batch generation failed. Exit code: %RESULT%
pause
exit /b %RESULT%
