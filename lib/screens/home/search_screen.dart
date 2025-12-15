import 'package:flutter/material.dart';
import '../../shared/models.dart';
import '../../shared/widgets.dart';
import 'detail_screen.dart'; // Pastikan path ini benar sesuai file DetailScreen kamu
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================
// SEARCH SCREEN (REVISI: HANYA FILTER POPULER)
// ==========================================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 1. Controller Text
  final TextEditingController _searchController = TextEditingController();

  // 2. Variabel Data
  List<Destination> _hasilPencarian = [];
  List<Destination> _semuaData = [];
  
  // 3. Status
  bool _isLoading = true;
  String _selectedCategory = 'Semua'; 

  @override
  void initState() {
    super.initState();
    _ambilDataDariSupabase();
  }

  Future<void> _ambilDataDariSupabase() async {
    try {
      final response = await Supabase.instance.client.from('destinasi').select();

      final List<Destination> dataAsli = (response as List)
          .map((item) => Destination.fromJson(item))
          .toList();

      if (mounted) {
        setState(() {
          _semuaData = dataAsli;
          _hasilPencarian = dataAsli;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error mengambil data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 4. LOGIKA FILTER (CUMA ADA SEMUA & POPULER) ---
  void _filterData() {
    // A. Mulai dari data asli
    List<Destination> hasilSementara = List.from(_semuaData);

    // B. Filter berdasarkan Teks Pencarian
    String keyword = _searchController.text.toLowerCase();
    if (keyword.isNotEmpty) {
      hasilSementara = hasilSementara.where((destinasi) =>
          destinasi.name.toLowerCase().contains(keyword) ||
          destinasi.location.toLowerCase().contains(keyword)
      ).toList();
    }

    // C. Filter berdasarkan Kategori Chip
    setState(() {
      if (_selectedCategory == 'Populer') {
        // Logika: Urutkan berdasarkan Rating Tertinggi (Descending)
        // b.compareTo(a) artinya dari Besar ke Kecil
        hasilSementara.sort((a, b) => b.rating.compareTo(a.rating));
      } 
      // Jika 'Semua', biarkan urutan default (atau acak)

      _hasilPencarian = hasilSementara;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER & SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: false,
                      onChanged: (val) => _filterData(), 
                      decoration: InputDecoration(
                        hintText: "Cari destinasi...",
                        prefixIcon: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Filter Visual (Hiasan saja karena filter sudah di chip)
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA5F3FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Color(0xFF0E7490)),
                  ),
                ],
              ),
            ),

            // --- FILTER CHIPS (HANYA SEMUA & POPULER) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildChip("Semua"),
                  _buildChip("Populer"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // --- LIST HASIL ---
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _hasilPencarian.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text("Tidak ditemukan", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _hasilPencarian.length,
                      itemBuilder: (context, index) {
                        final data = _hasilPencarian[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DestinationCard(
                            imageUrl: data.imageUrl,
                            title: data.name,
                            location: data.location,
                            isLarge: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(destination: data),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CHIP ---
  Widget _buildChip(String label) {
    bool isActive = _selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
        _filterData(); 
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA5F3FC) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: const Color(0xFF0E7490)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF0E7490) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}