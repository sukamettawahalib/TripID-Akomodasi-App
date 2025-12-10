import 'package:flutter/material.dart';
import '../../services/trip_service.dart';
import 'create_trip_screen.dart';
import 'itinerary_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  
  void _refreshTrips() {
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

          // KITA GABUNGKAN LOGIKA: List Kosong maupun Ada Isi tetap pakai ListView ini
          // Agar tombol "Tambah" selalu muncul di urutan terakhir
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            // Jumlah item = jumlah trip + 1 (untuk kartu "Tambah Baru")
            itemCount: trips.length + 1, 
            itemBuilder: (context, index) {
              
              // JIKA INI ADALAH ITEM TERAKHIR (Kartu Tambah)
              if (index == trips.length) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const CreateTripScreen())
                    );
                    if (result == true) _refreshTrips();
                  },
                  child: Container(
                    height: 100, // Tinggi lebih kecil sedikit biar estetik atau samakan 150
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5), // Warna outline biru muda
                        width: 2,
                        style: BorderStyle.solid // Bisa ganti .dashed kalau mau putus-putus (butuh package lain)
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.blue[600], size: 28),
                          const SizedBox(width: 8),
                          Text(
                            "Buat Petualangan Baru",
                            style: TextStyle(
                              color: Colors.blue[600], 
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // JIKA INI ADALAH KARTU TRIP BIASA
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
                    color: Colors.grey[200], // Placeholder warna loading
                    image: const DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1596401057633-56565384358a"), 
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