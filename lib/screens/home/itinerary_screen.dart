import 'package:flutter/material.dart';
import '../../transportasi_screen.dart'; 


class ItineraryScreen extends StatelessWidget {
  final String tripTitle;
  const ItineraryScreen({super.key, required this.tripTitle});

  
  Widget _buildDayChip(String day, String date, bool isActive) {
    final color = isActive ? Colors.blue[600] : Colors.grey[200];
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          Text(date, style: TextStyle(color: isActive ? Colors.white70 : Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAddDayChip() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Icon(Icons.add, color: Colors.blue),
    );
  }

  // Widget untuk Title Timeline (Transportasi/Akomodasi)
  Widget _buildTimelineItem(BuildContext context, {required String title, required Color iconColor, required VoidCallback onAddTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Timeline
        Column(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            ),
            Container(
              width: 2, height: 60,
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Konten
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Card Aksi
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[200]!, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: onAddTap, // Navigasi ke TransportSelectionScreen
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.add, color: Colors.blue[600]),
                          const SizedBox(height: 4),
                          Text(
                            title == "Transportasi" ? "Mau naik apa?" : "Mau nginep dimana?", 
                            style: TextStyle(color: Colors.blue[600])
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Placeholder Kosong
  Widget _buildEmptyItemCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 26, top: 10),
      child: Row(
        children: [
          Container(
            width: 2, height: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text("Hapus Item", style: TextStyle(color: Colors.grey))),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILD UTAMA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tripTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit Button (Pensil)
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Day Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildDayChip("Day 1", "8 Nov 2022", true),
                  _buildDayChip("Day 2", "9 Nov 2022", false),
                  _buildDayChip("Day 3", "10 Nov 2022", false),
                  _buildAddDayChip(),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Timeline Konten
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Transportasi ---
                  _buildTimelineItem(
                    context,
                    title: "Transportasi",
                    iconColor: Colors.blue,
                    onAddTap: () {
                      // NAVIGASI KE SCREEN TRANSPORT SELECTION
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportSelectionScreen()));
                    },
                  ),
                  const SizedBox(height: 20),
                  // Placeholder Item Kosong (Garis Putus-putus)
                  _buildEmptyItemCard(),
                  const SizedBox(height: 40),

                  // --- Akomodasi ---
                  _buildTimelineItem(
                    context,
                    title: "Akomodasi",
                    iconColor: Colors.blue,
                    onAddTap: () {}, // Aksi akan ditambahkan nanti
                  ),
                  // Placeholder Item Kosong
                  _buildEmptyItemCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            const SizedBox(height: 100), // Ruang bawah untuk Bottom Nav Bar
          ],
        ),
      ),
    );
  }
}