import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../shared/constants.dart';
import '../../shared/widgets.dart';

class RegisterDetailsScreen extends StatelessWidget {
  const RegisterDetailsScreen({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sedikit lagi',
                style: TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tinggal menambahkan beberapa detail lagi',
                style: TextStyle(fontSize: kFontSizeN, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              buildTextField(label: 'Username'),
              const SizedBox(height: 16),
              buildTextField(label: 'Kata sandi', isPassword: true),
              const SizedBox(height: 16),
              buildTextField(label: 'Verifikasi kata sandi', isPassword: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // SELESAI DAFTAR -> MENUJU HOME atau LOGIN
                    // Di sini kita arahkan ke LoginScreen sebagai simulasi
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false // Hapus history back stack
                    );
                  },
                  child: const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: kFontSizeN)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
