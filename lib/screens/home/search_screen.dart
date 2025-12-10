import 'package:flutter/material.dart';
import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../destination/destination_info_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan import Supabase

// ==========================================
// SEARCH SCREEN (REAL DATA SUPABASE)
// ==========================================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 1. Controller untuk menangkap teks inputan
  final TextEditingController _searchController = TextEditingController();

  // 2. Variabel untuk menampung hasil
  List<Destination> _hasilPencarian = [];
  
  // Variabel penampung SEMUA data asli dari Supabase
  List<Destination> _semuaData = [];
  
  // Status loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi ambil data saat layar dibuka
    _ambilDataDariSupabase();
  }

  // 3. FUNGSI AMBIL DATA DARI SUPABASE
  Future<void> _ambilDataDariSupabase() async {
    try {
      // Mengambil semua data dari tabel 'destinasi'
      final response = await Supabase.instance.client
          .from('destinasi')
          .select();

      // Konversi data mentah (JSON/Map) menjadi List<Destination>
      final List<Destination> dataAsli = (response as List)
          .map((item) => Destination.fromJson(item))
          .toList();

      if (mounted) {
        setState(() {
          _semuaData = dataAsli;       // Isi gudang data utama
          _hasilPencarian = dataAsli;  // Awalnya tampilkan semua
          _isLoading = false;          // Matikan loading
        });
      }
    } catch (e) {
      debugPrint("Error mengambil data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Tetap matikan loading meski error agar tidak stuck
        });
      }
    }
  }

  // 4. Fungsi Logika Pencarian (Client-side search)
  //    Kita memfilter data yang sudah diambil di _semuaData
  void _jalankanPencarian(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _hasilPencarian = _semuaData;
      } else {
        _hasilPencarian = _semuaData
            .where((destinasi) =>
                destinasi.name.toLowerCase().contains(keyword.toLowerCase()) ||
                destinasi.location.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
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
                      autofocus: false, // Ubah ke false jika tidak ingin keyboard langsung muncul
                      onChanged: _jalankanPencarian, // LOGIKA DIPANGGIL DI SINI
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
                  // Tombol Filter (Visual Saja)
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA5F3FC), // Cyan muda
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Color(0xFF0E7490)),
                  ),
                ],
              ),
            ),

            // --- FILTER CHIPS ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildChip("Semua", true),
                  _buildChip("Terdekat", false),
                  _buildChip("Populer", false),
                  _buildChip("Relevan", false),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // --- LIST HASIL PENCARIAN (BAGIAN DINAMIS) ---
            Expanded(
              child: _isLoading 
                // Tampilkan Loading jika sedang mengambil data
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
                            isLarge: true, // Tampilan besar ke bawah
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DestinationInfoScreen(destination: data),
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

  // Helper widget kecil untuk Chip
  Widget _buildChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFA5F3FC) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: isActive ? const Color(0xFF0E7490) : Colors.grey),
      ),
    );
  }
}