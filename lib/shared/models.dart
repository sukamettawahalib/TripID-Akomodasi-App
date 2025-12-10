// --- MOCK DATA MODEL ---
class Destination {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String description;
  final double rating;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.rating
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: (json['id_destinasi'] ?? json['id'])?.toString() ?? '',
      name: json['nama'] ?? json['name'] ?? 'Unknown',
      location: json['lokasi_kota'] ?? json['location'] ?? '',
      imageUrl: json['gambar_utama'] ?? json['imageUrl'] ?? 'https://via.placeholder.com/150',
      description: json['deskripsi'] ?? json['description'] ?? '',
      rating: (json['rating_rata_rata'] as num?)?.toDouble() ?? 
              (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Helper method to convert back to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'description': description,
    };
  }
}

// --- DATA DUMMY (PENTING: Agar search_screen tidak error) ---
List<Destination> popularDestinations = [
  Destination(
    id: '1',
    name: 'Danau Toba',
    location: 'Sumatera Utara',
    imageUrl: 'https://via.placeholder.com/150',
    description: 'Danau vulkanik terbesar di dunia.',
    rating: 4.8,
  ),
  Destination(
    id: '2',
    name: 'Raja Ampat',
    location: 'Papua Barat',
    imageUrl: 'https://via.placeholder.com/150',
    description: 'Surga penyelam dunia.',
    rating: 5.0,
  ),
  Destination(
    id: '3',
    name: 'Candi Borobudur',
    location: 'Jawa Tengah',
    imageUrl: 'https://via.placeholder.com/150',
    description: 'Candi Buddha terbesar di dunia.',
    rating: 4.7,
  ),
];