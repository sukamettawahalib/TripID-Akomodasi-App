import 'package:supabase_flutter/supabase_flutter.dart';

class ItineraryService {
  final _supabase = Supabase.instance.client;

  /// Save a note to the database
  /// [idPetualangan] - The trip ID
  /// [hariKe] - Day number (0-indexed in UI, but stored as 1-indexed)
  /// [tipeCatatan] - Type of note: 'aktivitas' or 'transportasi'
  /// [waktu] - Optional time string (e.g., "09:00")
  /// [konten] - The note content
  Future<Map<String, dynamic>?> saveNote({
    required int idPetualangan,
    required int hariKe,
    required String tipeCatatan,
    String? waktu,
    required String konten,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final response = await _supabase
          .from('itinerary_catatan')
          .insert({
            'id_petualangan': idPetualangan,
            'hari_ke': hariKe + 1, // Convert from 0-indexed to 1-indexed
            'tipe_catatan': tipeCatatan,
            'waktu': waktu ?? '',
            'konten': konten,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print("Error saving note: $e");
      return null;
    }
  }

  /// Load all notes for a specific trip
  /// Returns a map with structure: {dayIndex: {type: [notes]}}
  Future<Map<int, Map<String, List<Map<String, dynamic>>>>> loadNotesForTrip(
      int idPetualangan) async {
    try {
      final response = await _supabase
          .from('itinerary_catatan')
          .select()
          .eq('id_petualangan', idPetualangan)
          .order('hari_ke', ascending: true)
          .order('created_at', ascending: true);

      final notes = List<Map<String, dynamic>>.from(response);
      
      // Organize notes by day and type
      Map<int, Map<String, List<Map<String, dynamic>>>> organized = {};
      
      for (var note in notes) {
        int dayIndex = (note['hari_ke'] as int) - 1; // Convert to 0-indexed
        String type = note['tipe_catatan'];
        
        if (!organized.containsKey(dayIndex)) {
          organized[dayIndex] = {'aktivitas': [], 'transportasi': []};
        }
        
        organized[dayIndex]![type]!.add({
          'id': note['id_catatan'],
          'time': note['waktu'] ?? '',
          'content': note['konten'],
        });
      }
      
      return organized;
    } catch (e) {
      print("Error loading notes: $e");
      return {};
    }
  }

  /// Delete a specific note by ID
  Future<bool> deleteNote(int idCatatan) async {
    try {
      await _supabase
          .from('itinerary_catatan')
          .delete()
          .eq('id_catatan', idCatatan);
      return true;
    } catch (e) {
      print("Error deleting note: $e");
      return false;
    }
  }

  /// Update an existing note
  Future<bool> updateNote({
    required int idCatatan,
    String? waktu,
    String? konten,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (waktu != null) updates['waktu'] = waktu;
      if (konten != null) updates['konten'] = konten;

      if (updates.isEmpty) return false;

      await _supabase
          .from('itinerary_catatan')
          .update(updates)
          .eq('id_catatan', idCatatan);

      return true;
    } catch (e) {
      print("Error updating note: $e");
      return false;
    }
  }

  /// Delete all notes for a specific trip (useful when deleting a trip)
  Future<bool> deleteAllNotesForTrip(int idPetualangan) async {
    try {
      await _supabase
          .from('itinerary_catatan')
          .delete()
          .eq('id_petualangan', idPetualangan);
      return true;
    } catch (e) {
      print("Error deleting trip notes: $e");
      return false;
    }
  }
}
