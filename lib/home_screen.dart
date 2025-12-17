import 'package:flutter/material.dart';
import 'screens/home/my_trips_screen.dart';

// --- MOCK DATA MODEL ---
class Destination {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String description;

  Destination({
    required this.name,
    required this.location,
    required this.imageUrl,
    this.rating = 4.8,
    this.description = "Destinasi wisata alam yang menakjubkan dengan pemandangan yang memanjakan mata. Cocok untuk petualangan dan relaksasi.",
  });
}

// Data Dummy
final List<Destination> popularDestinations = [
  Destination(name: "Kawah Bromo", location: "Probolinggo, Jawa Timur", imageUrl: "https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272"),
  Destination(name: "Candi Prambanan", location: "Yogyakarta", imageUrl: "https://images.unsplash.com/photo-1559333086-b0a56225a93c"),
  Destination(name: "Kawah Ijen", location: "Banyuwangi", imageUrl: "https://images.unsplash.com/photo-1596401057633-56565384358a"),
];

final List<Destination> hiddenGems = [
  Destination(name: "Pulau Padar", location: "Nusa Tenggara Timur", imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb"),
  Destination(name: "Wae Rebo", location: "Nusa Tenggara Timur", imageUrl: "https://images.unsplash.com/photo-1621683248332-95f226b91c0e"),
  Destination(name: "Kawah Wurung", location: "Bondowoso, Jawa Timur", imageUrl: "https://images.unsplash.com/photo-1626252329307-e4359059b02a"),
];

// ==========================================
// MAIN HOME SCREEN (Berisi Bottom Nav)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExploreTab(),      // Halaman Jelajahi
    const MyTripsScreen(),
    const ProfileTab(),      // Halaman Profil 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Konten Utama
          _pages[_selectedIndex],

          // Bottom Navigation Bar Custom (Floating)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.travel_explore, "Jelajahi", 0),
                  _buildNavItem(Icons.map_outlined, "Petualanganku", 1),
                  _buildNavItem(Icons.person_outline, "Profil", 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// TAB JELAJAHI (Explore)
// ==========================================
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
                    const Text("Naufal Maula", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("ID: 3770", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
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
                    color: const Color(0xFFA5F3FC), // Cyan muda icon filter
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: Color(0xFF0E7490)),
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
            child: Text("Hidden Gems", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        color: isActive ? const Color(0xFFA5F3FC) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF0E7490) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dest.location,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
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

// ==========================================
// TAB PROFIL (Profile) - NEW
// ==========================================
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                const Text("Teman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                const Text("Ongoing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                const Text("Histori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SEARCH SCREEN (Fitur Pencarian)
// ==========================================
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true, // Langsung fokus keyboard
                        decoration: InputDecoration(
                          hintText: "Cari destinasi...",
                          prefixIcon: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 50, width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5F3FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: Color(0xFF0E7490)),
                    ),
                  ],
                ),
              ),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _chip("Semua", true),
                    _chip("Terdekat", false),
                    _chip("Populer", false),
                    _chip("Relevan", false),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              // Hasil Utama
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Hasil utama", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _resultCard(popularDestinations[2]), // Kawah Ijen
              ),

              const SizedBox(height: 24),
              // Dekat Dengan
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Dekat dengan 'Kawah Ijen'", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _resultSquareCard("Kalibendo", "Banyuwangi", "https://images.unsplash.com/photo-1544990967-84df2a472a5b"),
                    const SizedBox(width: 12),
                    _resultSquareCard("Kawah Wurung", "Bondowoso", "https://images.unsplash.com/photo-1626252329307-e4359059b02a"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFA5F3FC) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: isActive ? const Color(0xFF0E7490) : Colors.grey)),
    );
  }

  Widget _resultCard(Destination dest) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(dest.imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Colors.transparent, Colors.black54], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dest.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(dest.location, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _resultSquareCard(String title, String loc, String url) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(12),
           gradient: const LinearGradient(colors: [Colors.transparent, Colors.black54], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(loc, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DETAIL SCREEN (Info Detail Destinasi)
// ==========================================
class DetailScreen extends StatelessWidget {
  final Destination destination;

  const DetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar Full Screen
          Positioned.fill(
            child: Image.network(destination.imageUrl, fit: BoxFit.cover),
          ),
          
          // Tombol Back di atas
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

          // Detail Card di Bawah (Draggable sheet look)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(destination.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(destination.location, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(destination.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const Spacer(),
                  // Button Booking
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D79C7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Pesan Sekarang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
}