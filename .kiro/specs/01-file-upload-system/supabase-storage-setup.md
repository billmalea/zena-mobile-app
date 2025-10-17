# Supabase Storage Bucket Configuration Guide

## Overview
This guide walks you through configuring the `property-media` bucket in Supabase Storage for the file upload system.

**Supabase Project:** https://jwbdrjcddfkirzcxzbjv.supabase.co

## Step 1: Create the Storage Bucket

1. Go to your Supabase Dashboard: https://app.supabase.com/project/jwbdrjcddfkirzcxzbjv/storage/buckets
2. Click **"New bucket"**
3. Configure the bucket:
   - **Name:** `property-media`
   - **Public bucket:** ✅ Check this box (allows public read access to files)
   - **File size limit:** 10 MB (10485760 bytes)
   - **Allowed MIME types:** Leave empty or add: `video/mp4, video/quicktime, video/x-msvideo, video/webm`
4. Click **"Create bucket"**

## Step 2: Configure Bucket Policies

After creating the bucket, you need to set up Row Level Security (RLS) policies to control access.

### Option A: Using the Supabase Dashboard (Recommended)

1. Go to **Storage** → **Policies** in your Supabase Dashboard
2. Select the `property-media` bucket
3. Click **"New Policy"** and create the following policies:

#### Policy 1: Allow Authenticated Users to Upload to Their Own Folder

- **Policy Name:** `Users can upload to own folder`
- **Allowed operation:** INSERT
- **Target roles:** authenticated
- **USING expression:** (leave empty)
- **WITH CHECK expression:**
```sql
bucket_id = 'property-media' AND (storage.foldername(name))[1] = auth.uid()::text
```

#### Policy 2: Allow Public Read Access

- **Policy Name:** `Public read access`
- **Allowed operation:** SELECT
- **Target roles:** public
- **USING expression:**
```sql
bucket_id = 'property-media'
```
- **WITH CHECK expression:** (leave empty)

#### Policy 3: Allow Users to Delete Their Own Files

- **Policy Name:** `Users can delete own files`
- **Allowed operation:** DELETE
- **Target roles:** authenticated
- **USING expression:**
```sql
bucket_id = 'property-media' AND (storage.foldername(name))[1] = auth.uid()::text
```

### Option B: Using SQL Editor

Alternatively, you can run this SQL script in the Supabase SQL Editor:

1. Go to **SQL Editor** in your Supabase Dashboard
2. Create a new query
3. Copy and paste the SQL from `supabase-storage-policies.sql` (see below)
4. Click **"Run"**

## Step 3: Verify Bucket Configuration

After setting up the bucket and policies, verify the configuration:

1. **Check bucket exists:**
   - Go to Storage → Buckets
   - Confirm `property-media` bucket is listed
   - Confirm it's marked as "Public"

2. **Check policies:**
   - Go to Storage → Policies
   - Select `property-media` bucket
   - Confirm all 3 policies are active

3. **Test upload (see Step 4 below)**

## Step 4: Test Bucket Access

Run the test script to verify the bucket is configured correctly:

```bash
# From the project root
flutter test test/supabase_storage_test.dart
```

Or manually test in the app:
1. Run the app on a device/emulator
2. Navigate to the chat screen
3. Tap the attach button
4. Select a video file
5. Verify the upload completes successfully
6. Check the Supabase Storage dashboard to see the uploaded file

## Expected File Structure

Files will be organized in the bucket as follows:

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

Each user has their own folder (named with their user ID), and files are named with a timestamp and UUID to ensure uniqueness.

## Troubleshooting

### Issue: "new row violates row-level security policy"
**Solution:** Check that the INSERT policy is correctly configured with the WITH CHECK expression.

### Issue: "permission denied for bucket"
**Solution:** Verify the bucket is marked as public, or check that the SELECT policy allows public access.

### Issue: Files not visible after upload
**Solution:** Check that the public read policy is active and the bucket is marked as public.

### Issue: Cannot upload files
**Solution:** 
- Verify user is authenticated
- Check that the file path starts with the user's ID
- Verify the INSERT policy allows uploads to user folders

## Security Notes

- Users can only upload files to their own folder (enforced by RLS policy)
- Users can only delete their own files (enforced by RLS policy)
- All users can read all files (public bucket)
- File names are generated with UUIDs to prevent overwrites
- File size is limited to 10MB (enforced by bucket settings and client-side validation)

## Next Steps

After completing this configuration:
1. ✅ Mark task 4 as complete in tasks.md
2. Move to task 5: End-to-End Integration Testing
3. Test the complete file upload flow on real devices
