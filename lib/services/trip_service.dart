import 'package:supabase_flutter/supabase_flutter.dart';

class TripService {
  final _supabase = Supabase.instance.client;

  // 1. CREATE: Menambah Trip Baru
  Future<void> createTrip({
    required String judul,
    required String tglBerangkat,
    required String tglKembali,
    required int jumlahOrang,
    required double budgetMin,
    required double budgetMax,
    String? imageUrl, // <--- 1. Terima parameter gambar
  }) async {
    // Kita asumsikan user sudah login & punya ID (hardcode ID 1 dulu untuk tes jika belum login)
    // Nanti diganti: _supabase.auth.currentUser!.id
    final userId = 1; 

    await _supabase.from('petualangan').insert({
      'id_pembuat': userId,
      'judul': judul,
      'tanggal_berangkat': tglBerangkat, // Format: YYYY-MM-DD
      'tanggal_kembali': tglKembali,     // Format: YYYY-MM-DD
      'jumlah_orang': jumlahOrang,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'image_url': imageUrl, // <--- 2. Simpan ke kolom database
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 2. READ: Mengambil Daftar Trip
  Future<List<Map<String, dynamic>>> getMyTrips() async {
    // Ambil data dari tabel 'petualangan'
    // Urutkan berdasarkan tanggal dibuat paling baru
    final response = await _supabase
        .from('petualangan')
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
}