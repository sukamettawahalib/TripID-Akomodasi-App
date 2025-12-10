# TripID Authentication Implementation Guide

## 📋 Overview
This guide explains the complete authentication system implemented for TripID using Supabase OTP (One-Time Password) verification.

## 🔐 Authentication Flow

### Registration Flow
```
1. RegisterEmailScreen → User enters email
2. OTP sent to email via Supabase
3. VerificationScreen → User enters 6-digit OTP
4. OTP verified with Supabase
5. RegisterDetailsScreen → User sets username & password
6. User profile created in 'pengguna' table
7. Redirect to LoginScreen
```

### Login Flow
```
1. LoginScreen → User enters email & password
2. Authenticate with Supabase
3. Redirect to HomeScreen
```

## 📁 File Structure

### Service Layer
- **`lib/services/auth_service.dart`** - All authentication logic with Supabase

### Screen Files
1. **`lib/screens/auth/register_email_screen.dart`** - Email registration
2. **`lib/screens/auth/verification_screen.dart`** - OTP verification
3. **`lib/screens/auth/register_details_screen.dart`** - Username & password setup
4. **`lib/screens/auth/login_screen.dart`** - User login

## 🛠️ AuthService Methods

### `sendOtpToEmail(String email)`
Sends a 6-digit OTP to the provided email address.
```dart
final result = await authService.sendOtpToEmail('user@example.com');
```

### `verifyOtp({required String email, required String otpCode})`
Verifies the OTP code entered by the user.
```dart
final result = await authService.verifyOtp(
  email: 'user@example.com',
  otpCode: '123456',
);
```

### `completeRegistration({required String username, required String password})`
Creates user profile in the database after successful OTP verification.
```dart
final result = await authService.completeRegistration(
  username: 'johndoe',
  password: 'securePassword123',
);
```

### `signInWithEmail({required String email, required String password})`
Authenticates user with email and password.
```dart
final result = await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);
```

### `signOut()`
Signs out the current user.
```dart
await authService.signOut();
```

### `getUserProfile()`
Retrieves user profile from the 'pengguna' table.
```dart
final result = await authService.getUserProfile();
```

## 🔑 Key Features Implemented

### 1. Email Validation
- Format validation using regex
- Empty field checks

### 2. OTP System
- 6-digit OTP code
- Auto-focus next field on entry
- Resend OTP with 60-second cooldown timer
- Visual feedback for resend availability

### 3. Password Management
- Minimum 6 characters
- Password confirmation
- Show/hide password toggle on login

### 4. Loading States
- Loading indicators on all async operations
- Disabled buttons during API calls

### 5. Error Handling
- User-friendly error messages
- Dialog alerts for errors and success

## 📊 Database Integration

### Supabase Configuration
The app connects to Supabase using credentials in `main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

### Database Table: `pengguna`
```sql
CREATE TABLE pengguna (
    id_pengguna SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    foto_profil VARCHAR(255),
    total_trip INT DEFAULT 0,
    jarak_tempuh INT DEFAULT 0,
    jam_terbang INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## ⚠️ Important Notes

### 1. OTP Configuration in Supabase
Make sure to configure Supabase Auth settings:
- Go to Authentication → Settings in Supabase Dashboard
- Enable Email provider
- Configure email templates for OTP (optional)
- OTP expiry time: Default is 60 seconds

### 2. Security Considerations
The current implementation stores passwords in plain text in the `pengguna` table. For production:
- **DO NOT store plain passwords**
- Remove the password field from the `pengguna` table
- Supabase Auth already handles password hashing securely
- Only store additional user metadata in your custom table

### 3. Recommended Database Schema Update
```sql
-- Remove password field for security
ALTER TABLE pengguna DROP COLUMN password;

-- Link to Supabase Auth user using UUID
ALTER TABLE pengguna ADD COLUMN auth_user_id UUID REFERENCES auth.users(id);
```

### 4. Improved Registration Flow (Recommended)
```dart
// In completeRegistration method
final user = currentUser;

// Insert user data with auth_user_id instead of password
await _supabase.from('pengguna').insert({
  'auth_user_id': user.id,  // Link to Supabase Auth
  'email': user.email,
  'username': username,
  'foto_profil': fotoProfil,
});
```

## 🧪 Testing the Authentication

### Test Registration Flow
1. Run the app: `flutter run`
2. Tap "Siap Berpetualang!" on onboarding
3. Enter a valid email address
4. Check your email for the OTP code
5. Enter the 6-digit OTP
6. Set username and password
7. Confirm registration

### Test Login Flow
1. On login screen, enter registered email
2. Enter password
3. Tap "Masuk"
4. Should redirect to HomeScreen

### Test OTP Resend
1. On verification screen, wait for 60 seconds
2. Tap "Kirim ulang" link
3. Check email for new OTP

## 🐛 Troubleshooting

### OTP Not Received
- Check spam/junk folder
- Verify email in Supabase dashboard (Authentication → Users)
- Check Supabase logs for email delivery issues

### "Invalid OTP" Error
- Ensure OTP is entered correctly (6 digits)
- Check if OTP has expired (60 seconds)
- Request new OTP using resend feature

### Login Fails
- Verify email and password are correct
- Check if user completed registration
- Verify Supabase Auth settings

## 🚀 Next Steps

### Recommended Enhancements
1. **Password Reset** - Add forgot password functionality
2. **Social Auth** - Implement Google/Facebook login
3. **Email Verification Status** - Track verified users
4. **Profile Management** - Allow users to update profile
5. **Session Management** - Handle token refresh
6. **Remember Me** - Persist login state
7. **Security** - Remove password from pengguna table

### Additional Features
- Phone number OTP as alternative
- Two-factor authentication
- Account deletion
- Email change with verification

## 📝 Code Examples

### Check if User is Logged In
```dart
import 'package:tekber_tripid/services/auth_service.dart';

final authService = AuthService();

if (authService.isLoggedIn) {
  // User is logged in
  print('Current user: ${authService.currentUser?.email}');
} else {
  // User is not logged in
  Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
}
```

### Get User Profile
```dart
final result = await authService.getUserProfile();

if (result['success']) {
  final profile = result['profile'];
  print('Username: ${profile['username']}');
  print('Total Trips: ${profile['total_trip']}');
}
```

### Sign Out
```dart
await authService.signOut();
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginScreen()),
  (route) => false,
);
```

## 📞 Support
For issues or questions about the authentication implementation, please refer to:
- Supabase Documentation: https://supabase.com/docs/guides/auth
- Flutter Documentation: https://flutter.dev/docs

---

**Implementation Date:** December 10, 2025  
**Version:** 1.0  
**Status:** ✅ Complete with OTP Verification
