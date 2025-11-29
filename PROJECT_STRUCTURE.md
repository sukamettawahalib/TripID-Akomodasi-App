# TripID-Akomodasi-App Project Structure

## Overview
The project has been reorganized to separate each page/screen into individual Dart files for better maintainability and scalability.

## Folder Structure

```
lib/
├── main.dart                          # Main application entry point
├── screens/                           # All screen/page files
│   ├── splash/                        # Splash & Onboarding screens
│   │   ├── splash_screen.dart        # Splash screen with animation
│   │   ├── onboarding_screen.dart    # Onboarding screen
│   │   └── splash_screens.dart       # Barrel file for splash screens
│   ├── auth/                          # Authentication screens
│   │   ├── register_email_screen.dart    # Email registration
│   │   ├── verification_screen.dart     # OTP verification
│   │   ├── register_details_screen.dart # Profile details registration
│   │   ├── login_screen.dart            # Login screen
│   │   └── auth_screens.dart            # Barrel file for auth screens
│   ├── home/                          # Home/Main app screens
│   │   ├── home_screen.dart          # Main home with bottom nav
│   │   ├── explore_tab.dart          # Explore/Discovery tab
│   │   ├── profile_tab.dart          # User profile tab
│   │   ├── search_screen.dart        # Destination search
│   │   ├── detail_screen.dart        # Destination details
│   │   └── home_screens.dart         # Barrel file for home screens
│   └── screens.dart                  # Main barrel file for all screens
└── shared/                            # Shared utilities and resources
    ├── constants.dart                # Color constants and configuration
    ├── models.dart                   # Data models (Destination, etc.)
    ├── widgets.dart                  # Shared widgets and helpers
    └── shared.dart                   # Barrel file for shared utilities
```

## File Descriptions

### Splash & Onboarding (`screens/splash/`)
- **splash_screen.dart**: Initial loading screen with wave animations
- **onboarding_screen.dart**: Onboarding introduction screen

### Authentication (`screens/auth/`)
- **register_email_screen.dart**: First registration step - email input
- **verification_screen.dart**: OTP email verification (4 digits)
- **register_details_screen.dart**: Additional user info (username & password)
- **login_screen.dart**: User login with email and password

### Home/Main App (`screens/home/`)
- **home_screen.dart**: Main container with bottom navigation (3 tabs)
  - Jelajahi (Explore)
  - Petualanganku (My Adventures)
  - Profil (Profile)
- **explore_tab.dart**: Destination discovery and browsing
- **profile_tab.dart**: User profile information and trip history
- **search_screen.dart**: Advanced destination search
- **detail_screen.dart**: Detailed destination information

### Shared Resources (`shared/`)
- **constants.dart**: Color constants (kPrimaryBlue, kCyanLight, kCyanDark)
- **models.dart**: Data models like `Destination` with mock data
- **widgets.dart**: Helper functions and custom widgets (TextField, Wave Clippers)

## Usage Examples

### Importing Screens

```dart
// Option 1: Import specific screen
import 'screens/home/home_screen.dart';

// Option 2: Import from barrel file (recommended)
import 'screens/screens.dart';
```

### Importing Shared Resources

```dart
// Option 1: Import specific utilities
import 'shared/constants.dart';
import 'shared/models.dart';

// Option 2: Import from barrel file (recommended)
import 'shared/shared.dart';
```

## Screen Navigation Flow

```
SplashScreen (5 seconds)
    ↓
OnboardingScreen
    ↓
RegisterEmailScreen → [Existing user? → LoginScreen]
    ↓
VerificationScreen
    ↓
RegisterDetailsScreen
    ↓
LoginScreen → HomeScreen
    ↓
HomeScreen (Bottom Nav)
├── ExploreTab → [Tap Destination] → DetailScreen
├── MyAdventures (Placeholder)
└── ProfileTab
```

## Key Features by Screen

### Explore Tab
- User profile header with ID
- Search bar with filter options
- Category filtering (Semua, Terdekat, Populer, Museum, Gunung)
- Popular destinations carousel (horizontal scroll)
- Hidden gems list (vertical)
- Tappable destination cards → Detail Screen

### Search Screen
- Auto-focus search input
- Filter chips
- Main search results
- Related destinations carousel

### Detail Screen
- Full-screen background image
- Floating back button
- Bottom card with:
  - Destination name and rating
  - Location information
  - Description
  - "Pesan Sekarang" (Book Now) button

### Profile Tab
- Cover image with profile picture
- User info and edit button
- Statistics cards (trips, distance, flying hours)
- Friends list
- Ongoing trips
- Trip history

## Color Scheme

- **Primary Blue**: `#2D79C7` (kPrimaryBlue)
- **Cyan Light**: `#A5F3FC` (kCyanLight)
- **Cyan Dark**: `#0E7490` (kCyanDark)
- **Background**: `#F9F9F9`

## Data Models

### Destination
```dart
class Destination {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String description;
}
```

## Shared Widgets

- `buildTextField()` - Standardized text input field
- `BottomWaveClipper` - Wave animation effect
- `BottomWaveClipperReverse` - Reverse wave animation

## Future Enhancements

- Consider separating tabs in home_screen into separate files
- Add state management (Provider, Riverpod, GetX)
- Implement backend API calls
- Add local database for caching
- Extract strings to localization files (i18n)
- Create reusable component library for common UI patterns

## Notes

- All screen imports are organized with barrel files for cleaner imports
- Models and constants are centralized in the `shared/` folder
- The structure follows Flutter best practices for scalability
- Each page/screen is independent and can be modified without affecting others
