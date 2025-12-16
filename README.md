# TripID - Aplikasi Akomodasi dan Wisata

Aplikasi mobile TripID adalah platform berbasis Flutter untuk merencanakan perjalanan wisata di Indonesia. Aplikasi ini memudahkan pengguna untuk membuat itinerary perjalanan, menjelajahi destinasi wisata, serta mencari informasi akomodasi dan transportasi. Dibangun dengan Flutter untuk pengalaman cross-platform dan menggunakan Supabase sebagai backend.

## 📋 Deskripsi Proyek

TripID adalah aplikasi wisata lengkap yang menyediakan berbagai fitur untuk membantu wisatawan merencanakan perjalanan mereka:

- **Perencanaan Trip**: Buat dan kelola rencana perjalanan dengan detail lengkap (tanggal, budget, jumlah orang)
- **Pencarian Destinasi Wisata**: Jelajahi berbagai destinasi menarik dengan informasi lengkap
- **Informasi Akomodasi**: Lihat pilihan hotel dan penginapan untuk perjalanan Anda
- **Autentikasi Pengguna**: Sistem login dan registrasi yang aman menggunakan Supabase
- **Manajemen Profil**: Kelola informasi pribadi dan preferensi pengguna
- **Peta Interaktif**: Integrasi dengan Flutter Map untuk menampilkan lokasi destinasi
- **Review & Rating**: Baca ulasan dan penilaian destinasi wisata

### Fitur Utama

- ✨ **Splash Screen**: Halaman pembuka aplikasi yang menarik
- 🔐 **Authentication**: Login dan registrasi dengan validasi email
- 🏠 **Home Dashboard**: Tampilan utama dengan eksplorasi destinasi
- 📅 **Buat Trip**: Rencanakan perjalanan dengan detail tanggal, budget, dan jumlah peserta
- �️ **My Trips**: Kelola semua rencana perjalanan Anda
- 🏨 **Pilih Akomodasi**: Lihat dan pilih hotel/villa untuk perjalanan
- 📍 **Detail Destinasi**: Informasi lengkap, foto gallery, dan review destinasi wisata
- � **Profil & Edit**: Kelola informasi profil pengguna
- 🔍 **Search**: Cari destinasi wisata dengan mudah
- 🌍 **Maps Integration**: Lihat lokasi destinasi di peta dan buka di Google Maps

## 🛠️ Teknologi yang Digunakan

- **Flutter** (SDK ^3.9.2) - Framework utama untuk pengembangan aplikasi
- **Supabase Flutter** (^2.10.3) - Backend as a Service untuk autentikasi dan database
- **Flutter Map** (^6.1.0) - Integrasi peta interaktif
- **Image Picker** (^1.0.7) - Pengambilan foto dari galeri atau kamera
- **Intl** (^0.20.2) - Internasionalisasi dan format tanggal/waktu
- **URL Launcher** (^6.2.5) - Membuka URL eksternal

## 📁 Struktur Folder

```
TripID-Akomodasi-App/
│
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── auth_screens.dart                  # Halaman autentikasi (deprecated)
│   ├── home_screen.dart                   # Halaman home (deprecated)
│   ├── transportasi_screen.dart           # Halaman transportasi (deprecated)
│   │
│   ├── screens/                           # Semua halaman aplikasi
│   │   ├── screens.dart                   # Export barrel file
│   │   ├── splash/                        # Splash screen
│   │   ├── auth/                          # Autentikasi (login, register)
│   │   └── home/                          # Home dan fitur utama
│   │       ├── home_screens.dart          # Dashboard utama
│   │       ├── akomodasi_screen.dart      # Pencarian akomodasi
│   │       ├── destination_info_screen.dart # Detail destinasi
│   │       ├── profile_screen.dart        # Profil pengguna
│   │       └── ...                        # Screen lainnya
│   │
│   ├── shared/                            # Komponen bersama
│   │   ├── shared.dart                    # Export barrel file
│   │   ├── constants.dart                 # Konstanta aplikasi (colors, styles)
│   │   ├── models.dart                    # Model data (Hotel, User, dll)
│   │   ├── destination_info_models.dart   # Model data destinasi
│   │   └── widgets.dart                   # Custom widgets (buttons, cards, dll)
│   │
│   └── services/                          # Services layer
│       ├── auth_service.dart              # Autentikasi Supabase
│       └── ...                            # Service lainnya
│
├── assets/                                # Asset statis
│   └── images/
│       ├── onboard.png                    # Gambar onboarding
│       └── map_location.jpg               # Gambar peta
│
├── android/                               # Konfigurasi Android
├── ios/                                   # Konfigurasi iOS
├── web/                                   # Konfigurasi Web
├── linux/                                 # Konfigurasi Linux
├── macos/                                 # Konfigurasi macOS
├── windows/                               # Konfigurasi Windows
│
├── pubspec.yaml                           # Dependencies dan konfigurasi
├── analysis_options.yaml                  # Konfigurasi linter
│
└── docs/                                  # Dokumentasi tambahan
    ├── AUTH_FLOW_DIAGRAM.md               # Diagram alur autentikasi
    ├── AUTH_IMPLEMENTATION_GUIDE.md      # Panduan implementasi auth
    ├── PROJECT_STRUCTURE.md               # Struktur proyek detail
    └── ...                                # Dokumentasi lainnya
```

### Penjelasan Struktur

- **`lib/screens/`**: Berisi semua halaman UI aplikasi yang diorganisir berdasarkan fitur
- **`lib/shared/`**: Komponen yang digunakan bersama di seluruh aplikasi (widgets, models, constants)
- **`lib/services/`**: Layer business logic dan integrasi dengan backend
- **`assets/`**: File media seperti gambar, icon, dan font
- **Platform folders** (android, ios, web, dll): Konfigurasi spesifik untuk setiap platform

## 🚀 Cara Instalasi

### Prasyarat

Pastikan Anda sudah menginstal:

1. **Flutter SDK** (versi 3.9.2 atau lebih baru)
   - Download dari [flutter.dev](https://flutter.dev)
   - Verifikasi instalasi: `flutter --version`

2. **Git** untuk clone repository
   - Download dari [git-scm.com](https://git-scm.com/)

3. **IDE/Editor** (pilih salah satu):
   - Android Studio dengan Flutter plugin
   - Visual Studio Code dengan Flutter extension
   - IntelliJ IDEA dengan Flutter plugin

4. **Platform Development Setup**:
   - **Android**: Android Studio + Android SDK
   - **iOS**: Xcode (hanya di macOS)
   - **Web**: Chrome browser

### Langkah-langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/sukamettawahalib/TripID-Akomodasi-App.git
   cd TripID-Akomodasi-App
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Supabase** (Penting!)
   
   Buat file `lib/services/supabase_config.dart` dengan konten berikut:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```
   
   Ganti `YOUR_SUPABASE_URL` dan `YOUR_SUPABASE_ANON_KEY` dengan credentials dari dashboard Supabase Anda.
   
   > **Note**: Pastikan file ini tidak di-commit ke repository (sudah ada di `.gitignore`)

4. **Verifikasi Setup**
   ```bash
   flutter doctor
   ```
   
   Pastikan semua checklist sudah ✓ (hijau) atau setidaknya tidak ada error kritis.

## ▶️ Cara Menjalankan

### Running di Development Mode

1. **Melalui Command Line**
   
   **Android Emulator/Device:**
   ```bash
   flutter run
   ```
   
   **iOS Simulator (macOS only):**
   ```bash
   flutter run -d ios
   ```
   
   **Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```
   
   **Edge (Web):**
   ```bash
   flutter run -d edge
   ```

2. **Melalui IDE**
   
   - Buka project di Android Studio/VS Code
   - Pilih device target (emulator, simulator, atau device fisik)
   - Tekan tombol **Run** (▶️) atau **F5**

### Build untuk Production

**Android APK:**
```bash
flutter build apk --release
```
File APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

**Android App Bundle (untuk Google Play Store):**
```bash
flutter build appbundle --release
```

**iOS (macOS only):**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```
File web akan tersedia di: `build/web/`

### Tips Running

- **Hot Reload**: Tekan `r` di terminal saat aplikasi berjalan untuk reload cepat
- **Hot Restart**: Tekan `R` untuk restart penuh aplikasi
- **Quit**: Tekan `q` untuk keluar dari aplikasi

## 📱 Platform yang Didukung

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (Chrome, Edge, Safari, Firefox)
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 🔧 Konfigurasi Tambahan

### Android Permissions

Permissions yang diperlukan sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`:
- Internet access
- Camera access (untuk image picker)
- Storage access (untuk menyimpan foto)

### iOS Permissions

Tambahkan di `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses ke galeri foto untuk upload gambar</string>
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk mengambil foto</string>
```

---

**Terakhir Diperbarui**: 16 Desember 2025

**Versi**: 0.1.0