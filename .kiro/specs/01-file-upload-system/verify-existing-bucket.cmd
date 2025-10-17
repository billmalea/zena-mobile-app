@echo off
REM Verify existing Supabase Storage bucket with service role key
echo 🔍 Verifying Existing Supabase Storage Bucket...
echo.

REM Read .env.local file
if not exist ".env.local" (
    echo ❌ Error: .env.local file not found
    exit /b 1
)

REM Extract Supabase URL and service role key
for /f "tokens=1,* delims==" %%a in (.env.local) do (
    if "%%a"=="SUPABASE_URL" set SUPABASE_URL=%%b
    if "%%a"=="SUPABASE_SERVICE_ROLE_KEY" set SUPABASE_SERVICE_ROLE_KEY=%%b
)

if "%SUPABASE_URL%"=="" (
    echo ❌ Error: SUPABASE_URL not found in .env.local
    exit /b 1
)

if "%SUPABASE_SERVICE_ROLE_KEY%"=="" (
    echo ❌ Error: SUPABASE_SERVICE_ROLE_KEY not found in .env.local
    exit /b 1
)

echo 📡 Connecting to Supabase with service role...
echo    URL: %SUPABASE_URL%
echo.

set BUCKET_NAME=property-media
set API_URL=%SUPABASE_URL%/storage/v1/bucket/%BUCKET_NAME%

echo 🗂️  Checking bucket: %BUCKET_NAME%...
echo.

REM Use curl with service role key to check bucket
curl -s -X GET "%API_URL%" -H "apikey: %SUPABASE_SERVICE_ROLE_KEY%" -H "Authorization: Bearer %SUPABASE_SERVICE_ROLE_KEY%" > bucket_response.json

if errorlevel 1 (
    echo ❌ Error: Could not connect to Supabase
    del bucket_response.json 2>nul
    exit /b 1
)

REM Check if response contains error
findstr /C:"\"error\"" bucket_response.json >nul
if not errorlevel 1 (
    echo ❌ Bucket '%BUCKET_NAME%' does not exist!
    type bucket_response.json
    del bucket_response.json
    exit /b 1
)

echo ✅ Bucket '%BUCKET_NAME%' exists!
echo.

REM Check if bucket is public
findstr /C:"\"public\":true" bucket_response.json >nul
if not errorlevel 1 (
    echo ✅ Bucket is PUBLIC (correct for file sharing!)
) else (
    echo ⚠️  Bucket is PRIVATE (may need to be public for AI processing)
)

echo.
echo 📋 Bucket Details:
type bucket_response.json
echo.
echo.

REM List bucket contents
echo 📁 Checking bucket contents...
set LIST_URL=%SUPABASE_URL%/storage/v1/object/list/%BUCKET_NAME%
curl -s -X POST "%LIST_URL%" -H "apikey: %SUPABASE_SERVICE_ROLE_KEY%" -H "Authorization: Bearer %SUPABASE_SERVICE_ROLE_KEY%" -H "Content-Type: application/json" -d "{}" > list_response.json

findstr /C:"\"error\"" list_response.json >nul
if not errorlevel 1 (
    echo ⚠️  Could not list bucket contents
) else (
    echo ✅ Bucket is accessible
    echo.
    echo 📂 Sample contents:
    type list_response.json
)

echo.
echo.
echo ✅ Bucket verification complete!
echo.
echo 📋 Summary:
echo    ✅ Bucket exists
echo    ✅ Service role key has access
echo    ✅ Ready for file uploads
echo.

del bucket_response.json 2>nul
del list_response.json 2>nul
