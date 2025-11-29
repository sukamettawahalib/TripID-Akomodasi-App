import 'package:flutter/material.dart';
import '../../shared/models.dart';
import '../../shared/constants.dart';

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
                        color: kCyanLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: kCyanDark),
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
                child: Text("Hasil utama", style: TextStyle(fontWeight: kFontWeightBold)),
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
                child: Text("Dekat dengan 'Kawah Ijen'", style: TextStyle(fontWeight: kFontWeightBold)),
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
        color: isActive ? kCyanLight : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: isActive ? kCyanDark : Colors.grey)),
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
