# TripID App - Page/Screen Structure

## Screen Hierarchy & Organization

### 1. **Splash & Onboarding Flow**
```
SplashScreen
├── 5-second delay
└── OnboardingScreen
```
**File**: `lib/screens/splash/splash_screen.dart` & `onboarding_screen.dart`

---

### 2. **Authentication Flow**
```
RegisterEmailScreen
├── Email input
├── Link to LoginScreen
└── → VerificationScreen
    ├── OTP input (4 digits)
    └── → RegisterDetailsScreen
        ├── Username
        ├── Password
        ├── Confirm Password
        └── → LoginScreen
            ├── Email & Password login
            ├── Link to RegisterEmailScreen
            ├── Social login options
            └── → HomeScreen (on success)
```
**Files**: `lib/screens/auth/`
- `register_email_screen.dart`
- `verification_screen.dart`
- `register_details_screen.dart`
- `login_screen.dart`

---

### 3. **Home Screen (Main App)**
```
HomeScreen (Container)
├── Bottom Navigation (3 tabs)
│   ├── 🔍 Jelajahi (Explore)
│   ├── 🗺️ Petualanganku (My Adventures)
│   └── 👤 Profil (Profile)
│
├── ExploreTab
│   ├── User profile header
│   ├── Search bar
│   ├── Category filters
│   ├── Popular destinations (carousel)
│   └── Hidden gems (list)
│       └── → DetailScreen (tap destination)
│
├── ProfileTab
│   ├── Cover image & profile picture
│   ├── User name & edit button
│   ├── Statistics cards
│   ├── Friends list
│   ├── Ongoing trips
│   └── Trip history
│
└── Placeholder
    └── "Halaman Petualanganku"
```
**Files**: `lib/screens/home/`
- `home_screen.dart` (main container)
- `explore_tab.dart`
- `profile_tab.dart`
- `search_screen.dart` (pop-up from search bar)
- `detail_screen.dart` (pop-up from destination card)

---

### 4. **Detailed Page Descriptions**

#### SplashScreen
- **Purpose**: Initial app loading screen
- **Duration**: 5 seconds
- **Features**:
  - "TRIPID!" title with italic style
  - "Exploring Indonesia Made Easy" subtitle
  - Wave animations at bottom
  - Auto-redirect to OnboardingScreen

#### OnboardingScreen
- **Purpose**: App introduction
- **Features**:
  - Language selector (Bahasa Indonesia)
  - Illustration image
  - "Jelajahi Nusantara Anti Ribet" headline
  - Description text
  - "Siap Berpetualang!" CTA button

#### RegisterEmailScreen
- **Purpose**: First registration step
- **Features**:
  - Email input field
  - "Punya akun? Masuk di sini" link to login
  - "Lanjut" button → VerificationScreen

#### VerificationScreen
- **Purpose**: Verify email with OTP
- **Features**:
  - 4 OTP input boxes
  - "Tidak menerima kode? Kirim ulang" link
  - "Lanjut" button → RegisterDetailsScreen

#### RegisterDetailsScreen
- **Purpose**: Collect additional user info
- **Features**:
  - Username input
  - Password input
  - Confirm password input
  - "Masuk" button → LoginScreen

#### LoginScreen
- **Purpose**: User login
- **Features**:
  - Email input
  - Password input
  - "Masuk" button (filled)
  - "Belum punya akun" button (outlined)
  - Social login (Google, Facebook)
  - Success → HomeScreen

#### HomeScreen
- **Purpose**: Main app container
- **Features**:
  - 3-tab navigation (bottom floating bar)
  - Manages navigation between tabs
  - Tab state management

#### ExploreTab
- **Purpose**: Destination discovery
- **Features**:
  - User profile header (name, ID)
  - Search bar with filter icon
  - Category chips (Semua, Terdekat, Populer, Museum, Gunung)
  - Popular destinations (horizontal carousel)
  - Hidden gems (vertical list)
  - Cards are tappable → DetailScreen

#### ProfileTab
- **Purpose**: User profile display
- **Features**:
  - Cover image (airplane wing sunset)
  - Profile picture overlay
  - User name with edit button
  - Stats cards (Total trip, Jarak ditempuh, Jam terbang)
  - Friends section with avatars
  - Ongoing trips section
  - Trip history section

#### SearchScreen
- **Purpose**: Advanced destination search
- **Features**:
  - Auto-focus search input with back button
  - Filter icon
  - Filter chips (Semua, Terdekat, Populer, Relevan)
  - Main search results
  - Related destinations carousel
  - Destination cards display title, location, image

#### DetailScreen
- **Purpose**: Show destination details
- **Features**:
  - Full-screen background image
  - Back button
  - Bottom card with:
    - Destination name
    - Location with icon
    - Rating badge
    - Description
    - "Pesan Sekarang" button

---

## Page Separation Complete ✅

All pages have been separated into individual Dart files:

| Screen | File | Location |
|--------|------|----------|
| Splash | splash_screen.dart | screens/splash/ |
| Onboarding | onboarding_screen.dart | screens/splash/ |
| Register Email | register_email_screen.dart | screens/auth/ |
| Verification | verification_screen.dart | screens/auth/ |
| Register Details | register_details_screen.dart | screens/auth/ |
| Login | login_screen.dart | screens/auth/ |
| Home Container | home_screen.dart | screens/home/ |
| Explore Tab | explore_tab.dart | screens/home/ |
| Profile Tab | profile_tab.dart | screens/home/ |
| Search | search_screen.dart | screens/home/ |
| Detail | detail_screen.dart | screens/home/ |
| **Destination Info** | **destination_info_screen.dart** | **screens/destination/** |

---

## Shared Resources

| Resource | File | Type |
|----------|------|------|
| Colors & Constants | constants.dart | Constants |
| Destination Model | models.dart | Data Model |
| Review, Activity Models | destination_info_models.dart | Data Models |
| Helper Widgets | widgets.dart | Utilities |

---

## Easy Navigation with Barrel Files

### Main Barrel: `screens/screens.dart`
```dart
export 'splash/splash_screens.dart';
export 'auth/auth_screens.dart';
export 'home/home_screens.dart';
```

### Usage Example:
```dart
import 'screens/screens.dart';  // Import all screens at once

// Use directly
Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
```
