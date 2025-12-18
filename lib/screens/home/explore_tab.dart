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
  String _userName = "Pengguna";
  String _userAvatarUrl = "";
  
  // --- VARIABEL UNTUK DATA & FILTER ---
  List<Destination> _allDestinations = [];      // Data asli dari DB
  List<Destination> _displayDestinations = [];  // Data yang ditampilkan (hasil filter)
  bool _isLoadingDestinations = true;
  String _selectedCategory = 'Semua';           // Filter Aktif

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchDestinations(); // Ambil data destinasi di awal
  }

  // Ambil Data Destinasi (Gantikan FutureBuilder)
  Future<void> _fetchDestinations() async {
    try {
      final response = await Supabase.instance.client
          .from('destinasi')
          .select()
          .order('id_destinasi', ascending: true);

      final List<Destination> data = (response as List)
          .map((item) => Destination.fromJson(item))
          .toList();

      if (mounted) {
        setState(() {
          _allDestinations = data;
          _displayDestinations = data; // Awalnya tampilkan semua
          _isLoadingDestinations = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching destinations: $e");
      if (mounted) setState(() => _isLoadingDestinations = false);
    }
  }

  // Logic Filter
  void _applyFilter(String category) {
    setState(() {
      _selectedCategory = category;
      
      // Reset ke data asli dulu
      List<Destination> temp = List.from(_allDestinations);

      if (category == 'Populer') {
        // Sort rating tertinggi ke terendah
        temp.sort((a, b) => b.rating.compareTo(a.rating));
      } 
      // Kalau 'Semua', biarkan urutan default (ID)

      _displayDestinations = temp;
    });
  }

  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final data = await Supabase.instance.client
            .from('pengguna')
            .select('username, foto_profil')
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

  Future<void> _refreshData() async {
    // Reload semua data
    await Future.wait([
      _fetchUserProfile(),
      _fetchDestinations(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView( // Pakai ScrollView agar Header ikut ter-scroll
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER PROFILE
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
                          style: const TextStyle(fontWeight: kFontWeightBold, fontSize: kFontSizeN),
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
                  style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold, height: 1.2),
                ),
              ),

              const SizedBox(height: 20),

              // 2. SEARCH BAR (Button Only)
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
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[400]),
                        const SizedBox(width: 10),
                        Text("Cari destinasi wisata", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. FILTER CHIPS (BARU DITAMBAHKAN)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildFilterChip("Semua"),
                    _buildFilterChip("Populer"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. LIST DESTINASI
              _isLoadingDestinations
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _displayDestinations.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: Text('Belum ada data destinasi.')),
                        )
                      : ListView.separated(
                          // ShrinkWrap true & Physics disable agar scroll nyatu dengan SingleChildScrollView utama
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                          itemCount: _displayDestinations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildDestinationCard(context, _displayDestinations[index]);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Chip Filter
  Widget _buildFilterChip(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA5F3FC) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive 
              ? Border.all(color: const Color(0xFF0E7490)) 
              : Border.all(color: Colors.grey.shade300),
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

  Widget _buildDestinationCard(BuildContext context, Destination dest) {
    // ... (Kode widget ini tetap sama seperti sebelumnya) ...
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(destination: dest)),
        );
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          dest.rating.toStringAsFixed(1),
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