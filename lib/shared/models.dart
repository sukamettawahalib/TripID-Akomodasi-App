// lib/shared/models.dart

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

// =========================================
// DATA DUMMY (Sudah dengan Link Gambar Asli)
// =========================================

final List<Destination> popularDestinations = [
  Destination(
    name: "Kawah Bromo",
    location: "Probolinggo, Jawa Timur",
    imageUrl: "https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272", // Foto Bromo
  ),
  Destination(
    name: "Candi Prambanan",
    location: "Yogyakarta",
    imageUrl: "https://images.unsplash.com/photo-1559333086-b0a56225a93c", // Foto Prambanan
  ),
  Destination(
    name: "Kawah Ijen",
    location: "Banyuwangi",
    imageUrl: "https://images.unsplash.com/photo-1536146094120-8d7fcbc4c45b?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // Foto Kawah Ijen (Blue Fire area)
  ),
];

final List<Destination> hiddenGems = [
  Destination(
    name: "Pulau Padar",
    location: "Nusa Tenggara Timur",
    imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb", // Foto Pulau Padar
  ),
  Destination(
    name: "Wae Rebo",
    location: "Nusa Tenggara Timur",
    imageUrl: "https://images.unsplash.com/photo-1621683248332-95f226b91c0e", // Foto Desa Wae Rebo
  ),
  Destination(
    name: "Kawah Wurung",
    location: "Bondowoso, Jawa Timur",
    imageUrl: "https://images.unsplash.com/photo-1705926063259-b3d12c33b3e5?q=80&w=1931&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // Foto Kawah Wurung (Savana)
  ),
];

// Data Tambahan untuk Hasil Pencarian (Biar tidak kosong)
final List<Destination> otherDestinations = [
  Destination(
    name: "Kalibendo",
    location: "Banyuwangi",
    imageUrl: "https://images.unsplash.com/photo-1526494631344-8c6fa6462b17", // Foto Hutan/Perkebunan (Vibe Kalibendo)
  ),
  Destination(
    name: "Pulau Merah",
    location: "Banyuwangi",
    imageUrl: "https://images.unsplash.com/photo-1632832549226-926e2730175d", // Foto Pantai (Vibe Pulau Merah)
  ),
  Destination(
    name: "Baluran",
    location: "Situbondo",
    imageUrl: "https://images.unsplash.com/photo-1604423043492-41303788de80", // Foto Savana Baluran Asli
  ),
];