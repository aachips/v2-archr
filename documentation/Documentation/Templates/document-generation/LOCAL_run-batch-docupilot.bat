@echo off
setlocal
cd /d "%~dp0"

if not exist "%~dp0pat.txt" (
  if not defined AIRTABLE_PAT if not defined AIRTABLE_TOKEN (
    echo ERROR: No Airtable PAT found.
    echo Add the token to "%~dp0pat.txt" or set AIRTABLE_PAT.
    exit /b 1
  )
)

rem If arguments were supplied, pass them directly to the Node batch script.
if not "%~1"=="" goto :passthrough

echo Local Document Generator
echo.
echo   1. Single Record
echo   2. All In View
echo.
set /p "GENERATION_MODE=Select mode [1 or 2]: "

if "%GENERATION_MODE%"=="1" goto :single_record
if "%GENERATION_MODE%"=="2" goto :all_in_view
echo ERROR: Select 1 for Single Record or 2 for All In View.
exit /b 1

:single_record
set /p "PROJECT_KEY=projectKEY: "
set /p "DOC_CODE=[[DocCode]]: "
if not defined PROJECT_KEY (
  echo ERROR: projectKEY is required.
  exit /b 1
)
if not defined DOC_CODE (
  echo ERROR: [[DocCode]] is required.
  exit /b 1
)
echo.
node "%~dp0batch-docupilot-generator.js" --mode single --project-key "%PROJECT_KEY%" --doc-code "%DOC_CODE%"
goto :finish

:all_in_view
set /p "INPUT_VIEW_URL=Input view URL: "
set /p "PROJECT_KEY_FIELD_URL=projectKEY field URL on that view: "
set /p "DOC_CODE=[[DocCode]]: "

if not defined INPUT_VIEW_URL (
  echo ERROR: Document Creator view URL is required.
  exit /b 1
)
if not defined PROJECT_KEY_FIELD_URL (
  echo ERROR: projectKEY field URL is required.
  exit /b 1
)
if not defined DOC_CODE (
  echo ERROR: [[DocCode]] is required.
  exit /b 1
)

echo.
node "%~dp0batch-docupilot-generator.js" --mode view --input-view-url "%INPUT_VIEW_URL%" --project-key-field-url "%PROJECT_KEY_FIELD_URL%" --doc-code "%DOC_CODE%"

:finish
set "RESULT=%errorlevel%"

echo.
if not "%RESULT%"=="0" echo Batch finished with errors. Exit code: %RESULT%
if "%RESULT%"=="0" echo Batch finished successfully.
pause
exit /b %RESULT%

:passthrough
node "%~dp0batch-docupilot-generator.js" %*
exit /b %errorlevel%
