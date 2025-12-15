import 'package:flutter/material.dart';
import 'home_screen.dart';

// --- CONFIG VARS ---
const Color kPrimaryBlue = Color(0xFF2D79C7);

// ==========================================
// 1. SCREEN: BUAT AKUN (Input Email)
// ==========================================
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukkan email yang ingin digunakan untuk akun TripID',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              _buildTextField(label: 'Email', hint: 'contoh@email.com'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Login jika sudah punya akun
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Punya akun? ',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Masuk di sini',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
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
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white, fontSize: 16)),
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

// ==========================================
// 2. SCREEN: VERIFIKASI EMAIL (OTP)
// ==========================================
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kami telah mengirimkan kode 4 digit ke emailmu. Masukkan kode verifikasi',
                style: TextStyle(fontSize: 16, color: Colors.black87),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white, fontSize: 16)),
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: "", // Menghilangkan counter angka kecil di bawah
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. SCREEN: SEDIKIT LAGI (Username & Pass)
// ==========================================
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tinggal menambahkan beberapa detail lagi',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              _buildTextField(label: 'Username'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Kata sandi', isPassword: true),
              const SizedBox(height: 16),
              _buildTextField(label: 'Verifikasi kata sandi', isPassword: true),
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
                  child: const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. SCREEN: LOGIN (Masuk)
// ==========================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar kosong untuk memberi jarak status bar tapi tanpa tombol back jika ini halaman utama
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, toolbarHeight: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Masuk',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukkan detail akunmu',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              _buildTextField(label: 'Email'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Kata sandi', isPassword: true),
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
                  child: const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  child: const Text('Belum punya akun', style: TextStyle(color: kPrimaryBlue, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ==========================================
// WIDGET HELPER (Untuk TextField yang seragam)
// ==========================================
Widget _buildTextField({required String label, String? hint, bool isPassword = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.5)),
        ),
        child: TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label, // Menggunakan label sebagai hint text di dalam box (sesuai gambar)
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    ],
  );
}