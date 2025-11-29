import 'package:flutter/material.dart';
import '../../shared/constants.dart';
import '../auth/register_email_screen.dart';

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
                  fontSize: kFontSizeXL,
                  fontWeight: kFontWeightBold,
                  color: kBlueDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              // DESKRIPSI
              const Text(
                'Dengan TripID! kamu bisa mengatur rencana petualanganmu di satu aplikasi. Mudah dan tidak ribet',
                style: TextStyle(
                  fontSize: kFontSizeN,
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
                      MaterialPageRoute(builder: (_) => const RegisterEmailScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Siap Berpetualang!',
                    style: TextStyle(
                      fontSize: kFontSizeN,
                      fontWeight: kFontWeightSemiBold,
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
