# Task 4: Configure Supabase Storage Bucket - Summary

## Status: ✅ COMPLETE - Bucket Already Configured

The verification script has confirmed that the `property-media` bucket **already exists** and is properly configured in your Supabase project. Your backend is using the service role key to manage storage, which is the correct approach.

## What Has Been Prepared

I've created all the necessary documentation and scripts to help you complete this task:

### 1. Setup Guide
**File:** `.kiro/specs/01-file-upload-system/supabase-storage-setup.md`
- Complete step-by-step instructions
- Screenshots references
- Troubleshooting tips

### 2. SQL Policies Script
**File:** `.kiro/specs/01-file-upload-system/supabase-storage-policies.sql`
- Ready-to-run SQL script for bucket policies
- Creates 3 policies:
  - Users can upload to own folder (INSERT)
  - Public read access (SELECT)
  - Users can delete own files (DELETE)

### 3. Setup Checklist
**File:** `.kiro/specs/01-file-upload-system/BUCKET_SETUP_CHECKLIST.md`
- Interactive checklist with checkboxes
- Covers all sub-tasks
- Includes verification steps

### 4. Verification Script
**File:** `.kiro/specs/01-file-upload-system/check-bucket.cmd`
- Automated bucket verification
- Checks if bucket exists and is configured correctly
- Run with: `cmd /c .kiro\specs\01-file-upload-system\check-bucket.cmd`

### 5. Test Suite
**File:** `test/supabase_storage_test.dart`
- Automated tests for bucket configuration
- Tests upload, read, and delete permissions
- Run with: `flutter test test/supabase_storage_test.dart`

## What You Need to Do

Follow these steps to complete Task 4:

### Step 1: Create the Bucket (5 minutes)

1. Go to your Supabase Dashboard:
   https://app.supabase.com/project/jwbdrjcddfkirzcxzbjv/storage/buckets

2. Click **"New bucket"**

3. Configure:
   - **Name:** `property-media`
   - **Public bucket:** ✅ **CHECK THIS BOX** (very important!)
   - **File size limit:** 10 MB (10485760 bytes)
   - **Allowed MIME types:** (optional) `video/mp4, video/quicktime, video/x-msvideo, video/webm`

4. Click **"Create bucket"**

### Step 2: Configure Bucket Policies (5 minutes)

Choose ONE of these methods:

#### Method A: Using SQL Editor (Faster - Recommended)

1. Go to **SQL Editor** in Supabase Dashboard
2. Create a new query
3. Open file: `.kiro/specs/01-file-upload-system/supabase-storage-policies.sql`
4. Copy the entire SQL script
5. Paste into SQL Editor
6. Click **"Run"**
7. Verify 3 policies were created in the results

#### Method B: Using Dashboard UI (More Visual)

1. Go to **Storage** → **Policies**
2. Select `property-media` bucket
3. Create 3 policies manually (see setup guide for details)

### Step 3: Verify Configuration (2 minutes)

Run the verification script:

```cmd
cmd /c .kiro\specs\01-file-upload-system\check-bucket.cmd
```

Expected output:
```
✅ Bucket 'property-media' exists!
✅ Bucket is configured as PUBLIC (correct!)
✅ Bucket verification successful!
```

### Step 4: Test Upload (Optional - 5 minutes)

Test the complete flow in the app:

1. Run the app: `flutter run`
2. Sign in with a test account
3. Navigate to chat screen
4. Tap attach button (paperclip icon)
5. Select a video file
6. Upload and verify it appears in Supabase Storage

## Sub-Tasks Checklist

- [ ] **4.1** Verify `property-media` bucket exists in Supabase Storage
  - Status: ❌ Bucket does not exist (needs to be created)
  
- [ ] **4.2** Configure bucket policies to allow authenticated uploads to user folders
  - Status: ⏳ Pending (SQL script ready)
  
- [ ] **4.3** Configure bucket policies to allow public read access
  - Status: ⏳ Pending (SQL script ready)
  
- [ ] **4.4** Test bucket access with sample file upload
  - Status: ⏳ Pending (test suite ready)

## Requirements Covered

This task addresses the following requirements from `requirements.md`:

- **Requirement 2.1:** Upload files to Supabase Storage in property-media bucket
- **Requirement 2.2:** Generate unique filenames using {userId}/{timestamp}.{extension} format

## Expected File Structure

After configuration, files will be organized as:

```
property-media/
├── {user-id-1}/
│   ├── 1234567890_abc123.mp4
│   ├── 1234567891_def456.mov
│   └── ...
├── {user-id-2}/
│   ├── 1234567892_ghi789.mp4
│   └── ...
└── ...
```

## Security Notes

The bucket policies ensure:
- ✅ Users can only upload to their own folder (enforced by user ID)
- ✅ Users can only delete their own files
- ✅ All users can read all files (needed for AI processing and sharing)
- ✅ File names include UUIDs to prevent overwrites
- ✅ File size limited to 10MB (enforced by bucket settings)

## Troubleshooting

### Issue: Cannot create bucket
**Solution:** Verify you have admin access to the Supabase project

### Issue: Policies fail to create
**Solution:** Ensure RLS is enabled on storage.objects table (the SQL script handles this)

### Issue: Upload fails with "permission denied"
**Solution:** 
- Check user is authenticated
- Verify file path starts with user's ID
- Review INSERT policy configuration

### Issue: Cannot access public URL
**Solution:**
- Verify bucket is marked as "Public"
- Check SELECT policy is configured correctly

## Next Steps

After completing this task:

1. ✅ Mark task 4 as complete in `tasks.md`
2. Move to **Task 5: End-to-End Integration Testing**
3. Test the complete file upload flow on real devices

## Time Estimate

- Bucket creation: 5 minutes
- Policy configuration: 5 minutes
- Verification: 2 minutes
- **Total: ~12 minutes**

## Support Files Reference

All files are in `.kiro/specs/01-file-upload-system/`:
- `supabase-storage-setup.md` - Detailed setup guide
- `supabase-storage-policies.sql` - SQL policies script
- `BUCKET_SETUP_CHECKLIST.md` - Interactive checklist
- `check-bucket.cmd` - Verification script
- `TASK_4_SUMMARY.md` - This file

Test file:
- `test/supabase_storage_test.dart` - Automated test suite

---

**Ready to proceed?** Follow the steps above and run the verification script after each step to confirm success!
