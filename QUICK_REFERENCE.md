# Quick Reference Guide - TripID App Structure

## 📍 Finding Screens

### Splash & Onboarding
- **SplashScreen** → `lib/screens/splash/splash_screen.dart`
- **OnboardingScreen** → `lib/screens/splash/onboarding_screen.dart`

### Authentication Screens
- **RegisterEmailScreen** → `lib/screens/auth/register_email_screen.dart`
- **VerificationScreen** → `lib/screens/auth/verification_screen.dart`
- **RegisterDetailsScreen** → `lib/screens/auth/register_details_screen.dart`
- **LoginScreen** → `lib/screens/auth/login_screen.dart`

### Home & Main App
- **HomeScreen** → `lib/screens/home/home_screen.dart` (container with nav)
- **ExploreTab** → `lib/screens/home/explore_tab.dart` (discovery)
- **ProfileTab** → `lib/screens/home/profile_tab.dart` (user profile)
- **SearchScreen** → `lib/screens/home/search_screen.dart` (search results)
- **DetailScreen** → `lib/screens/home/detail_screen.dart` (destination details)

---

## 🔍 Shared Resources

### Constants
- **kPrimaryBlue** = `#2D79C7`
- **kCyanLight** = `#A5F3FC`
- **kCyanDark** = `#0E7490`
- **Location**: `lib/shared/constants.dart`

### Models & Data
- **Destination** model
- **popularDestinations** (mock data)
- **hiddenGems** (mock data)
- **Location**: `lib/shared/models.dart`

### Helper Functions
- **buildTextField()** - Standardized text input
- **BottomWaveClipper** - Wave animation
- **BottomWaveClipperReverse** - Reverse wave
- **Location**: `lib/shared/widgets.dart`

---

## 📦 Import Shortcuts

### Import All Screens
```dart
import 'screens/screens.dart';

// All screens now available:
SplashScreen()
OnboardingScreen()
RegisterEmailScreen()
VerificationScreen()
RegisterDetailsScreen()
LoginScreen()
HomeScreen()
ExploreTab()
ProfileTab()
SearchScreen()
DetailScreen()
```

### Import All Shared Resources
```dart
import 'shared/shared.dart';

// Available:
kPrimaryBlue
kCyanLight
kCyanDark
Destination
popularDestinations
hiddenGems
buildTextField()
BottomWaveClipper()
```

### Import Specific Category
```dart
import 'screens/auth/auth_screens.dart';
import 'screens/home/home_screens.dart';
import 'screens/splash/splash_screens.dart';
```

---

## 🔄 Navigation Examples

```dart
// Navigate to Login
Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));

// Navigate to Explore Tab
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));

// Navigate to Details with parameter
Navigator.push(context, MaterialPageRoute(
  builder: (_) => DetailScreen(destination: selectedDestination)
));

// Go back
Navigator.pop(context);

// Replace all previous screens (for auth flow)
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => HomeScreen()),
  (route) => false
);
```

---

## 🎨 Common UI Patterns

### Build Text Input Field
```dart
buildTextField(
  label: 'Email',
  hint: 'contoh@email.com',
  isPassword: false
)
```

### Build Category Chip
```dart
_buildCategoryChip("Semua", isActive: true)
```

### Build Destination Card
```dart
_buildDestinationCard(
  context,
  destination,
  isHorizontal: true // or false for vertical
)
```

---

## 📱 Screen Navigation Flow

```
Main Entry
↓
SplashScreen (5 seconds)
↓
OnboardingScreen
↓
↙ [Existing user?] ↘
↙ [New user] ↘
RegisterEmailScreen → VerificationScreen → RegisterDetailsScreen → LoginScreen
                                          ↗
                                    [Existing User]
                        
LoginScreen → HomeScreen
              ├─ ExploreTab
              │  ├─ SearchScreen (pop-up)
              │  └─ DetailScreen (pop-up)
              ├─ MyAdventures (placeholder)
              └─ ProfileTab
```

---

## ⚙️ Configuration & Colors

### Color Scheme (`shared/constants.dart`)
```dart
const Color kPrimaryBlue = Color(0xFF2D79C7);  // Main button color
const Color kCyanLight = Color(0xFFA5F3FC);   // Background accents
const Color kCyanDark = Color(0xFF0E7490);    // Text on cyan background
```

### Default Background
- Light Gray: `Color(0xFFF9F9F9)` (used in HomeScreen)
- White: `Colors.white` (default for most screens)

---

## 🧪 Testing Navigation

To test navigation flow:

1. **Test Splash → Onboarding**: Run app, wait 5 seconds
2. **Test Registration Flow**: Click "Siap Berpetualang!" button
3. **Test Login → Home**: Navigate through entire auth flow
4. **Test Bottom Nav**: Click tabs in HomeScreen
5. **Test Search**: Tap search bar in ExploreTab
6. **Test Details**: Tap any destination card

---

## 📊 File Organization Summary

| Category | Files | Purpose |
|----------|-------|---------|
| **Splash** | 2 | Initial app experience |
| **Auth** | 4 | User registration & login |
| **Home** | 5 | Main app interface |
| **Shared** | 3 | Common utilities & data |
| **Barrel** | 5 | Convenient imports |
| **Docs** | 3 | Documentation |
| **TOTAL** | 22 | Complete app structure |

---

## ❓ FAQ

**Q: How do I add a new screen?**  
A: Create a new file in appropriate folder (screens/auth/, screens/home/, etc.), then add export to barrel file.

**Q: How do I use a different theme color?**  
A: Update `lib/shared/constants.dart` color constants.

**Q: Can I import specific screens?**  
A: Yes! Import directly: `import 'screens/auth/login_screen.dart';`

**Q: Where is mock data?**  
A: In `lib/shared/models.dart` - `popularDestinations` and `hiddenGems` lists.

**Q: How do I navigate between screens?**  
A: Use `Navigator.push()` or `Navigator.pushReplacement()` with MaterialPageRoute.

---

## 🚀 Tips for Development

1. **Keep screens focused**: Each file should represent one complete screen
2. **Use barrel files**: Cleaner imports for multiple related screens
3. **Centralize constants**: All colors in `constants.dart`
4. **Reuse widgets**: Extract common patterns to `shared/widgets.dart`
5. **Follow naming**: Use `_screenName_`, `_buildWidget()` conventions
6. **Comment code**: Document complex logic and business rules

---

## 📚 Documentation Files

- **PROJECT_STRUCTURE.md** - Detailed folder organization
- **SCREEN_ORGANIZATION.md** - Visual screen hierarchy
- **REFACTORING_SUMMARY.md** - What was changed and why
- **QUICK_REFERENCE.md** (this file) - Quick lookup guide
