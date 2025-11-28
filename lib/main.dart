import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripID',
      theme: ThemeData(
        // Menggunakan warna biru utama yang mirip dengan desain
        primaryColor: const Color(0xFF2D79C7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D79C7)),
        useMaterial3: true,
        fontFamily: 'Roboto', // Bisa diganti dengan font custom jika ada
      ),
      home: const SplashScreen(),
    );
  }
}

// =======================
// 1. SPLASH SCREEN
// =======================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer selama 3 detik sebelum pindah ke Onboarding
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D79C7), // Warna Biru Background
      body: Stack(
        children: [
          // Konten Tengah (Text)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TRIPID!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic, // Gaya agak miring seperti kuas
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Exploring Indonesia\nMade Easy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Efek Gelombang (Wave) di Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                color: Colors.white.withOpacity(0.1), // Transparan sedikit
                height: 150,
              ),
            ),
          ),
           Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipperReverse(),
              child: Container(
                color: const Color(0xFF4FA3F1), // Warna gelombang lebih muda
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk membuat efek gelombang di Splash Screen
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomWaveClipperReverse extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 20);
    
    var firstControlPoint = Offset(size.width / 4, 80);
    var firstEndPoint = Offset(size.width / 2, 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    
    var secondControlPoint = Offset(size.width * 0.75, 0);
    var secondEndPoint = Offset(size.width, 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }
   @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


// =======================
// 2. ONBOARDING SCREEN
// =======================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bahasa Indonesia (ID)",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),
              // AREA GAMBAR ILUSTRASI
              // Catatan: Ganti Icon/Container ini dengan Image.asset('assets/gambar_kamu.png')
              Center(
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                       Image.asset('assets/images/onboard.png')
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
              
              // JUDUL UTAMA
              const Text(
                'Jelajahi Nusantara\nAnti Ribet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0), // Biru gelap
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              // DESKRIPSI
              const Text(
                'Dengan TripID! kamu bisa mengatur rencana petualanganmu di satu aplikasi. Mudah dan tidak ribet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // TOMBOL BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke Halaman Pendaftaran
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterEmailScreen()), // Pastikan import class ini
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D79C7), // Warna tombol biru
                    foregroundColor: Colors.white, // Warna teks putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Siap Berpetualang!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
