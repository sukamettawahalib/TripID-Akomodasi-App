import 'package:flutter/material.dart';
import '../../services/trip_service.dart';
import 'itinerary_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  
  // Fungsi untuk refresh data (bisa dipanggil dari luar jika perlu)
  void refreshTrips() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Petualanganku", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Otomatis refresh saat halaman dibuka
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: TripService().getMyTrips(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final trips = snapshot.data ?? [];

          // 3. Kosong (Tampilkan pesan suruh jelajah)
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada petualangan", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Cari destinasi di menu Jelajah\nuntuk mulai membuat trip!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 4. Ada Data (Tampilkan List Saja)
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: trips.length, // Tidak perlu +1 lagi
            itemBuilder: (context, index) {
              final trip = trips[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => ItineraryScreen(tripTitle: trip['judul'])
                    )
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                    image: const DecorationImage(
                      // Placeholder gambar (nanti bisa diambil dari destinasi)
                      image: NetworkImage("https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80"), 
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          trip['judul'] ?? "Tanpa Judul",
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          "${trip['tanggal_berangkat']} - ${trip['tanggal_kembali']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}