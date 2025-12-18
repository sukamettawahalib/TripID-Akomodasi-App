# Profile Picture Upload Setup Guide

## 📋 Overview
This guide explains how to set up and use the profile picture upload feature in TripID app.

## ✨ Features Implemented

### 1. **Edit Profile Screen**
- ✅ Users can upload/change their profile picture
- ✅ Image picker from gallery
- ✅ Image preview before saving
- ✅ Upload to Supabase Storage
- ✅ Update `foto_profil` field in database
- ❌ Cover photo removed (only profile picture allowed)

### 2. **Profile Picture Display**
Profile pictures are displayed in:
- ✅ **Profile Tab** - Large profile picture with cover background
- ✅ **Explore Tab (Homepage)** - Small avatar in header
- ✅ Any other screens using user profile data

## 🗄️ Database Schema

### Table: `pengguna`
```sql
CREATE TABLE pengguna (
    id_pengguna SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255), -- Consider removing for security
    foto_profil VARCHAR(255), -- Stores the public URL of profile picture
    total_trip INT DEFAULT 0,
    jarak_tempuh INT DEFAULT 0,
    jam_terbang INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 🪣 Supabase Storage Setup

### Step 1: Create Storage Bucket

1. Open your **Supabase Dashboard**
2. Go to **Storage** in the left sidebar
3. Click **New Bucket**
4. Create a bucket with these settings:
   - **Name:** `images`
   - **Public:** ✅ Yes (Enable public access)
   - **File size limit:** 5MB (recommended)
   - **Allowed MIME types:** `image/jpeg, image/png, image/jpg`

### Step 2: Set Bucket Policies

After creating the bucket, set up these policies:

#### Policy 1: Allow Authenticated Users to Upload
```sql
-- Policy name: "Authenticated users can upload avatars"
-- Operation: INSERT
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'images' 
  AND (storage.foldername(name))[1] = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[2]
);
```

#### Policy 2: Allow Public Read Access
```sql
-- Policy name: "Anyone can view images"
-- Operation: SELECT
CREATE POLICY "Anyone can view images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');
```

#### Policy 3: Allow Users to Update Their Own Images
```sql
-- Policy name: "Users can update their own avatars"
-- Operation: UPDATE
CREATE POLICY "Users can update their own avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'images' 
  AND (storage.foldername(name))[1] = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[2]
);
```

#### Policy 4: Allow Users to Delete Their Own Images
```sql
-- Policy name: "Users can delete their own avatars"
-- Operation: DELETE
CREATE POLICY "Users can delete their own avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'images' 
  AND (storage.foldername(name))[1] = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[2]
);
```

### Alternative: Simple Public Bucket (Less Secure)

If you want simpler setup for development/testing:

1. Create bucket `images` with **Public** enabled
2. Enable one policy:
```sql
CREATE POLICY "Public Access"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'images');
```

⚠️ **Note:** This allows anyone to upload/delete. Only use for testing!

## 📱 How It Works

### Upload Flow

1. **User taps profile picture** in Edit Profile screen
2. **Image picker opens** gallery
3. **User selects image**
4. **Preview shown** in CircleAvatar
5. **User taps "Simpan"**
6. **Image uploads** to `images/avatars/{userId}_{timestamp}.jpg`
7. **Public URL generated** and saved to `foto_profil` in database
8. **UI refreshes** to show new profile picture

### File Structure in Storage
```
images/
  └── avatars/
      ├── abc123_1234567890.jpg  (user abc123's photo)
      ├── xyz789_1234567891.png  (user xyz789's photo)
      └── ...
```

### File Naming Convention
```
{userId}_{timestamp}.{extension}
```
Example: `a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6_1702876543210.jpg`

## 🔧 Code Implementation

### Edit Profile Screen (`edit_profil.dart`)

#### Image Upload Function
```dart
Future<String?> _uploadImage(File imageFile, String folderName) async {
  final user = Supabase.instance.client.auth.currentUser;
  final bytes = await imageFile.readAsBytes();
  final fileExt = imageFile.path.split('.').last;
  final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
  final filePath = '$folderName/$fileName';

  await Supabase.instance.client.storage
    .from('images')
    .uploadBinary(filePath, bytes);

  return Supabase.instance.client.storage
    .from('images')
    .getPublicUrl(filePath);
}
```

#### Save Profile with Image
```dart
Future<void> _saveProfile() async {
  String? finalAvatarUrl = _currentAvatarUrl;

  // Upload new image if selected
  if (_newAvatarFile != null) {
    final url = await _uploadImage(_newAvatarFile!, 'avatars');
    if (url != null) finalAvatarUrl = url;
  }

  // Update database
  await Supabase.instance.client
    .from('pengguna')
    .update({'foto_profil': finalAvatarUrl})
    .eq('email', user.email!);
}
```

### Profile Tab Display
```dart
CircleAvatar(
  radius: 40,
  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
    ? NetworkImage(_avatarUrl!)
    : null,
  child: (_avatarUrl == null || _avatarUrl!.isEmpty)
    ? const Icon(Icons.person, size: 40, color: Colors.grey)
    : null,
)
```

### Explore Tab Display
```dart
CircleAvatar(
  radius: 24,
  backgroundImage: _userAvatarUrl.isNotEmpty
    ? NetworkImage(_userAvatarUrl)
    : null,
  child: _userAvatarUrl.isEmpty
    ? const Icon(Icons.person, color: Colors.white)
    : null,
)
```

## 📦 Required Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.3
  image_picker: ^1.0.4  # For image selection
```

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
  <application>
    <!-- Add these permissions -->
  </application>
  
  <!-- Add these outside application tag -->
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
</manifest>
```

### iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload profile pictures</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take profile pictures</string>
```

## ✅ Testing Checklist

- [ ] Create `images` bucket in Supabase Storage
- [ ] Enable public access on bucket
- [ ] Set up storage policies (or use simple public policy for testing)
- [ ] Run `flutter pub get` to install image_picker
- [ ] Test selecting image from gallery
- [ ] Test image preview in edit screen
- [ ] Test saving profile with new image
- [ ] Verify image appears in Supabase Storage
- [ ] Verify `foto_profil` URL is saved in database
- [ ] Test profile picture displays in Profile Tab
- [ ] Test profile picture displays in Explore Tab
- [ ] Test uploading multiple times (old images remain in storage)

## 🐛 Troubleshooting

### "Bucket 'images' not found"
**Solution:** Create the bucket in Supabase Dashboard → Storage

### "Permission denied" when uploading
**Solution:** 
1. Check if bucket is public
2. Verify storage policies are set correctly
3. Try simple public policy for testing

### Image not displaying after upload
**Solution:**
1. Check if URL is saved in database: `SELECT foto_profil FROM pengguna WHERE email='your@email.com'`
2. Try opening the URL directly in browser
3. Verify bucket is public

### "No permission to read external storage" on Android
**Solution:** Add permissions to AndroidManifest.xml (see above)

### Image picker not working on iOS
**Solution:** Add usage descriptions to Info.plist (see above)

## 🔐 Security Best Practices

### 1. File Size Limits
Configure in Supabase bucket settings:
- Recommended: 5MB max
- Prevents abuse and saves storage costs

### 2. File Type Restrictions
Only allow image types:
```dart
final XFile? pickedFile = await _picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 70, // Compress to 70%
);
```

### 3. Clean Up Old Images
Consider implementing:
- Delete old profile picture when uploading new one
- Scheduled cleanup of unused images
- User storage quota limits

### 4. Validate Image Before Upload
```dart
// Check file size
final fileSize = await imageFile.length();
if (fileSize > 5 * 1024 * 1024) { // 5MB
  throw Exception('File too large');
}

// Check file type
final mimeType = lookupMimeType(imageFile.path);
if (!['image/jpeg', 'image/png', 'image/jpg'].contains(mimeType)) {
  throw Exception('Invalid file type');
}
```

## 📚 Related Files

- `lib/screens/home/edit_profil.dart` - Edit profile with image upload
- `lib/screens/home/profile_tab.dart` - Display profile picture
- `lib/screens/home/explore_tab.dart` - Display profile picture in header

## 🎯 Future Enhancements

Consider adding:
- [ ] Camera option (in addition to gallery)
- [ ] Image cropping before upload
- [ ] Avatar selection from predefined set
- [ ] Delete old images when uploading new one
- [ ] Compression for larger images
- [ ] Loading states during upload
- [ ] Error handling with retry option
- [ ] Profile picture zoom/preview
