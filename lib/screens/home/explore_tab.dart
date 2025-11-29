import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'detail_screen.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // Space untuk Bottom Nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde"), // Placeholder User
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Naufal Maula", style: TextStyle(fontWeight: kFontWeightBold, fontSize: kFontSizeN)),
                    Text("ID: 3770", style: TextStyle(color: Colors.grey[600], fontSize: kFontSizeXS)),
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                           BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,2))
                        ]
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
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: kCyanLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: kCyanDark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildCategoryChip("Semua", isActive: true),
                _buildCategoryChip("Terdekat"),
                _buildCategoryChip("Populer"),
                _buildCategoryChip("Museum"),
                _buildCategoryChip("Gunung"),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Popular Destinations (Horizontal)
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: popularDestinations.length,
              separatorBuilder: (_,__) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildDestinationCard(context, popularDestinations[index], isHorizontal: true);
              },
            ),
          ),

          const SizedBox(height: 24),
          // Hidden Gems Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text("Hidden Gems", style: TextStyle(fontSize: kFontSizeM, fontWeight: kFontWeightBold)),
          ),
          
          const SizedBox(height: 16),
          // Hidden Gems List (Vertical/Grid-like)
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: hiddenGems.length,
            separatorBuilder: (_,__) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildDestinationCard(context, hiddenGems[index], isHorizontal: false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? kCyanLight : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? kCyanDark : Colors.grey,
          fontWeight: isActive ? kFontWeightBold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, Destination dest, {required bool isHorizontal}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(destination: dest)));
      },
      child: Container(
        width: isHorizontal ? 180 : double.infinity,
        height: isHorizontal ? 220 : 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(dest.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dest.name,
                style: const TextStyle(color: Colors.white, fontWeight: kFontWeightBold, fontSize: kFontSizeN),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dest.location,
                      style: const TextStyle(color: Colors.white70, fontSize: kFontSizeXXS),
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
