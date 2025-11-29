import 'package:flutter/material.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';
import '../../shared/widgets.dart'; // Mengambil DestinationCard
import '../destination/destination_info_screen.dart'; // Import untuk navigate ke detail

// ==========================================
// SEARCH SCREEN (VERSI DINAMIS / PINTAR)
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
  
  // Gabungkan semua data (dari models.dart) untuk pencarian
  final List<Destination> _semuaData = [...popularDestinations, ...hiddenGems, ...otherDestinations];

  @override
  void initState() {
    super.initState();
    // Awalnya tampilkan semua data
    _hasilPencarian = _semuaData;
  }

  // 3. Fungsi Logika Pencarian
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
                      autofocus: true,
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
              child: _hasilPencarian.isEmpty
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
                        // MENGGUNAKAN WIDGET 'DestinationCard' DARI FILE WIDGETS.DART
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