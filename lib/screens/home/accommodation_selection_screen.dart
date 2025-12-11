import 'package:flutter/material.dart';

// --- MODEL DATA AKOMODASI ---
class AccommodationOption {
  final String name;
  final String type; // Hotel, Villa, Guest House
  final String location;
  final double rating;
  final double pricePerNight;
  final String imageUrl;

  AccommodationOption({
    required this.name,
    required this.type,
    required this.location,
    required this.rating,
    required this.pricePerNight,
    required this.imageUrl,
  });
}

class AccommodationSelectionScreen extends StatefulWidget {
  const AccommodationSelectionScreen({super.key});

  @override
  State<AccommodationSelectionScreen> createState() => _AccommodationSelectionScreenState();
}

class _AccommodationSelectionScreenState extends State<AccommodationSelectionScreen> {
  String _selectedFilter = 'Semua';

  // DATA DUMMY HOTEL (Bisa diganti data asli nanti)
  final List<AccommodationOption> _allOptions = [
    AccommodationOption(
      name: "Ketapang Indah Hotel",
      type: "Hotel",
      location: "Jl. Gatot Subroto, Banyuwangi",
      rating: 4.5,
      pricePerNight: 450000,
      imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
    ),
    AccommodationOption(
      name: "Dialoog Banyuwangi",
      type: "Hotel",
      location: "Klatak, Kalipuro",
      rating: 4.8,
      pricePerNight: 1200000,
      imageUrl: "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80",
    ),
    AccommodationOption(
      name: "Villa Solong",
      type: "Villa",
      location: "Pantai Solong",
      rating: 4.6,
      pricePerNight: 850000,
      imageUrl: "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80",
    ),
    AccommodationOption(
      name: "Ijen Resort & Villas",
      type: "Villa",
      location: "Randu Agung, Licin",
      rating: 4.7,
      pricePerNight: 1500000,
      imageUrl: "https://images.unsplash.com/photo-1571896349842-6e5a513e610a?auto=format&fit=crop&w=800&q=80",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter Logic
    final filteredList = _selectedFilter == 'Semua'
        ? _allOptions
        : _allOptions.where((opt) => opt.type == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Akomodasi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip("Semua"),
                _buildFilterChip("Hotel"),
                _buildFilterChip("Villa"),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Hotel
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildHotelCard(filteredList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D79C7) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(AccommodationOption hotel) {
    return GestureDetector(
      onTap: () {
        // KEMBALIKAN DATA SAAT DIKLIK
        Navigator.pop(context, hotel);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Hotel
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                hotel.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hotel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(hotel.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(hotel.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                        child: Text(hotel.type, style: TextStyle(color: Colors.blue[800], fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        "Rp${hotel.pricePerNight.toStringAsFixed(0)}/malam",
                        style: const TextStyle(color: Color(0xFF2D79C7), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}