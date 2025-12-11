import 'package:flutter/material.dart';
import '../../services/trip_service.dart';
import 'itinerary_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  
  // Fungsi Refresh
  void refreshTrips() {
    setState(() {});
  }

  // Fungsi Hapus dengan Konfirmasi
  Future<void> _deleteTrip(int id) async {
    // Tampilkan Dialog Konfirmasi
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Petualangan?"),
        content: const Text("Yakin ingin menghapus trip ini? Data tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Yakin
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Jika user pilih "Hapus"
    if (confirm == true) {
      await TripService().deleteTrip(id); // Panggil Service Delete
      refreshTrips(); // Refresh tampilan
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip berhasil dihapus"))
        );
      }
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => refreshTrips(),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: TripService().getMyTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final trips = snapshot.data ?? [];

          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Belum ada petualangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Cari destinasi di menu Jelajah\nuntuk mulai membuat trip!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => ItineraryScreen(tripData: trip)
                    )
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                    // GAMBAR DINAMIS (Tanpa const)
                    image: DecorationImage(
                      image: NetworkImage(
                        trip['image_url'] ?? "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80"
                      ), 
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                    ),
                  ),
                  // MENGGUNAKAN STACK UNTUK TOMBOL SAMPAH
                  child: Stack(
                    children: [
                      // KONTEN TEKS (Di Kiri Bawah)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip['judul'] ?? "Tanpa Judul",
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${trip['tanggal_berangkat']} - ${trip['tanggal_kembali']}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // TOMBOL DELETE (Di Kanan Atas)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            // Ambil ID Trip
                            final int tripId = trip['id_petualangan']; 
                            _deleteTrip(tripId);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5), // Latar hitam transparan
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
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