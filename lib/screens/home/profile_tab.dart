import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                    image: NetworkImage("https://images.unsplash.com/photo-1436491865332-7a61a109cc05"), // Airplane wing sunset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Profile Picture
              Positioned(
                bottom: -40,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black,
                    backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde"), // Placeholder
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
                const Text(
                  "Naufal Maula",
                  style: TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text("Edit profil", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Total trip", "36"),
                _buildStatCard("Jarak ditempuh", "965"),
                _buildStatCard("Jam terbang", "342"),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 4. Friends (Teman)
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

          // 5. Ongoing Trip
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
                  "https://images.unsplash.com/photo-1596401057633-56565384358a", // Kawah Ijen
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 6. Histori
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
                  "https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272", // Bromo
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
