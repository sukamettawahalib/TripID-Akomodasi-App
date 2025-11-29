import 'package:flutter/material.dart';
import 'register_details_screen.dart';
import '../../shared/constants.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

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
                'Verifikasi Email',
                style: TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kami telah mengirimkan kode 4 digit ke emailmu. Masukkan kode verifikasi',
                style: TextStyle(fontSize: kFontSizeN, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              // OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:List.generate(4, (index) => _buildOtpBox(context)),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Tidak menerima kode? Kirim ulang',
                  style: TextStyle(color: Colors.grey[600], fontSize: kFontSizeS),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // PINDAH KE SCREEN 3 (DETAIL PROFIL)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterDetailsScreen()),
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

  Widget _buildOtpBox(BuildContext context) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryBlue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
        ),
      ),
    );
  }
}
