# 🚀 Supabase Auth Setup Checklist

Before testing the authentication system, make sure you've completed these steps in your Supabase dashboard:

## ✅ Step 1: Enable Email Authentication

1. Go to your Supabase project dashboard: https://supabase.com/dashboard
2. Navigate to **Authentication** → **Providers**
3. Find **Email** provider
4. Toggle it to **Enabled**
5. Configure settings:
   - ✅ Enable email confirmations (for OTP)
   - ✅ Secure email change
   - ✅ Set OTP expiry (default: 60 seconds is fine)

## ✅ Step 2: Configure Email Templates (Optional but Recommended)

1. Go to **Authentication** → **Email Templates**
2. Customize the **Magic Link** template (used for OTP):
   ```html
   <h2>Your TripID Verification Code</h2>
   <p>Enter this code in the app:</p>
   <h1>{{ .Token }}</h1>
   <p>This code expires in 60 seconds.</p>
   ```

## ✅ Step 3: Test Email Delivery

1. Go to **Authentication** → **Users**
2. Try creating a test user manually
3. Check if emails are being delivered
4. If emails not working:
   - Check **Settings** → **Auth** → **SMTP Settings**
   - For development, Supabase uses built-in email service
   - For production, configure custom SMTP

## ✅ Step 4: Row Level Security (RLS) - IMPORTANT!

### Current Status
The database schema provided has RLS commented out. This means:
- ⚠️ Anyone can read/write to `pengguna` table
- ⚠️ Not secure for production

### Enable RLS (Recommended)
1. Go to **Table Editor** → select `pengguna` table
2. Click on the table → **Settings** → Enable RLS
3. Add policies:

#### Policy 1: Users can insert their own profile
```sql
CREATE POLICY "Users can insert own profile" 
ON pengguna FOR INSERT 
WITH CHECK (auth.uid()::text = email);
```

#### Policy 2: Users can read their own profile
```sql
CREATE POLICY "Users can view own profile" 
ON pengguna FOR SELECT 
USING (auth.uid()::text = email);
```

#### Policy 3: Users can update their own profile
```sql
CREATE POLICY "Users can update own profile" 
ON pengguna FOR UPDATE 
USING (auth.uid()::text = email);
```

## ✅ Step 5: Update Database Schema (Security Fix)

The current implementation stores passwords in the `pengguna` table. This is **NOT RECOMMENDED** for production.

### Recommended Changes:

1. Remove password from pengguna table:
```sql
ALTER TABLE pengguna DROP COLUMN IF EXISTS password;
```

2. Add link to Supabase Auth:
```sql
ALTER TABLE pengguna ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id);
ALTER TABLE pengguna ADD CONSTRAINT unique_auth_user UNIQUE (auth_user_id);
```

3. Update the `completeRegistration` method in `auth_service.dart`:
```dart
// Replace the insert statement with:
await _supabase.from('pengguna').insert({
  'auth_user_id': user.id,  // Link to Supabase Auth
  'email': user.email,
  'username': username,
  'foto_profil': fotoProfil,
  'total_trip': 0,
  'jarak_tempuh': 0,
  'jam_terbang': 0,
});
```

## ✅ Step 6: Test the Authentication Flow

### Test 1: Registration
- [ ] Run app: `flutter run`
- [ ] Navigate to registration
- [ ] Enter valid email
- [ ] Check email inbox for OTP
- [ ] Enter OTP (6 digits)
- [ ] Complete profile (username + password)
- [ ] Verify redirect to login

### Test 2: OTP Resend
- [ ] Start registration
- [ ] Wait 60 seconds on OTP screen
- [ ] Click "Kirim ulang"
- [ ] Verify new OTP received

### Test 3: Login
- [ ] Open login screen
- [ ] Enter registered email
- [ ] Enter password
- [ ] Verify redirect to home screen

### Test 4: Invalid Scenarios
- [ ] Test invalid email format
- [ ] Test wrong OTP code
- [ ] Test expired OTP
- [ ] Test wrong password on login
- [ ] Test password mismatch on registration

## 📱 Development Testing Tips

### Use Test Email
For development, you can use:
- Temporary email services (tempmail.com, guerrillamail.com)
- Your own email with `+` notation: `yourname+test1@gmail.com`

### Check Supabase Logs
1. Go to **Logs** → **Auth Logs** in Supabase dashboard
2. Monitor authentication events
3. Check for errors

### Debug Mode
Add this to see auth state changes:
```dart
// In main.dart or auth_service.dart
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  print('Auth state changed: ${data.event}');
  print('User: ${data.session?.user.email}');
});
```

## 🔒 Security Checklist for Production

- [ ] Remove password field from pengguna table
- [ ] Enable Row Level Security (RLS)
- [ ] Configure custom SMTP for email delivery
- [ ] Set up email rate limiting
- [ ] Implement CAPTCHA for registration
- [ ] Add password strength requirements
- [ ] Enable MFA (Multi-Factor Authentication)
- [ ] Set up monitoring and alerts
- [ ] Configure secure password reset
- [ ] Review and test all RLS policies

## 🐛 Common Issues and Solutions

### Issue 1: OTP Not Received
**Solutions:**
- Check spam folder
- Verify email provider in Supabase settings
- Check Supabase Auth logs for errors
- Test with different email provider

### Issue 2: "Invalid OTP" Error
**Solutions:**
- OTP might have expired (60 seconds)
- Check if OTP is exactly 6 digits
- Use resend feature to get new OTP
- Verify Supabase OTP settings

### Issue 3: Registration Fails
**Solutions:**
- Check if user already exists (duplicate email)
- Verify RLS policies if enabled
- Check Supabase logs for specific error
- Ensure database connection is active

### Issue 4: Login Fails After Registration
**Solutions:**
- Wait a few seconds after registration
- Verify user appears in Supabase Auth dashboard
- Check if email was verified
- Try password reset if needed

## 📚 Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Email Auth with OTP](https://supabase.com/docs/guides/auth/auth-email-passwordless)

## 🆘 Need Help?

If you encounter issues:
1. Check Supabase dashboard logs
2. Review error messages in Flutter console
3. Verify all checklist items completed
4. Test with simple email first
5. Check GitHub issues for supabase_flutter package

---

**Last Updated:** December 10, 2025  
**Status:** Ready for Testing ✅
