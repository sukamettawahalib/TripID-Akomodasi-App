import 'package:flutter/material.dart';

// --- MODEL DATA TRANSPORTASI ---
class TransportOption {
  final String name;
  final String classType;
  final String departureTime;
  final String origin;
  final String duration;
  final String arrivalTime;
  final String destination;
  final double price;
  final String mode; // 'Kereta', 'Bus', 'Pesawat'

  TransportOption({
    required this.name,
    required this.classType,
    required this.departureTime,
    required this.origin,
    required this.duration,
    required this.arrivalTime,
    required this.destination,
    required this.price,
    required this.mode,
  });
}

class TransportSelectionScreen extends StatefulWidget {
  const TransportSelectionScreen({super.key});

  @override
  State<TransportSelectionScreen> createState() => _TransportSelectionScreenState();
}

class _TransportSelectionScreenState extends State<TransportSelectionScreen> {
  // 1. STATE UNTUK FILTER AKTIF
  String _selectedFilter = 'Semua';

  // 2. DATA DUMMY (Nanti bisa diganti API real)
  final List<TransportOption> _allOptions = [
    TransportOption(
      name: "Argo Bromo Anggrek",
      classType: "Eksekutif",
      departureTime: "08:00",
      origin: "Surabaya (SGU)",
      duration: "4j 0m",
      arrivalTime: "12:00",
      destination: "Banyuwangi (BW)",
      price: 150000,
      mode: "Kereta",
    ),
    TransportOption(
      name: "Sancaka Utara",
      classType: "Bisnis",
      departureTime: "14:00",
      origin: "Surabaya (SGU)",
      duration: "4j 30m",
      arrivalTime: "18:30",
      destination: "Banyuwangi (BW)",
      price: 120000,
      mode: "Kereta",
    ),
    TransportOption(
      name: "PO Haryanto",
      classType: "VIP Class",
      departureTime: "19:00",
      origin: "Terminal Bungurasih",
      duration: "6j 0m",
      arrivalTime: "01:00",
      destination: "Terminal Brawijaya",
      price: 250000,
      mode: "Bus",
    ),
    TransportOption(
      name: "Wings Air",
      classType: "Ekonomi",
      departureTime: "10:00",
      origin: "Juanda (SUB)",
      duration: "50m",
      arrivalTime: "10:50",
      destination: "Blimbingsari (BWX)",
      price: 850000,
      mode: "Pesawat",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 3. LOGIKA FILTERING
    final filteredList = _selectedFilter == 'Semua'
        ? _allOptions
        : _allOptions.where((opt) => opt.mode == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Transportasi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BAGIAN FILTER CHIPS ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildModeChip("Semua"),
                _buildModeChip("Kereta"),
                _buildModeChip("Bus"),
                _buildModeChip("Pesawat"),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // --- LIST DATA ---
          Expanded(
            child: filteredList.isEmpty 
              ? const Center(child: Text("Tidak ada transportasi tersedia"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return _buildTransportCard(filteredList[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  // Widget Chip yang Bisa Diklik
  Widget _buildModeChip(String label) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D79C7) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Widget Kartu Transportasi (Interactive)
  Widget _buildTransportCard(TransportOption option) {
    return GestureDetector(
      onTap: () {
        // --- INTEGRASI PENTING ---
        // Saat diklik, kita kembalikan data 'option' ke halaman sebelumnya (ItineraryScreen)
        Navigator.pop(context, option);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama & Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(option.classType, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  "Rp${option.price.toStringAsFixed(0)}",
                  style: const TextStyle(color: Color(0xFF2D79C7), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Body: Waktu & Rute
            Row(
              children: [
                // Berangkat
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.departureTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(option.origin, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                
                // Durasi (Garis tengah)
                Expanded(
                  child: Column(
                    children: [
                      Text(option.duration, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                      const Divider(color: Colors.grey, thickness: 1, indent: 10, endIndent: 10),
                      Icon(
                        option.mode == "Pesawat" ? Icons.flight_takeoff : Icons.directions_bus, 
                        size: 16, color: Colors.grey[400]
                      ),
                    ],
                  ),
                ),

                // Tiba
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(option.arrivalTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(option.destination, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}