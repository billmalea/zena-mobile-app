@echo off
REM Batch script to verify Supabase Storage bucket configuration
REM Run with: check-bucket.cmd

echo 🔍 Verifying Supabase Storage Bucket Configuration...
echo.

REM Read .env.local file
if not exist ".env.local" (
    echo ❌ Error: .env.local file not found
    exit /b 1
)

REM Extract Supabase URL and key
for /f "tokens=1,2 delims==" %%a in (.env.local) do (
    if "%%a"=="SUPABASE_URL" set SUPABASE_URL=%%b
    if "%%a"=="SUPABASE_ANON_KEY" set SUPABASE_ANON_KEY=%%b
)

if "%SUPABASE_URL%"=="" (
    echo ❌ Error: SUPABASE_URL not found in .env.local
    exit /b 1
)

if "%SUPABASE_ANON_KEY%"=="" (
    echo ❌ Error: SUPABASE_ANON_KEY not found in .env.local
    exit /b 1
)

echo 📡 Connecting to Supabase...
echo    URL: %SUPABASE_URL%
echo.

set BUCKET_NAME=property-media
set API_URL=%SUPABASE_URL%/storage/v1/bucket/%BUCKET_NAME%

echo 🗂️  Checking bucket: %BUCKET_NAME%...
echo.

REM Use curl to check bucket
curl -s -X GET "%API_URL%" ^
  -H "apikey: %SUPABASE_ANON_KEY%" ^
  -H "Authorization: Bearer %SUPABASE_ANON_KEY%" > bucket_response.json

if errorlevel 1 (
    echo ❌ Error: Could not connect to Supabase
    del bucket_response.json 2>nul
    exit /b 1
)

REM Check if response contains error
findstr /C:"\"error\"" bucket_response.json >nul
if not errorlevel 1 (
    echo ❌ Bucket '%BUCKET_NAME%' does not exist!
    echo.
    echo 📝 To create the bucket:
    echo    1. Go to: https://app.supabase.com/project/jwbdrjcddfkirzcxzbjv/storage/buckets
    echo    2. Click 'New bucket'
    echo    3. Name: property-media
    echo    4. Check 'Public bucket'
    echo    5. File size limit: 10 MB
    echo    6. Click 'Create bucket'
    echo.
    del bucket_response.json
    exit /b 1
)

echo ✅ Bucket '%BUCKET_NAME%' exists!
echo.

REM Check if bucket is public
findstr /C:"\"public\":true" bucket_response.json >nul
if not errorlevel 1 (
    echo ✅ Bucket is configured as PUBLIC (correct!)
) else (
    echo ⚠️  WARNING: Bucket is NOT public!
    echo    You need to recreate the bucket with 'Public bucket' checked
)

echo.
echo ✅ Bucket verification successful!
echo.
echo 📋 Next steps:
echo    1. Configure bucket policies using the SQL script
echo       File: .kiro/specs/01-file-upload-system/supabase-storage-policies.sql
echo    2. Run the Flutter app and test file upload
echo    3. Check the Supabase dashboard to see uploaded files
echo       URL: https://app.supabase.com/project/jwbdrjcddfkirzcxzbjv/storage/buckets/property-media
echo.

del bucket_response.json
