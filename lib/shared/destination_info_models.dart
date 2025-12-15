class Review {
  final String? id;
  final String userName;
  final String userAvatar;
  final String reviewText;
  final double rating;
  final DateTime date;

  Review({
    this.id,
    required this.userName,
    required this.userAvatar,
    required this.reviewText,
    required this.rating,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // --- LOGIKA JOIN HANDLING ---
    // Karena kita pakai .select('*, pengguna(*)'), data user ada di dalam objek 'pengguna'
    String nama = 'Pengunjung';
    String avatar = 'https://ui-avatars.com/api/?name=Pengunjung&background=random';

    // Cek apakah ada data join 'pengguna'
    if (json['pengguna'] != null && json['pengguna'] is Map) {
      nama = json['pengguna']['username'] ?? nama;
      // Jika foto_profil null/kosong, pakai avatar default
      if (json['pengguna']['foto_profil'] != null && json['pengguna']['foto_profil'].toString().isNotEmpty) {
        avatar = json['pengguna']['foto_profil'];
      }
    } 
    // Fallback jika pakai kolom flat (opsional)
    else if (json['nama_user'] != null) {
      nama = json['nama_user'];
    }

    return Review(
      id: json['id_ulasan']?.toString(),
      userName: nama,
      userAvatar: avatar,
      reviewText: json['komentar'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      date: json['tanggal_ulasan'] != null 
          ? DateTime.parse(json['tanggal_ulasan']) 
          : DateTime.now(),
    );
  }
}
