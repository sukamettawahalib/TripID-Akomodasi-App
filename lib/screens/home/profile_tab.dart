import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/constants.dart';
import '../auth/login_screen.dart'; // Import Login Screen
import 'edit_profil.dart'; // Import Edit Profil Screen
import 'itinerary_screen.dart'; // Import Itinerary Screen

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

  // State Trips
  List<Map<String, dynamic>> _ongoingTrips = [];
  List<Map<String, dynamic>> _historyTrips = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserTrips();
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
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. FETCH TRIPS AND FILTER BY DATE ---
  Future<void> _fetchUserTrips() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('petualangan')
          .select()
          .eq('id_pembuat', user.id)
          .order('tanggal_berangkat', ascending: false);

      final trips = List<Map<String, dynamic>>.from(response);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (mounted) {
        setState(() {
          // Ongoing: trips where current date is between start and end date
          _ongoingTrips = trips.where((trip) {
            try {
              final startDate = DateTime.parse(trip['tanggal_berangkat']);
              final endDate = DateTime.parse(trip['tanggal_kembali']);
              final start = DateTime(startDate.year, startDate.month, startDate.day);
              final end = DateTime(endDate.year, endDate.month, endDate.day);
              
              return today.isAtSameMomentAs(start) || 
                     today.isAtSameMomentAs(end) ||
                     (today.isAfter(start) && today.isBefore(end));
            } catch (e) {
              return false;
            }
          }).toList();

          // History: trips where end date has passed
          _historyTrips = trips.where((trip) {
            try {
              final endDate = DateTime.parse(trip['tanggal_kembali']);
              final end = DateTime(endDate.year, endDate.month, endDate.day);
              return today.isAfter(end);
            } catch (e) {
              return false;
            }
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching trips: $e");
    }
  }

  // --- 3. LOGIKA LOGOUT ---
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
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
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

          // 3. Stats Card (Total Trip)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Text("Total trip", style: TextStyle(fontSize: kFontSizeS, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(_totalTrip.toString(), style: const TextStyle(fontSize: 32, fontWeight: kFontWeightBold)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 4. Ongoing Trip (Dynamic)
          if (_ongoingTrips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ongoing", style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold)),
                  const SizedBox(height: 12),
                  ..._ongoingTrips.map((trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOngoingTripCard(trip),
                  )).toList(),
                ],
              ),
            ),

          if (_ongoingTrips.isNotEmpty) const SizedBox(height: 30),

          // 5. Histori (Dynamic)
          if (_historyTrips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Histori", style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold)),
                  const SizedBox(height: 12),
                  ..._historyTrips.map((trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildHistoryTripCard(trip),
                  )).toList(),
                ],
              ),
            ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildOngoingTripCard(Map<String, dynamic> trip) {
    final title = trip['judul'] ?? 'Untitled Trip';
    final imageUrl = trip['image_url'] ?? 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05';
    
    // Calculate duration
    String duration = '1 hari';
    try {
      final startDate = DateTime.parse(trip['tanggal_berangkat']);
      final endDate = DateTime.parse(trip['tanggal_kembali']);
      final days = endDate.difference(startDate).inDays + 1;
      final nights = days - 1;
      
      if (nights > 0) {
        duration = '$days hari & $nights malam';
      } else {
        duration = '$days hari';
      }
    } catch (e) {
      debugPrint('Error calculating duration: $e');
    }

    return GestureDetector(
      onTap: () {
        // Navigate to itinerary screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItineraryScreen(tripData: trip),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
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
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: kFontSizeN, fontWeight: kFontWeightBold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(duration, style: const TextStyle(fontSize: kFontSizeXS, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Sedang Berlangsung',
                        style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTripCard(Map<String, dynamic> trip) {
    final title = trip['judul'] ?? 'Untitled Trip';
    final imageUrl = trip['image_url'] ?? 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05';
    
    // Calculate duration
    String duration = '1 hari';
    try {
      final startDate = DateTime.parse(trip['tanggal_berangkat']);
      final endDate = DateTime.parse(trip['tanggal_kembali']);
      final days = endDate.difference(startDate).inDays + 1;
      final nights = days - 1;
      
      if (nights > 0) {
        duration = '$days hari & $nights malam';
      } else {
        duration = '$days hari';
      }
    } catch (e) {
      debugPrint('Error calculating duration: $e');
    }

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
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
                onError: (_, __) {},
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: kFontSizeN, fontWeight: kFontWeightBold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(duration, style: const TextStyle(fontSize: kFontSizeXS, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}