import 'package:supabase_flutter/supabase_flutter.dart';

class TripService {
  final _supabase = Supabase.instance.client;

  // GET
  Future<List<Map<String, dynamic>>> getMyTrips() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('petualangan')
          .select()
          .eq('id_pembuat', user.id) // user.id adalah UUID (String)
          .order('id_petualangan', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // CREATE
  Future<void> createTrip({
    required String judul,
    required String tglBerangkat,
    required String tglKembali,
    required int jumlahOrang,
    required double budgetMin,
    required double budgetMax,
    String? imageUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await _supabase.from('petualangan').insert({
      'id_pembuat': user.id, // PASTI UUID (String)
      'judul': judul,
      'tanggal_berangkat': tglBerangkat,
      'tanggal_kembali': tglKembali,
      'jumlah_orang': jumlahOrang,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'image_url': imageUrl,
    });
  }

  // DELETE
  Future<void> deleteTrip(int id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase.from('petualangan').delete().eq('id_petualangan', id);
  }
}