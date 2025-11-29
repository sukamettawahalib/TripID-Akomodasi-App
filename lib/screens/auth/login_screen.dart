import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'register_email_screen.dart';
import '../../shared/constants.dart';
import '../../shared/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      // AppBar kosong untuk memberi jarak status bar tapi tanpa tombol back jika ini halaman utama
      appBar: AppBar(backgroundColor: kWhite, elevation: 0, toolbarHeight: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Masuk',
                style: TextStyle(fontSize: kFontSizeXL, fontWeight: kFontWeightBold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukkan detail akunmu',
                style: TextStyle(fontSize: kFontSizeN, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              buildTextField(label: 'Email'),
              const SizedBox(height: 16),
              buildTextField(label: 'Kata sandi', isPassword: true),
              const SizedBox(height: 40),
              
              // BUTTON MASUK (Filled)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                     Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const HomeScreen()), 
                      (route) => false
                    );
                  },
                  child: const Text('Masuk', style: TextStyle(color: kWhite, fontSize: kFontSizeN)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // BUTTON BELUM PUNYA AKUN (Outlined)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Ke Screen RegisterEmailScreen
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterEmailScreen()),
                    );
                  },
                  child: const Text('Belum punya akun', style: TextStyle(color: kPrimaryBlue, fontSize: kFontSizeN)),
                ),
              ),
              
              const SizedBox(height: 30),
              const Center(
                child: Text('atau masuk dengan', style: TextStyle(fontSize: kFontSizeXS, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              
              // SOCIAL BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(Icons.g_mobiledata, Colors.red), // Placeholder Google
                  const SizedBox(width: 20),
                  _socialButton(Icons.facebook, Colors.blue), // Placeholder Facebook
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
