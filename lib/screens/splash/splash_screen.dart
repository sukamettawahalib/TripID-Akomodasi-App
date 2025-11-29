import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/constants.dart';
import 'onboarding_screen.dart';
import '../../shared/widgets.dart';

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
      backgroundColor: kPrimaryBlue, // Warna Biru Background
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
                    fontSize: kFontSizeXXL,
                    fontWeight: kFontWeightBold,
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
                    fontSize: kFontSizeN,
                    color: Colors.white70,
                    fontWeight: kFontWeightNormal,
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
                color: kBlueLight, // Warna gelombang lebih muda
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
