# 🎨 Authentication Flow Diagram

## Visual Flow Chart

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP STARTS                               │
│                         (main.dart)                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │              │
                  │ SplashScreen │ (5 seconds)
                  │              │
                  └──────┬───────┘
                         │
                         ▼
              ┌──────────────────────┐
              │                      │
              │  OnboardingScreen    │ "Siap Berpetualang!"
              │                      │
              └──────┬───────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │                       │
         │ RegisterEmailScreen   │ ←──── "Belum punya akun?" ─┐
         │                       │                              │
         └───────┬───────────────┘                              │
                 │ Enter Email                                  │
                 │ Tap "Lanjut"                                │
                 ▼                                              │
    ┌────────────────────────┐                                 │
    │  SUPABASE AUTH         │                                 │
    │  Sends OTP to Email    │                                 │
    └────────┬───────────────┘                                 │
             │                                                  │
             ▼                                                  │
  ┌──────────────────────┐                                     │
  │                      │                                     │
  │ VerificationScreen   │                                     │
  │  (6-digit OTP)       │ ◄─── "Kirim ulang" (60s timer)    │
  │                      │                                     │
  └──────┬───────────────┘                                     │
         │ Enter OTP                                           │
         │ Tap "Lanjut"                                       │
         ▼                                                     │
┌────────────────────────┐                                     │
│  SUPABASE AUTH         │                                     │
│  Verifies OTP          │                                     │
│  Creates Auth User     │                                     │
└────────┬───────────────┘                                     │
         │                                                     │
         ▼                                                     │
┌─────────────────────────┐                                    │
│                         │                                    │
│ RegisterDetailsScreen   │                                    │
│  - Username             │                                    │
│  - Password             │                                    │
│  - Confirm Password     │                                    │
│                         │                                    │
└─────────┬───────────────┘                                    │
          │ Tap "Daftar"                                       │
          ▼                                                    │
┌────────────────────────┐                                     │
│  DATABASE (pengguna)   │                                     │
│  Creates user profile  │                                     │
│  - email               │                                     │
│  - username            │                                     │
│  - password            │                                     │
│  - foto_profil         │                                     │
│  - total_trip          │                                     │
└────────┬───────────────┘                                     │
         │                                                     │
         │ Success Dialog                                      │
         │ "Registrasi berhasil!"                             │
         ▼                                                     │
  ┌──────────────┐                                            │
  │              │ ───────────────────────────────────────────┘
  │ LoginScreen  │
  │              │ ◄─── "Punya akun? Masuk di sini"
  └──────┬───────┘
         │ Enter Email & Password
         │ Tap "Masuk"
         ▼
┌────────────────────────┐
│  SUPABASE AUTH         │
│  Authenticates User    │
│  Returns Session       │
└────────┬───────────────┘
         │
         ▼
  ┌──────────────┐
  │              │
  │  HomeScreen  │ ✅ USER AUTHENTICATED
  │              │
  └──────────────┘
```

---

## 📋 Component Breakdown

### 1️⃣ RegisterEmailScreen
**Purpose:** Collect user's email address  
**Actions:**
- Validate email format
- Send OTP via Supabase Auth
- Navigate to VerificationScreen

**Key Code:**
```dart
await authService.sendOtpToEmail(email);
```

---

### 2️⃣ VerificationScreen  
**Purpose:** Verify OTP sent to email  
**Actions:**
- Accept 6-digit OTP input
- Auto-focus next field
- Resend OTP (with 60s cooldown)
- Verify OTP with Supabase

**Key Code:**
```dart
await authService.verifyOtp(
  email: widget.email,
  otpCode: otpCode,
);
```

**UI Features:**
- 6 individual digit boxes
- Auto-advance on input
- Countdown timer for resend
- Loading indicator

---

### 3️⃣ RegisterDetailsScreen
**Purpose:** Complete user profile  
**Actions:**
- Collect username
- Set password (min 6 chars)
- Confirm password match
- Create user profile in database

**Key Code:**
```dart
await authService.completeRegistration(
  username: username,
  password: password,
);
```

**Validations:**
- Username ≥ 3 characters
- Password ≥ 6 characters
- Password confirmation match

---

### 4️⃣ LoginScreen
**Purpose:** Authenticate existing user  
**Actions:**
- Email & password login
- Navigate to HomeScreen on success

**Key Code:**
```dart
await authService.signInWithEmail(
  email: email,
  password: password,
);
```

**UI Features:**
- Email input
- Password input (with show/hide toggle)
- Link to registration
- Social login placeholders

---

## 🔐 Security Flow

```
Email Input → OTP Sent → OTP Verified → User Created → Profile Saved → Login Ready
     ↓            ↓            ↓             ↓              ↓             ↓
  Validated   Supabase    Supabase      Auth User     Database       Session
              Email       verifyOTP     Created       Record         Started
```

---

## 📱 User Experience Timeline

| Step | Screen | User Action | Time | Backend Action |
|------|--------|-------------|------|----------------|
| 1 | Splash | Watches animation | 5s | Initialize Supabase |
| 2 | Onboarding | Taps button | - | - |
| 3 | Register Email | Enters email | - | Validate format |
| 4 | - | Taps "Lanjut" | 1-2s | Send OTP email |
| 5 | Verification | Checks email | - | - |
| 6 | - | Enters OTP | - | - |
| 7 | - | Taps "Lanjut" | 1s | Verify OTP |
| 8 | Register Details | Fills form | - | - |
| 9 | - | Taps "Daftar" | 1-2s | Create user + profile |
| 10 | Login | Enters credentials | - | - |
| 11 | - | Taps "Masuk" | 1s | Authenticate |
| 12 | Home | Sees dashboard | - | Load user data |

**Total Time:** ~2-3 minutes (depending on user speed)

---

## 🗄️ Database Flow

### During Registration:

1. **Supabase Auth Table** (`auth.users`)
   - Created automatically when OTP verified
   - Stores: email, encrypted password, metadata
   - Managed by Supabase

2. **Custom Table** (`pengguna`)
   - Created when user completes profile
   - Stores: username, email, profile data, trip stats
   - Linked to auth.users (by email)

### During Login:

1. Check `auth.users` for credentials
2. Return session token
3. Can query `pengguna` for profile data

---

## 🔄 State Management

### Auth States:
```
UNAUTHENTICATED → REGISTERING → OTP_SENT → OTP_VERIFIED → 
PROFILE_CREATING → AUTHENTICATED
```

### Screen States:
- **Loading**: Showing spinner during API calls
- **Error**: Showing dialog with error message
- **Success**: Navigating to next screen

---

## 📊 Data Flow Diagram

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │ Enters Email
       ▼
┌─────────────────┐      ┌──────────────────┐
│ Flutter App     │─────▶│ Supabase Auth    │
│ (UI Layer)      │      │ (Auth Service)    │
└─────────────────┘      └────────┬─────────┘
       │                          │
       │ Displays OTP Input       │ Sends Email
       │                          ▼
       │                  ┌──────────────────┐
       │                  │ User's Email     │
       │                  │ Inbox            │
       │                  └────────┬─────────┘
       │ User enters OTP          │
       │◄─────────────────────────┘
       ▼
┌─────────────────┐      ┌──────────────────┐
│ Verification    │─────▶│ Supabase Auth    │
│ Screen          │      │ Verify OTP       │
└─────────────────┘      └────────┬─────────┘
       │                          │ ✅ Valid
       │                          ▼
       │                  ┌──────────────────┐
       │                  │ Auth User        │
       │                  │ Created          │
       │                  └────────┬─────────┘
       │ Enter Details            │
       ▼                          │
┌─────────────────┐               │
│ Profile Details │               │
│ Screen          │               │
└─────────┬───────┘               │
          │ Submit                │
          ▼                       ▼
┌─────────────────┐      ┌──────────────────┐
│ AuthService     │─────▶│ PostgreSQL       │
│ Complete Reg    │      │ pengguna table   │
└─────────────────┘      └──────────────────┘
          │                       
          │ ✅ Success
          ▼
┌─────────────────┐
│ Login Screen    │
└─────────────────┘
```

---

## 🎯 Success Criteria

✅ OTP received in email within seconds  
✅ OTP verification works correctly  
✅ User profile created in database  
✅ Login with credentials successful  
✅ Session maintained after login  
✅ Error messages shown appropriately  
✅ Loading states prevent double submission  
✅ Navigation flows smoothly  

---

**Last Updated:** December 10, 2025
