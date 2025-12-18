import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/models.dart';
import '../../shared/destination_info_models.dart';
import '../../shared/constants.dart';
import 'create_trip_screen.dart';
import 'all_reviews_screen.dart';

class DetailScreen extends StatefulWidget {
  final Destination destination;

  const DetailScreen({super.key, required this.destination});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDescriptionExpanded = false;
  
  // Map Controller
  final MapController _mapController = MapController();
  
  // State Data
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  
  // State User & Ulasan Pribadi
  int? _myDbId; // ID Integer user yang sedang login
  Review? _myExistingReview; // Objek ulasan milik user sendiri (jika ada)
  
  // New Features State
  bool _isBookmarked = false;
  
  // Sample photo gallery - dapat diganti dengan data dari database
  final List<String> _photoGallery = [];

  @override
  void initState() {
    super.initState();
    _initPageData();
    _loadBookmarkStatus();
    _initPhotoGallery();
  }

  // --- 1. INISIALISASI DATA (USER & ULASAN) ---
  Future<void> _initPageData() async {
    await _getCurrentUserDbId(); // 1. Cari tahu siapa saya (ID Integer)
    await _fetchReviews();       // 2. Ambil ulasan & cek mana punya saya
  }

  // Cari ID Integer user berdasarkan Email Login
  Future<void> _getCurrentUserDbId() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser?.email == null) return;

    try {
      final data = await Supabase.instance.client
          .from('pengguna')
          .select('id_pengguna')
          .eq('email', authUser!.email!)
          .maybeSingle();
      
      if (data != null && mounted) {
        setState(() {
          _myDbId = data['id_pengguna'];
        });
      }
    } catch (e) {
      debugPrint("Gagal load user ID: $e");
    }
  }

  // --- 2. FETCH REVIEWS ---
  Future<void> _fetchReviews() async {
    try {
      final response = await Supabase.instance.client
          .from('ulasan')
          .select('*, pengguna(*)')
          .eq('id_destinasi', widget.destination.id)
          .order('tanggal_ulasan', ascending: false);

      final List<dynamic> rawList = response as List;
      
      // Reset ulasan saya
      Review? foundMyReview;

      // Mapping ke Object Review
      final List<Review> fetchedReviews = rawList.map((json) {
        final review = Review.fromJson(json);
        
        // LOGIKA CEK KEPEMILIKAN:
        // Jika ID Pengguna di ulasan ini == ID Saya (_myDbId)
        if (_myDbId != null && json['id_pengguna'] == _myDbId) {
          foundMyReview = review; // Simpan ulasan saya
        }
        return review;
      }).toList();

      if (mounted) {
        setState(() {
          _reviews = fetchedReviews;
          _myExistingReview = foundMyReview; // Update state ulasan saya
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  // --- 3. SUBMIT (INSERT / UPDATE) ---
  Future<void> _submitReview(double rating, String comment) async {
    if (_myDbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengidentifikasi user. Coba login ulang.")));
      return;
    }

    try {
      if (_myExistingReview != null) {
        // --- MODE EDIT (UPDATE) ---
        // Karena user sudah punya ulasan, kita UPDATE ulasan yang ID-nya sama
        await Supabase.instance.client
            .from('ulasan')
            .update({
              'komentar': comment,
              'rating': rating,
              'tanggal_ulasan': DateTime.now().toIso8601String(), // Update tanggal juga
            })
            .eq('id_ulasan', _myExistingReview!.id!); // Kunci update: ID Ulasan

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ulasan berhasil diperbarui!")));

      } else {
        // --- MODE BARU (INSERT) ---
        await Supabase.instance.client.from('ulasan').insert({
          'id_destinasi': int.parse(widget.destination.id),
          'id_pengguna': _myDbId, // Integer ID User
          'komentar': comment,
          'rating': rating,
          'tanggal_ulasan': DateTime.now().toIso8601String(),
        });

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ulasan berhasil dikirim!")));
      }

      _fetchReviews(); // Refresh list agar tampilan update
    } catch (e) {
      debugPrint("Error submitting: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan saat menyimpan.")));
    }
  }

  // --- 4. DELETE REVIEW ---
  Future<void> _deleteReview() async {
    if (_myExistingReview == null || _myExistingReview!.id == null) return;

    try {
      await Supabase.instance.client
          .from('ulasan')
          .delete()
          .eq('id_ulasan', _myExistingReview!.id!); // Hapus berdasarkan ID ulasan saya

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ulasan dihapus.")));
        setState(() {
          _myExistingReview = null; // Kosongkan state lokal
        });
        _fetchReviews(); // Refresh list
      }
    } catch (e) {
      debugPrint("Error deleting: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus ulasan.")));
    }
  }

  // --- SHOW MODAL ---
  void _showReviewModal() {
    if (_myDbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan login terlebih dahulu.")));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ReviewInputForm(
        // Jika sudah ada ulasan, isi form dengan data lama (Pre-fill)
        initialRating: _myExistingReview?.rating ?? 0,
        initialComment: _myExistingReview?.reviewText ?? '',
        onSubmit: (rating, comment) async {
          await _submitReview(rating, comment);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }
  
  // --- NEW FEATURES METHODS ---
  
  // Load bookmark status (dari local storage atau database)
  Future<void> _loadBookmarkStatus() async {
    // TODO: Implement dengan shared_preferences atau database
    // Untuk sekarang gunakan dummy
    setState(() {
      _isBookmarked = false;
    });
  }
  
  // Toggle bookmark
  Future<void> _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    // TODO: Save to database atau shared_preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Ditambahkan ke bookmark' : 'Dihapus dari bookmark'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  // Initialize photo gallery
  void _initPhotoGallery() {
    // Sample - bisa diganti dengan fetch dari database
    _photoGallery.addAll([
      widget.destination.imageUrl,
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'https://images.unsplash.com/photo-1518098268026-4e89f1a2cd8e?w=800',
    ]);
  }
  
  // Pull to refresh
  Future<void> _handleRefresh() async {
    await Future.wait([
      _fetchReviews(),
      Future.delayed(const Duration(milliseconds: 500)), // Minimum delay for UX
    ]);
  }
  
  // Share destination
  void _shareDestination() {
    // TODO: Implement with share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: ${widget.destination.name} - ${widget.destination.location}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Open in Maps
  Future<void> _openInMaps(double lat, double lng) async {
    // Try to open in Google Maps app first, fallback to browser
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    try {
      // Try to launch
      bool launched = await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        // Fallback: open in browser
        await launchUrl(
          googleMapsUri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak bisa membuka Maps. Pastikan browser Anda mengizinkan popup.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Coordinate override for specific destinations
    // This ensures correct locations even if database has wrong coordinates
    double lat = widget.destination.latitude ?? -6.2088;
    double lng = widget.destination.longitude ?? 106.8456;
    
    final String destName = widget.destination.name.toLowerCase();
    
    // Override coordinates for Indonesian tourist destinations
    if (destName.contains('bromo')) {
      lat = -7.9425; lng = 112.9531; // Kawah Bromo, Probolinggo, East Java
    } else if (destName.contains('prambanan')) {
      lat = -7.7520; lng = 110.4915; // Candi Prambanan, Yogyakarta
    } else if (destName.contains('ijen')) {
      lat = -8.0587; lng = 114.2425; // Kawah Ijen, Banyuwangi, East Java
    } else if (destName.contains('padar')) {
      lat = -8.6595; lng = 119.5845; // Pulau Padar, Komodo National Park
    } else if (destName.contains('wae rebo')) {
      lat = -8.5167; lng = 120.4667; // Wae Rebo, Flores, NTT
    } else if (destName.contains('wurung')) {
      lat = -8.0853; lng = 112.4447; // Kawah Wurung, Bondowoso, East Java
    } else if (destName.contains('raja ampat')) {
      lat = -0.2358; lng = 130.5211; // Raja Ampat, Papua Barat
    } else if (destName.contains('toba')) {
      lat = 2.6845; lng = 98.8756; // Danau Toba, North Sumatra
    } else if (destName.contains('labuan bajo')) {
      lat = -8.4967; lng = 119.8881; // Labuan Bajo, Flores, NTT
    } else if (destName.contains('dieng')) {
      lat = -7.2042; lng = 109.9069; // Dieng Plateau, Central Java
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image Section with Hero Animation
                  Stack(
                    children: [
                      // Hero Animated Background Image
                      Hero(
                        tag: 'destination-${widget.destination.id}',
                        child: Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.destination.imageUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            ),
                          ),
                        ),
                      ),
                      
                      // Back Button
                      Positioned(
                        top: 50,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                      ),
                      
                      // Action Buttons (Bookmark & Share)
                      Positioned(
                        top: 50,
                        right: 20,
                        child: Row(
                          children: [
                            // Share Button
                            GestureDetector(
                              onTap: _shareDestination,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.share, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Bookmark Button
                            GestureDetector(
                              onTap: _toggleBookmark,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  size: 20,
                                  color: _isBookmarked ? kPrimaryBlue : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                
                // White Sheet Content
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  transform: Matrix4.translationValues(0, -30, 0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.destination.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: kPrimaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.destination.location,
                                          style: const TextStyle(
                                            color: kPrimaryBlue,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.destination.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                                                // Description Section
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDescriptionText(),
                        
                        const SizedBox(height: 24),

                        // Map Section
                        const Text(
                          "Lokasi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // OSM Map with real coordinates
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Map
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(lat, lng),
                                    initialZoom: 13.0,
                                    minZoom: 5.0,
                                    maxZoom: 18.0,
                                    // Disable scroll wheel zoom to prevent conflict with page scroll
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all & ~InteractiveFlag.scrollWheelZoom,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.tripid.akomodasi',
                                      maxZoom: 19,
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(lat, lng),
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Zoom Controls (Bottom Right)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Column(
                                  children: [
                                    // Zoom In Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add, color: kPrimaryBlue),
                                        onPressed: () {
                                          final currentZoom = _mapController.camera.zoom;
                                          _mapController.move(
                                            _mapController.camera.center,
                                            currentZoom + 1,
                                          );
                                        },
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Zoom Out Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.remove, color: kPrimaryBlue),
                                        onPressed: () {
                                          final currentZoom = _mapController.camera.zoom;
                                          _mapController.move(
                                            _mapController.camera.center,
                                            currentZoom - 1,
                                          );
                                        },
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Open in Maps Button
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openInMaps(lat, lng),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Buka di Maps'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimaryBlue,
                              side: const BorderSide(color: kPrimaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Photo Gallery Section
                        if (_photoGallery.length > 1) ...[
                          const Text(
                            "Galeri Foto",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _photoGallery.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // TODO: Open fullscreen gallery
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('View photo ${index + 1}'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(_photoGallery[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Reviews Section
                        _buildReviewsSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Activities & Pengalaman Section
                        const Text(
                          "Aktivitas & Pengalaman",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActivitiesSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Destinasi Lain Section
                        const Text(
                          "Destinasi Lain",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRelatedDestinations(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateTripScreen(
                          initialTitle: "Trip ke ${widget.destination.name}",
                          initialImageUrl: widget.destination.imageUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Buat Petualangan!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDescriptionText() {
    final String desc = widget.destination.description.isNotEmpty ? widget.destination.description : "Deskripsi belum tersedia.";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isDescriptionExpanded ? desc : (desc.length > 100 ? "${desc.substring(0, 100)}..." : desc),
          style: const TextStyle(color: Colors.grey, height: 1.5),
        ),
        if (desc.length > 100)
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(_isDescriptionExpanded ? "Lebih sedikit" : "Selengkapnya", style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Ulasan (${_reviews.length})", style: const TextStyle(fontWeight: kFontWeightBold, fontSize: kFontSizeN)),
            
            // LOGIKA TOMBOL HEADER:
            // Jika user belum punya review -> "Tulis Ulasan"
            // Jika user sudah punya review -> "Edit Ulasan Anda"
            GestureDetector(
              onTap: _showReviewModal,
              child: Text(
                _myExistingReview == null ? "Tulis Ulasan" : "Edit Ulasan Anda", 
                style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey))))
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length > 3 ? 3 : _reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
          ),
          if (_reviews.length > 3) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllReviewsScreen(destination: widget.destination),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  "Lihat Semua ${_reviews.length} Ulasan",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(foregroundColor: kPrimaryBlue),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    // Cek apakah ulasan ini milik user yang sedang login
    // Kita bandingkan ID ulasan dengan ID ulasan milik user (yang kita simpan di fetch)
    bool isMine = _myExistingReview != null && review.id == _myExistingReview!.id;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(review.userAvatar),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMine ? "${review.userName} (Anda)" : review.userName, // Penanda visual 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.orange),
                      Text(review.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      
                      // MENU EDIT / DELETE (HANYA MUNCUL JIKA MILIK SENDIRI)
                      if (isMine)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showReviewModal(); // Buka modal dengan data lama
                            } else if (value == 'delete') {
                              _deleteReview(); // Hapus ulasan
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem<String>(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(review.reviewText, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
  
  // Build Activities & Pengalaman Section
  Widget _buildActivitiesSection() {
    final activities = [
      {'name': 'Camping', 'icon': Icons.cabin},
      {'name': 'Pendakian', 'icon': Icons.hiking},
      {'name': 'Blue Fire', 'icon': Icons.whatshot},
    ];
    
    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: kPrimaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                activity['name'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  // Build Related Destinations Section
  Widget _buildRelatedDestinations() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('destinasi')
          .select()
          .neq('id_destinasi', widget.destination.id) // Exclude current destination
          .limit(5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            'Belum ada destinasi lain tersedia',
            style: TextStyle(color: Colors.grey),
          );
        }
        
        final destinations = snapshot.data!
            .map((item) => Destination.fromJson(item))
            .toList();
        
        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to detail screen of the tapped destination
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(destination: dest),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(dest.imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dest.location,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- FORM INPUT REVIEW (MODAL) ---
class _ReviewInputForm extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  final Function(double, String) onSubmit;

  const _ReviewInputForm({
    this.initialRating = 0,
    this.initialComment = '',
    required this.onSubmit,
  });

  @override
  State<_ReviewInputForm> createState() => _ReviewInputFormState();
}

class _ReviewInputFormState extends State<_ReviewInputForm> {
  late TextEditingController _commentController;
  late int _selectedRating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.initialComment);
    _selectedRating = widget.initialRating.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.initialComment.isNotEmpty ? "Edit Pengalamanmu" : "Bagikan Pengalamanmu", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              onPressed: () => setState(() => _selectedRating = index + 1),
              icon: Icon(index < _selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
            )),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(hintText: "Ceritakan pengalamanmu...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[50]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedRating == 0 ? null : () async {
                if (_commentController.text.isEmpty) return;
                setState(() => _isSubmitting = true);
                await widget.onSubmit(_selectedRating.toDouble(), _commentController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
              child: _isSubmitting 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(widget.initialComment.isNotEmpty ? "Update Ulasan" : "Kirim Ulasan", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}