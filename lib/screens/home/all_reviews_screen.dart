import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models.dart';
import '../../shared/destination_info_models.dart';
import '../../shared/constants.dart';

class AllReviewsScreen extends StatefulWidget {
  final Destination destination;

  const AllReviewsScreen({super.key, required this.destination});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  int? _myDbId;
  Review? _myExistingReview;

  @override
  void initState() {
    super.initState();
    _initPageData();
  }

  Future<void> _initPageData() async {
    await _getCurrentUserDbId();
    await _fetchReviews();
  }

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

  Future<void> _fetchReviews() async {
    try {
      final response = await Supabase.instance.client
          .from('ulasan')
          .select('*, pengguna(*)')
          .eq('id_destinasi', widget.destination.id)
          .order('tanggal_ulasan', ascending: false);

      final List<dynamic> rawList = response as List;
      Review? foundMyReview;

      final List<Review> fetchedReviews = rawList.map((json) {
        final review = Review.fromJson(json);
        if (_myDbId != null && json['id_pengguna'] == _myDbId) {
          foundMyReview = review;
        }
        return review;
      }).toList();

      if (mounted) {
        setState(() {
          _reviews = fetchedReviews;
          _myExistingReview = foundMyReview;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview(double rating, String comment) async {
    if (_myDbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengidentifikasi user. Coba login ulang."))
      );
      return;
    }

    try {
      if (_myExistingReview != null) {
        // Update existing review
        final response = await Supabase.instance.client
            .from('ulasan')
            .update({
              'komentar': comment,
              'rating': rating,
              'tanggal_ulasan': DateTime.now().toIso8601String(),
            })
            .eq('id_ulasan', _myExistingReview!.id!)
            .select();

        debugPrint("Update response: $response");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ulasan berhasil diperbarui!"))
          );
        }
      } else {
        // Insert new review
        final response = await Supabase.instance.client
            .from('ulasan')
            .insert({
              'id_destinasi': int.parse(widget.destination.id),
              'id_pengguna': _myDbId,
              'komentar': comment,
              'rating': rating,
              'tanggal_ulasan': DateTime.now().toIso8601String(),
            })
            .select();

        debugPrint("Insert response: $response");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ulasan berhasil dikirim!"))
          );
        }
      }

      // Refresh reviews list
      await _fetchReviews();
    } catch (e) {
      debugPrint("Error submitting: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}"))
        );
      }
    }
  }

  Future<void> _deleteReview() async {
    if (_myExistingReview == null || _myExistingReview!.id == null) return;

    try {
      await Supabase.instance.client
          .from('ulasan')
          .delete()
          .eq('id_ulasan', _myExistingReview!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ulasan dihapus."))
        );
        setState(() {
          _myExistingReview = null;
        });
        _fetchReviews();
      }
    } catch (e) {
      debugPrint("Error deleting: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus ulasan."))
        );
      }
    }
  }

  void _showReviewModal() {
    if (_myDbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu."))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => _ReviewInputForm(
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ulasan ${widget.destination.name}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showReviewModal,
            icon: const Icon(Icons.edit, size: 18),
            label: Text(
              _myExistingReview == null ? "Tulis" : "Edit",
              style: const TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(foregroundColor: kPrimaryBlue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingReviews
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.reviews_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada ulasan",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showReviewModal,
                        child: const Text("Jadilah yang pertama mengulas!"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchReviews,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _reviews.length,
                    separatorBuilder: (_, __) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      final isMine = _myExistingReview != null &&
                          review.id == _myExistingReview!.id;

                      return _buildReviewCard(review, isMine);
                    },
                  ),
                ),
    );
  }

  Widget _buildReviewCard(Review review, bool isMine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
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
                  Expanded(
                    child: Text(
                      isMine ? "${review.userName} (Anda)" : review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isMine)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showReviewModal();
                            } else if (value == 'delete') {
                              _deleteReview();
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                review.reviewText,
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Review Input Form Modal
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialComment.isNotEmpty ? "Edit Pengalamanmu" : "Bagikan Pengalamanmu",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _selectedRating = index + 1),
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Ceritakan pengalamanmu...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedRating == 0
                  ? null
                  : () async {
                      if (_commentController.text.isEmpty) return;
                      setState(() => _isSubmitting = true);
                      await widget.onSubmit(_selectedRating.toDouble(), _commentController.text);
                    },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.initialComment.isNotEmpty ? "Update Ulasan" : "Kirim Ulasan",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
