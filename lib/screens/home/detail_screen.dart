import 'package:flutter/material.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';

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
                          Text(destination.name, style: const TextStyle(fontSize: kFontSizeL, fontWeight: kFontWeightBold)),
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
                            Text(destination.rating.toString(), style: const TextStyle(fontWeight: kFontWeightBold, color: Colors.orange)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Deskripsi", style: TextStyle(fontWeight: kFontWeightBold, fontSize: kFontSizeN)),
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
                        backgroundColor: kPrimaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Pesan Sekarang", style: TextStyle(color: Colors.white, fontSize: kFontSizeN, fontWeight: kFontWeightBold)),
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
