import 'package:flutter/material.dart';
import 'register_details_screen.dart';
import 'login_screen.dart';
import '../../shared/constants.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continueToDetails() async {
    final email = _emailController.text.trim();
    
    // Validate email
    if (email.isEmpty) {
      _showErrorDialog('Email tidak boleh kosong');
      return;
    }
    
    if (!_isValidEmail(email)) {
      _showErrorDialog('Format email tidak valid');
      return;
    }

    // Navigate directly to details screen (skip OTP)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterDetailsScreen(email: email),
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'contoh@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kPrimaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Login jika sudah punya akun
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
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
                  onPressed: _continueToDetails,
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
