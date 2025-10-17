# Supabase Storage Bucket Setup Checklist

Use this checklist to complete Task 4: Configure Supabase Storage Bucket

## Prerequisites
- [ ] Supabase account with access to project: https://jwbdrjcddfkirzcxzbjv.supabase.co
- [ ] Admin access to the Supabase dashboard

---

## Part 1: Create the Bucket

- [ ] **1.1** Navigate to Supabase Storage
  - Go to: https://app.supabase.com/project/jwbdrjcddfkirzcxzbjv/storage/buckets
  
- [ ] **1.2** Create new bucket
  - Click "New bucket" button
  - Name: `property-media`
  - Public bucket: ✅ **CHECKED** (important!)
  - File size limit: 10 MB (10485760 bytes)
  - Allowed MIME types: (optional) `video/mp4, video/quicktime, video/x-msvideo, video/webm`
  - Click "Create bucket"

- [ ] **1.3** Verify bucket creation
  - Bucket appears in the list
  - Shows "Public" badge
  - No errors displayed

---

## Part 2: Configure Bucket Policies

Choose **ONE** of the following methods:

### Method A: Using Supabase Dashboard (Easier)

- [ ] **2.1** Navigate to Storage Policies
  - Go to: Storage → Policies
  - Select `property-media` bucket

- [ ] **2.2** Create Policy 1: Upload to Own Folder
  - Click "New Policy"
  - Policy name: `Users can upload to own folder`
  - Allowed operation: **INSERT**
  - Target roles: **authenticated**
  - WITH CHECK expression:
    ```sql
    bucket_id = 'property-media' AND (storage.foldername(name))[1] = auth.uid()::text
    ```
  - Click "Save"

- [ ] **2.3** Create Policy 2: Public Read Access
  - Click "New Policy"
  - Policy name: `Public read access`
  - Allowed operation: **SELECT**
  - Target roles: **public**
  - USING expression:
    ```sql
    bucket_id = 'property-media'
    ```
  - Click "Save"

- [ ] **2.4** Create Policy 3: Delete Own Files
  - Click "New Policy"
  - Policy name: `Users can delete own files`
  - Allowed operation: **DELETE**
  - Target roles: **authenticated**
  - USING expression:
    ```sql
    bucket_id = 'property-media' AND (storage.foldername(name))[1] = auth.uid()::text
    ```
  - Click "Save"

### Method B: Using SQL Editor (Faster)

- [ ] **2.1** Navigate to SQL Editor
  - Go to: SQL Editor in Supabase Dashboard

- [ ] **2.2** Run the SQL script
  - Open file: `.kiro/specs/01-file-upload-system/supabase-storage-policies.sql`
  - Copy the entire SQL script
  - Paste into SQL Editor
  - Click "Run"

- [ ] **2.3** Verify policies created
  - Check the query results
  - Should show 3 policies created

---

## Part 3: Verify Configuration

- [ ] **3.1** Check bucket in dashboard
  - Go to: Storage → Buckets
  - Confirm `property-media` exists
  - Confirm "Public" badge is visible

- [ ] **3.2** Check policies in dashboard
  - Go to: Storage → Policies
  - Select `property-media` bucket
  - Confirm 3 policies are listed:
    - ✅ Users can upload to own folder (INSERT)
    - ✅ Public read access (SELECT)
    - ✅ Users can delete own files (DELETE)

- [ ] **3.3** Run verification script
  ```bash
  dart run .kiro/specs/01-file-upload-system/verify-bucket.dart
  ```
  - Script should output: "✅ Bucket verification successful!"
  - If errors, review the output and fix issues

---

## Part 4: Test Bucket Access

Choose **ONE** of the following test methods:

### Option A: Manual Test in App

- [ ] **4.1** Run the Flutter app
  ```bash
  flutter run
  ```

- [ ] **4.2** Sign in to the app
  - Use a test account or create a new one

- [ ] **4.3** Navigate to chat screen
  - Open any conversation or create a new one

- [ ] **4.4** Test file upload
  - Tap the attach button (paperclip icon)
  - Select "Gallery" or "Camera"
  - Choose a video file (or record one)
  - Tap "Upload"
  - Wait for upload to complete

- [ ] **4.5** Verify upload in Supabase
  - Go to: Storage → property-media bucket
  - Look for a folder named with your user ID
  - Confirm the uploaded file is there
  - Click the file to view details
  - Copy the public URL and open in browser
  - Confirm the file is accessible

### Option B: Automated Test

- [ ] **4.1** Run the test suite
  ```bash
  flutter test test/supabase_storage_test.dart
  ```

- [ ] **4.2** Review test results
  - All tests should pass
  - Check for any warnings or errors

---

## Part 5: Final Verification

- [ ] **5.1** Bucket exists and is public
- [ ] **5.2** Upload policy allows authenticated users to upload to own folder
- [ ] **5.3** Read policy allows public access to all files
- [ ] **5.4** Delete policy allows users to delete own files
- [ ] **5.5** Test upload completed successfully
- [ ] **5.6** Uploaded file is accessible via public URL

---

## Troubleshooting

### Issue: Bucket creation fails
- **Check:** Do you have admin access to the Supabase project?
- **Solution:** Contact project owner for admin access

### Issue: Policy creation fails
- **Check:** Is RLS enabled on storage.objects table?
- **Solution:** Run: `ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;`

### Issue: Upload fails with "permission denied"
- **Check:** Is the user authenticated?
- **Check:** Is the file path starting with the user's ID?
- **Solution:** Review the INSERT policy configuration

### Issue: Cannot access public URL
- **Check:** Is the bucket marked as "Public"?
- **Check:** Is the SELECT policy configured correctly?
- **Solution:** Recreate the bucket as public or fix the SELECT policy

### Issue: Verification script fails
- **Check:** Is .env.local file present with correct credentials?
- **Check:** Is the bucket name spelled correctly?
- **Solution:** Review error message and fix configuration

---

## Completion

Once all checkboxes are marked:

- [ ] Update task status in `.kiro/specs/01-file-upload-system/tasks.md`
- [ ] Mark task 4 as complete: `[x] 4. Configure Supabase Storage Bucket`
- [ ] Proceed to task 5: End-to-End Integration Testing

---

## Reference Files

- Setup guide: `.kiro/specs/01-file-upload-system/supabase-storage-setup.md`
- SQL policies: `.kiro/specs/01-file-upload-system/supabase-storage-policies.sql`
- Verification script: `.kiro/specs/01-file-upload-system/verify-bucket.dart`
- Test suite: `test/supabase_storage_test.dart`
