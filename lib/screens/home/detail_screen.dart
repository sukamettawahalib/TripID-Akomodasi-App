import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models.dart';
import '../../shared/destination_info_models.dart';
import '../../shared/constants.dart';
import 'create_trip_screen.dart';

class DetailScreen extends StatefulWidget {
  final Destination destination;

  const DetailScreen({super.key, required this.destination});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDescriptionExpanded = false;
  
  // State Data
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  
  // State User & Ulasan Pribadi
  int? _myDbId; // ID Integer user yang sedang login
  Review? _myExistingReview; // Objek ulasan milik user sendiri (jika ada)

  @override
  void initState() {
    super.initState();
    _initPageData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              widget.destination.imageUrl, 
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => Container(color: Colors.grey[300]),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50, left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),
          ),

          // Detail Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.destination.name, style: const TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(child: Text(widget.destination.location, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(widget.destination.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: kFontWeightBold, color: Colors.orange)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Deskripsi", style: TextStyle(fontWeight: kFontWeightBold, fontSize: kFontSizeN)),
                          const SizedBox(height: 8),
                          _buildDescriptionText(),
                          const SizedBox(height: 24),
                          _buildReviewsSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Button Create Trip
                  Container(
                    width: double.infinity,
                    height: 55,
                    margin: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTripScreen(initialTitle: "Trip ke ${widget.destination.name}", initialImageUrl: widget.destination.imageUrl)));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("Buat Petualangan!", style: TextStyle(color: Colors.white, fontSize: kFontSizeN, fontWeight: kFontWeightBold)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
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
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length > 3 ? 3 : _reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
          ),
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