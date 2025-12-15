import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/constants.dart';
import '../auth/login_screen.dart'; // Import Login Screen
import 'edit_profil.dart'; // Import Edit Profil Screen

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // State Data Profil
  String _fullName = "Memuat...";
  String? _avatarUrl;
  
  // State Statistik
  int _totalTrip = 0;
  int _jarakTempuh = 0;
  int _jamTerbang = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // --- 1. AMBIL DATA DARI SUPABASE ---
  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      final data = await Supabase.instance.client
          .from('pengguna')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _fullName = data['username'] ?? "Pengguna";
          _avatarUrl = data['foto_profil'];
          _totalTrip = data['total_trip'] ?? 0;
          _jarakTempuh = data['jarak_tempuh'] ?? 0;
          _jamTerbang = data['jam_terbang'] ?? 0;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. LOGIKA LOGOUT ---
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Keluar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // 1. Header & Profile Picture
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Cover Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1436491865332-7a61a109cc05"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Profile Picture (Sinkron)
              Positioned(
                bottom: -40,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),

          // 2. Info & Edit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Agar nama panjang tidak overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName, // Nama sinkron
                        style: const TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Row Tombol Aksi (Logout & Edit)
                Row(
                  children: [
                    // Tombol Logout (Kecil Merah)
                    IconButton(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      tooltip: "Keluar",
                    ),
                    
                    const SizedBox(width: 8),

                    // Tombol Edit Profil
                    OutlinedButton(
                      onPressed: () async {
                        // Navigate ke Edit Profile & Refresh saat kembali
                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfilScreen()),
                        );
                        if (result == true) {
                          _fetchUserProfile();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("Edit profil", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Stats Cards (Sinkron)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Total trip", _totalTrip.toString()),
                _buildStatCard("Jarak ditempuh", _jarakTempuh.toString()),
                _buildStatCard("Jam terbang", _jamTerbang.toString()),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 4. Friends (Teman - Masih Mockup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Teman", style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=${index + 10}"),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 5. Ongoing Trip (Mockup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ongoing", style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold)),
                const SizedBox(height: 12),
                _buildTripCard(
                  "Banyuwangi Trip :)",
                  "3 hari & 2 malam",
                  "https://images.unsplash.com/photo-1596401057633-56565384358a",
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 6. Histori (Mockup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Histori", style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold)),
                const SizedBox(height: 12),
                _buildTripCard(
                  "Bromo Midnight",
                  "1 hari",
                  "https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: kFontSizeXXS, color: Colors.black54), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold)),
        ],
      ),
    );
  }

  Widget _buildTripCard(String title, String duration, String imageUrl) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: kFontSizeN, fontWeight: kFontWeightBold)),
                  const SizedBox(height: 4),
                  Text(duration, style: const TextStyle(fontSize: kFontSizeXS, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}