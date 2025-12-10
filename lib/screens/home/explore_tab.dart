import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_screen.dart';
import 'detail_screen.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Column biasa tanpa SingleChildScrollView utama
    // karena kita ingin list-nya yang bisa di-scroll (Expanded)
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER PROFILE
          const SizedBox(height: 60), // Sedikit disesuaikan biar pas status bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Naufal Maula",
                        style: TextStyle(
                            fontWeight: kFontWeightBold, fontSize: kFontSizeN)),
                    Text("ID: 3770",
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: kFontSizeXS)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Temukan dan Jelajahi\nDestinasi Terbaik Indonesia",
              style: TextStyle(
                  fontSize: kFontSizeM,
                  fontWeight: kFontWeightBold,
                  height: 1.2),
            ),
          ),

          const SizedBox(height: 20),

          // 2. SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SearchScreen()));
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2))
                          ]),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[400]),
                          const SizedBox(width: 10),
                          Text("Cari destinasi wisata",
                              style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  ),
                ),
                // Filter dihapus sesuai request, sisa spacer kalau mau
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. LIST DESTINASI (SUPABASE)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              // Fetch data dari tabel 'destinasi'
              future: Supabase.instance.client.from('destinasi').select(),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error State
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Empty State
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada data destinasi.'));
                }

                final dataList = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                  itemCount: dataList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    // Konversi JSON Supabase ke Object Destination
                    final dest = Destination.fromJson(dataList[index]);

                    return _buildDestinationCard(context, dest);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Card (Disederhanakan untuk list vertikal)
  Widget _buildDestinationCard(BuildContext context, Destination dest) {
    return GestureDetector(
      onTap: () {
        // Kita passing object destination ke detail screen
        // Pastikan DetailScreen menerima parameter 'destination' tipe dynamic/object ini
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DetailScreen(destination: dest)));
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[300], // Placeholder color
          image: DecorationImage(
            image: NetworkImage(dest.imageUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Handle jika gambar error, tidak crash
            },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dest.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: kFontWeightBold,
                    fontSize: kFontSizeN),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dest.location,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: kFontSizeXXS),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
