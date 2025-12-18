import 'package:flutter/material.dart';
import '../../shared/models.dart';
import 'detail_screen.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Destination> _hasilPencarian = [];
  List<Destination> _semuaData = [];
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
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData() {
    List<Destination> hasilSementara = List.from(_semuaData);
    String keyword = _searchController.text.toLowerCase();
    
    // 1. Filter Search Text
    if (keyword.isNotEmpty) {
      hasilSementara = hasilSementara.where((destinasi) =>
          destinasi.name.toLowerCase().contains(keyword) ||
          destinasi.location.toLowerCase().contains(keyword)
      ).toList();
    }

    // 2. Filter Kategori (Populer = Sort by Rating)
    setState(() {
      if (_selectedCategory == 'Populer') {
        hasilSementara.sort((a, b) => b.rating.compareTo(a.rating));
      } 
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
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
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
                      ),
                    ),
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
                  ? const Center(child: Text("Tidak ditemukan"))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _hasilPencarian.length,
                      separatorBuilder: (_,__) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final data = _hasilPencarian[index];
                        // MENGGUNAKAN CUSTOM CARD AGAR ADA RATING
                        return _buildSearchCardWithRating(data);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CARD BARU DENGAN RATING ---
  Widget _buildSearchCardWithRating(Destination dest) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => DetailScreen(destination: dest)));
      },
      child: Container(
        height: 180, // Sedikit lebih kecil dari explore
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[300],
          image: DecorationImage(
            image: NetworkImage(dest.imageUrl),
            fit: BoxFit.cover,
            onError: (_,__) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dest.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // --- BADGE RATING ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          dest.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = label);
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