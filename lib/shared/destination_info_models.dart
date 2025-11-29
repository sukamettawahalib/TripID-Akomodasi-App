// lib/screens/destination/models/destination_info_models.dart

/// Model untuk User Review
class Review {
  final String userName;
  final String userAvatar;
  final String reviewText;
  final double rating;

  Review({
    required this.userName,
    required this.userAvatar,
    required this.reviewText,
    this.rating = 5.0,
  });
}

/// Model untuk Activity/Pengalaman
class Activity {
  final String name;
  final String imageUrl;

  Activity({
    required this.name,
    required this.imageUrl,
  });
}
