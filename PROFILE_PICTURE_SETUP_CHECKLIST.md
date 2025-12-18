# Profile Picture Upload - Quick Setup Checklist

## ✅ What's Already Done

### Code Implementation
- ✅ `edit_profil.dart` - Profile picture upload UI (cover photo removed)
- ✅ `profile_tab.dart` - Displays profile picture from database
- ✅ `explore_tab.dart` - Displays profile picture in header
- ✅ `image_picker` dependency in pubspec.yaml
- ✅ Android permissions in AndroidManifest.xml
- ✅ iOS permissions in Info.plist

### Database
- ✅ `foto_profil` column exists in `pengguna` table

## 🚀 Setup Required in Supabase

### 1. Create Storage Bucket (5 minutes)

1. Open **Supabase Dashboard**
2. Go to **Storage** (left sidebar)
3. Click **New Bucket**
4. Configure:
   - Name: `images`
   - Public: ✅ **Yes**
   - File size limit: `5242880` (5MB)
   - Allowed MIME types: `image/jpeg,image/png,image/jpg`
5. Click **Create Bucket**

### 2. Set Storage Policies (2 minutes)

**Option A: Production-Ready Policies (Recommended)**

Go to **SQL Editor** and run:
```sql
-- Copy from: supabase/migrations/20251218_storage_setup.sql
-- Lines 7-46 (the four CREATE POLICY statements)
```

**Option B: Simple Testing Policy (Quick but less secure)**

Go to **SQL Editor** and run:
```sql
CREATE POLICY "Public Access to Images"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'images')
WITH CHECK (bucket_id = 'images');
```

⚠️ For production, use Option A!

### 3. Verify Setup (2 minutes)

1. Go to **Storage** → **images** bucket
2. Try uploading a test image manually
3. Check if you can view the image URL
4. Delete the test image

## 🧪 Testing Steps

### Test 1: Upload Profile Picture
1. Run the app: `flutter run`
2. Navigate to Profile Tab
3. Tap **Edit profil**
4. Tap on the profile picture
5. Select an image from gallery
6. Tap **Simpan**
7. ✅ Should show success message
8. ✅ Profile picture should update immediately

### Test 2: Verify in Database
1. Go to Supabase → **Table Editor** → `pengguna`
2. Find your user record
3. ✅ `foto_profil` should contain a URL like:
   ```
   https://YOUR_PROJECT.supabase.co/storage/v1/object/public/images/avatars/USER_ID_TIMESTAMP.jpg
   ```

### Test 3: Verify in Storage
1. Go to Supabase → **Storage** → `images` → `avatars`
2. ✅ Should see your uploaded image file

### Test 4: Profile Picture Display
1. Check **Profile Tab** - ✅ Large profile picture visible
2. Check **Explore Tab** - ✅ Small avatar in header visible
3. Close and reopen app - ✅ Profile picture persists

## 🐛 Quick Troubleshooting

### Error: "Bucket 'images' not found"
**Fix:** Create the bucket (see Setup Step 1)

### Error: "Permission denied"
**Fix:** Set up storage policies (see Setup Step 2)

### Image doesn't display after upload
**Check:**
1. Bucket is set to **Public**
2. URL is saved in database: Check `pengguna.foto_profil`
3. Try opening URL directly in browser

### "No permission" error on Android
**Fix:** Already added to AndroidManifest.xml ✅

### Image picker doesn't open on iOS
**Fix:** Already added to Info.plist ✅

## 📊 Expected Results

### Before Upload
- Profile Tab: Grey circle with person icon
- Explore Tab: Grey circle with person icon
- Database: `foto_profil` is `NULL` or empty

### After Upload
- Profile Tab: Shows uploaded image
- Explore Tab: Shows uploaded image in header
- Database: `foto_profil` contains Supabase Storage URL
- Storage: Image file exists in `images/avatars/` folder

## 📝 Additional Notes

### Image Specifications
- Max size: 5MB
- Formats: JPEG, PNG, JPG
- Quality: Compressed to 70% on upload
- Naming: `{userId}_{timestamp}.{ext}`

### Storage Costs
- Supabase Free Tier: 1GB storage
- Average profile pic: ~100-500KB
- Estimate: ~2000-10000 profile pictures per GB

### Cleanup
Current implementation doesn't delete old images. Consider:
- Manual cleanup of old profile pictures
- Implementing auto-delete when user uploads new photo
- Setting retention policies in Supabase

## 🎯 Summary

**Total Setup Time: ~10 minutes**

1. ✅ Code is ready (no changes needed)
2. ⏳ Create `images` bucket in Supabase (5 min)
3. ⏳ Set storage policies (2 min)
4. ⏳ Test upload (3 min)

After setup, users can upload profile pictures that will be displayed throughout the app!
