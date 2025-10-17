-- Supabase Storage Policies for property-media bucket
-- Run this script in the Supabase SQL Editor after creating the bucket

-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to allow re-running this script)
DROP POLICY IF EXISTS "Users can upload to own folder" ON storage.objects;
DROP POLICY IF EXISTS "Public read access" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own files" ON storage.objects;

-- Policy 1: Allow authenticated users to upload files to their own folder
-- This ensures users can only upload to folders named with their user ID
CREATE POLICY "Users can upload to own folder"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'property-media' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 2: Allow public read access to all files in the bucket
-- This allows anyone to view/download files (needed for AI processing and sharing)
CREATE POLICY "Public read access"
ON storage.objects
FOR SELECT
TO public
USING (
  bucket_id = 'property-media'
);

-- Policy 3: Allow authenticated users to delete their own files
-- This ensures users can only delete files in their own folder
CREATE POLICY "Users can delete own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'property-media' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Verify policies were created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects' 
  AND (
    policyname = 'Users can upload to own folder' 
    OR policyname = 'Public read access'
    OR policyname = 'Users can delete own files'
  );
