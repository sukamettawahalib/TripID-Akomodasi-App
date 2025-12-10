import 'package:flutter/material.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';
import '../../shared/destination_info_models.dart';

class DestinationInfoScreen extends StatefulWidget {
  final Destination destination;

  const DestinationInfoScreen({super.key, required this.destination});

  @override
  State<DestinationInfoScreen> createState() => _DestinationInfoScreenState();
}

class _DestinationInfoScreenState extends State<DestinationInfoScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Sample data - dalam production nanti bisa dari API/database
    final List<Review> reviews = [
      Review(
        userName: "Salman",
        userAvatar: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&h=200&fit=crop", // Avatar pria
        reviewText: "Kawah Ijen sangat bagus dan treknya tidak terlalu menantang. Cocok bagi pemula. Pemandangannya juga mulai dari mulai dari pantai dan laut",
      ),
      Review(
        userName: "Ubay",
        userAvatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop", // Avatar pria berkacamata
        reviewText: "Kawah Ijen sangat bagus dan treknya tidak terlalu menantang. Cocok bagi pemula. Pemandangannya juga mulai dari mulai dari pantai dan laut",
      ),
      Review(
        userName: "Hasjibu",
        userAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop", // Avatar pria casual
        reviewText: "Kawah Ijen sangat bagus dan treknya tidak terlalu menantang. Cocok bagi pemula. Pemandangannya juga mulai dari mulai dari pantai dan laut",
      ),
    ];

    final List<Activity> activities = [
      Activity(
        name: "Camping", 
        imageUrl: "https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=400&h=300&fit=crop" // Camping dengan tenda dan api unggun
      ),
      Activity(
        name: "Pendakian", 
        imageUrl: "https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=300&fit=crop" // Hiking trail gunung
      ),
      Activity(
        name: "Blue Fire", 
        imageUrl: "https://images.unsplash.com/photo-1536146094120-8d7fcbc4c45b?w=400&h=300&fit=crop" // Kawah Ijen Blue Fire
      ),
    ];

    // final List<Destination> relatedDestinations = [
    //   Destination(
    //     name: "Air Terjun Tumpak Sewu",
    //     location: "Lumajang, Jawa Timur",
    //     imageUrl: "https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=400&h=300&fit=crop&q=80", // Air terjun indah - Tumpak Sewu style
    //   ),
    //   Destination(
    //     name: "Kawah Wurung",
    //     location: "Bondowoso, Jawa Timur",
    //     imageUrl: "https://images.unsplash.com/photo-1705926063259-b3d12c33b3e5?w=400&h=300&fit=crop", // Savanna landscape
    //   ),
    // ];

    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image dengan Overlay Nama Destinasi
            _buildHeaderImage(),

            // Konten Utama
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deskripsi Section
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),

                  // Map Section
                  _buildMapSection(),
                  const SizedBox(height: 24),

                  // Reviews Section
                  _buildReviewsSection(reviews),
                  const SizedBox(height: 24),

                  // Activities Section
                  _buildActivitiesSection(activities),
                  const SizedBox(height: 24),

                  // // Related Destinations
                  // _buildRelatedDestinations(relatedDestinations),
                  // const SizedBox(height: 24),

                  // CTA Button
                  _buildCTAButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header dengan Gambar dan Nama Destinasi
  Widget _buildHeaderImage() {
    return Stack(
      children: [
        // Background Image
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.destination.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Gradient Overlay
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: kWhite, size: 24),
            ),
          ),
        ),

        // Nama dan Lokasi di bawah
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.destination.name,
                style: const TextStyle(
                  fontSize: kFontSizeXL,
                  fontWeight: kFontWeightBold,
                  color: kWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.destination.location,
                style: TextStyle(
                  fontSize: kFontSizeS,
                  color: kWhite.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Deskripsi dengan Tombol Selengkapnya
  Widget _buildDescriptionSection() {
    const String fullDescription = 
      "Kawah Ijen sangat direkomendasikan untuk dikunjungi karena fenomena Blue Fire yang jarang ditemukan gunung. Dalam lingkar api biru mempesona di dalam kawah dengan danau asam terbesar di dunia yang memiliki luas 154 kilometer persegi. Ikni merupakan gunung berapi tertinggi kelima salah satu gunung berapi paling aktif di Indonesia, dengan ketinggian 2.443 m di atas permukaan laut.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isDescriptionExpanded 
            ? fullDescription 
            : fullDescription.substring(0, fullDescription.length > 150 ? 150 : fullDescription.length) + "...",
          style: const TextStyle(
            fontSize: kFontSizeS,
            color: kBlack,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Text(
            _isDescriptionExpanded ? "Lebih sedikit" : "Selengkapnya",
            style: const TextStyle(
              fontSize: kFontSizeS,
              color: kPrimaryBlue,
              fontWeight: kFontWeightSemiBold,
            ),
          ),
        ),
      ],
    );
  }

  // Map Section (Dummy Image)
  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lokasi",
          style: TextStyle(
            fontSize: kFontSizeN,
            fontWeight: kFontWeightBold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              // Foto map dari Figma (untuk web, diambil dari folder web)
              'map_location.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      "Map Placeholder",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Reviews Section
  Widget _buildReviewsSection(List<Review> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ulasan",
              style: TextStyle(
                fontSize: kFontSizeN,
                fontWeight: kFontWeightBold,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to all reviews
              },
              child: const Text(
                "tulis ulasan",
                style: TextStyle(
                  fontSize: kFontSizeS,
                  color: kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewCard(review);
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: NetworkImage(review.userAvatar),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(width: 12),
        // Review Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontSize: kFontSizeS,
                  fontWeight: kFontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                review.reviewText,
                style: TextStyle(
                  fontSize: kFontSizeXS,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Activities Section
  Widget _buildActivitiesSection(List<Activity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aktivitas & Pengalaman",
          style: TextStyle(
            fontSize: kFontSizeN,
            fontWeight: kFontWeightBold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityCard(activity);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Activity Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                activity.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image,
                  color: Colors.grey[400],
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Activity Name
          Text(
            activity.name,
            style: const TextStyle(
              fontSize: kFontSizeS,
              fontWeight: kFontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Related Destinations
  Widget _buildRelatedDestinations(List<Destination> destinations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Destinasi lain",
          style: TextStyle(
            fontSize: kFontSizeN,
            fontWeight: kFontWeightBold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return _buildRelatedDestinationCard(destination);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedDestinationCard(Destination destination) {
    return GestureDetector(
      onTap: () {
        // Navigate to this destination's info screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DestinationInfoScreen(destination: destination),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                destination.imageUrl,
                width: 160,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Text Overlay
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: kFontSizeS,
                      fontWeight: kFontWeightBold,
                      color: kWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    destination.location,
                    style: TextStyle(
                      fontSize: kFontSizeXS,
                      color: kWhite.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CTA Button
  Widget _buildCTAButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to create adventure/itinerary
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Buat petualangan!",
          style: TextStyle(
            color: kWhite,
            fontSize: kFontSizeN,
            fontWeight: kFontWeightBold,
          ),
        ),
      ),
    );
  }
}
