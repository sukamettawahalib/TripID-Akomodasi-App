import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Register user directly with email and password
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email redirect
      );
      
      print('SignUp response: User=${response.user?.id}, Session=${response.session != null}'); // Debug log
      
      if (response.user != null) {
        return {
          'success': true,
          'message': 'Akun berhasil dibuat',
          'user': response.user,
          'session': response.session,
        };
      } else {
        return {
          'success': false,
          'message': 'Registrasi gagal',
        };
      }
    } on AuthException catch (e) {
      print('AuthException in registerWithEmail: ${e.message}'); // Debug log
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      print('Exception in registerWithEmail: ${e.toString()}'); // Debug log
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Verify OTP code - No longer needed with direct registration
  // Future<Map<String, dynamic>> verifyOtp({
  //   required String email,
  //   required String otpCode,
  // }) async {
  //   ...
  // }

  // Complete user registration by creating user profile in pengguna table
  Future<Map<String, dynamic>> completeRegistration({
    required String email,
    required String username,
    required String password,
    String? fotoProfil,
  }) async {
    try {
      // First, register user with Supabase Auth
      final authResult = await registerWithEmail(
        email: email,
        password: password,
      );

      if (!authResult['success']) {
        return authResult;
      }

      final user = authResult['user'] as User;

      // Insert user data into pengguna table
      try {
        final insertResult = await _supabase.from('pengguna').insert({
          'email': user.email,
          'username': username,
          'password': password, // Note: In production, you should hash this
          'foto_profil': fotoProfil,
          'total_trip': 0,
          'jarak_tempuh': 0,
          'jam_terbang': 0,
        }).select();

        print('Insert result: $insertResult'); // Debug log

        return {
          'success': true,
          'message': 'Registrasi berhasil',
          'user': user,
        };
      } on PostgrestException catch (e) {
        print('PostgrestException: ${e.message}, Code: ${e.code}, Details: ${e.details}'); // Debug log
        // Sign out the user since profile creation failed
        await _supabase.auth.signOut();
        return {
          'success': false,
          'message': 'Gagal menyimpan profil: ${e.message}',
        };
      }
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Database error: ${e.message}',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': 'Auth error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Login berhasil',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Login gagal',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Sign out
  Future<Map<String, dynamic>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return {
        'success': true,
        'message': 'Berhasil keluar',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get user profile from pengguna table
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'User tidak ditemukan',
        };
      }

      final response = await _supabase
          .from('pengguna')
          .select()
          .eq('email', user.email!)
          .single();

      return {
        'success': true,
        'profile': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Resend OTP - No longer needed with direct registration
  // Future<Map<String, dynamic>> resendOtp(String email) async {
  //   return await sendOtpToEmail(email);
  // }
}
