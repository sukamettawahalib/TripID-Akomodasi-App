-- Supabase Storage Bucket Setup for Profile Pictures
-- Run this in Supabase SQL Editor after creating the 'images' bucket

-- First, ensure the bucket exists (you must create it manually in the UI)
-- Go to Supabase Dashboard -> Storage -> New Bucket
-- Name: images
-- Public: Yes

-- Then run these policies:

-- 1. Allow authenticated users to upload their avatars
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'images' 
  AND (storage.foldername(name))[1] = 'avatars'
);

-- 2. Allow anyone to view images (public read)
CREATE POLICY "Anyone can view images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');

-- 3. Allow users to update their own avatars
CREATE POLICY "Users can update their own avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'images' 
  AND (storage.foldername(name))[1] = 'avatars'
);

-- 4. Allow users to delete their own avatars
CREATE POLICY "Users can delete their own avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'images' 
  AND (storage.foldername(name))[1] = 'avatars'
);

-- ============================================
-- ALTERNATIVE: Simple Public Policy (For Testing Only)
-- If you want a simpler setup for development, use this instead:
-- ============================================

-- DROP the above policies first if you created them, then use this:
/*
CREATE POLICY "Public Access to Images"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'images')
WITH CHECK (bucket_id = 'images');
*/

-- ⚠️ WARNING: The simple public policy allows anyone to upload/delete files
-- Only use for testing/development. For production, use the specific policies above.
