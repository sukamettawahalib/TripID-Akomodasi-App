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
