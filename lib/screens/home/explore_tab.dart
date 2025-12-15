import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_screen.dart';
import 'detail_screen.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  // Variabel untuk menyimpan data profil user
  String _userName = "Pengguna";
  String _userAvatarUrl = ""; // Kosong = pakai inisial/default

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fungsi ambil profil dari database
  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final data = await Supabase.instance.client
            .from('pengguna')
            .select('username, foto_profil, id_pengguna')
            .eq('email', user.email!)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _userName = data['username'] ?? "Pengguna";
            _userAvatarUrl = data['foto_profil'] ?? "";
          });
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }
    }
  }

  // Fungsi untuk refresh data saat kembali dari detail screen (jika ada update rating)
  Future<void> _refreshData() async {
    setState(() {});
    _fetchUserProfile(); // Refresh profil juga kalau perlu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER PROFILE (DINAMIS)
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _userAvatarUrl.isNotEmpty
                      ? NetworkImage(_userAvatarUrl)
                      : null,
                  child: _userAvatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                          fontWeight: kFontWeightBold, fontSize: kFontSizeN),
                    ),
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
                  ],
                ),
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

          const SizedBox(height: 24),

          // 3. LIST DESTINASI (SUPABASE)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              // Fetch data dari tabel 'destinasi', urutkan berdasarkan rating tertinggi (opsional)
              future: Supabase.instance.client
                  .from('destinasi')
                  .select()
                  .order('id_destinasi', ascending: true), // Urutkan biar rapi
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

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                    itemCount: dataList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      // Konversi JSON ke Object Destination
                      final dest = Destination.fromJson(dataList[index]);

                      return _buildDestinationCard(context, dest);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Card Custom
  Widget _buildDestinationCard(BuildContext context, Destination dest) {
    return GestureDetector(
      onTap: () async {
        // Navigate dan tunggu hasil (siapa tau rating berubah setelah diulas)
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(destination: dest)),
        );
        // Refresh halaman saat kembali
        _refreshData();
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[300],
          image: DecorationImage(
            image: NetworkImage(dest.imageUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Nama & Lokasi
                  Expanded(
                    child: Column(
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
                  
                  // RATING BADGE (Yang Kamu Minta)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Transparan dikit
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          dest.rating.toStringAsFixed(1), // Format 1 desimal (e.g., 4.5)
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: kFontSizeXS
                          ),
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
}