import 'package:flutter/material.dart';
import 'verification_screen.dart';
import '../../shared/constants.dart';
import '../../shared/widgets.dart';

class RegisterEmailScreen extends StatelessWidget {
  const RegisterEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Buat akun',
                style: TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukkan email yang ingin digunakan untuk akun TripID',
                style: TextStyle(fontSize: kFontSizeN, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              buildTextField(label: 'Email', hint: 'contoh@email.com'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Login jika sudah punya akun
                  Navigator.pushNamed(context, '/login');
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Punya akun? ',
                    style: TextStyle(color: Colors.black54, fontSize: kFontSizeS),
                    children: [
                      TextSpan(
                        text: 'Masuk di sini',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: kFontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // TOMBOL LANJUT
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // PINDAH KE SCREEN 2 (VERIFIKASI)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VerificationScreen()),
                    );
                  },
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white, fontSize: kFontSizeN)),
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
