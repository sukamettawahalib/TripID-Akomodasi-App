import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_details_screen.dart';
import '../../shared/constants.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class VerificationScreen extends StatefulWidget {
  final String email;
  
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final _authService = AuthService();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    final otpCode = _otpControllers.map((c) => c.text).join();
    
    if (otpCode.length != 6) {
      _showErrorDialog('Masukkan kode OTP 6 digit');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.verifyOtp(
      email: widget.email,
      otpCode: otpCode,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterDetailsScreen(),
          ),
        );
      }
    } else {
      _showErrorDialog(result['message']);
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    final result = await _authService.resendOtp(widget.email);

    setState(() => _isLoading = false);

    if (result['success']) {
      _startResendTimer();
      _showSuccessDialog('Kode OTP berhasil dikirim ulang');
    } else {
      _showErrorDialog(result['message']);
    }
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
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
                'Verifikasi Email',
                style: TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
              ),
              const SizedBox(height: 16),
              Text(
                'Kami telah mengirimkan kode 6 digit ke ${widget.email}. Masukkan kode verifikasi',
                style: const TextStyle(fontSize: kFontSizeN, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              // OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend 
                        ? 'Tidak menerima kode? Kirim ulang'
                        : 'Kirim ulang dalam $_resendTimer detik',
                    style: TextStyle(
                      color: _canResend ? kPrimaryBlue : Colors.grey[600],
                      fontSize: kFontSizeS,
                      fontWeight: _canResend ? kFontWeightBold : kFontWeightMedium,
                    ),
                  ),
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
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Lanjut', style: TextStyle(color: Colors.white, fontSize: kFontSizeN)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryBlue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            }
            if (value.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
