import 'package:flutter/material.dart';
import 'home_screen.dart'; 

// Define TransportOption model used by this screen (add fields used in this file)
class TransportOption {
  final String name;
  final String classType;
  final String departureTime;
  final String origin;
  final String duration;
  final String arrivalTime;
  final String destination;
  final double price;
  final String mode;

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


class TransportSelectionScreen extends StatelessWidget {
  const TransportSelectionScreen({super.key});

  
  // Widget Pembantu untuk Chip Mode Transportasi
  Widget _buildModeChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue[600] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget Pembantu untuk Kartu Opsi Transportasi
  Widget _buildTransportCard(BuildContext context, TransportOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama & Kelas
          Text(
            option.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            option.classType,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          
          // Detail Waktu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Waktu Berangkat
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.departureTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(option.origin, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              
              // Durasi Tengah
              Column(
                children: [
                  Text(option.duration, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const Icon(Icons.arrow_right_alt, color: Colors.grey),
                ],
              ),
              
              // Waktu Tiba
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(option.arrivalTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(option.destination, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Harga
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Rp${option.price.toStringAsFixed(3)}",
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILD UTAMA ---

  @override
  Widget build(BuildContext context) {
    // Contoh data opsi transportasi
    final List<TransportOption> transportOptions = [
      TransportOption(
        name: "Kereta Api Argo Bromo",
        classType: "Eksekutif",
        departureTime: "08:00",
        origin: "Surabaya Gubeng",
        duration: "3j 30m",
        arrivalTime: "11:30",
        destination: "Banyuwangi Baru",
        price: 150000,
        mode: "Kereta",
      ),
      TransportOption(
        name: "Bus Sumber Kencono",
        classType: "AC Eksekutif",
        departureTime: "09:00",
        origin: "Surabaya Terminal Bungurasih",
        duration: "4j 0m",
        arrivalTime: "13:00",
        destination: "Banyuwangi Terminal Karangente",
        price: 120000,
        mode: "Bus",
      ),
      // Tambah opsi lainnya sesuai kebutuhan
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Transportasi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilihan Mode Transportasi
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildModeChip("Semua", true),
                  _buildModeChip("Kereta", false),
                  _buildModeChip("Bus", false),
                  _buildModeChip("Pesawat", false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Daftar Opsi Transportasi
            Expanded(
              child: ListView.builder(
                itemCount: transportOptions.length,
                itemBuilder: (context, index) {
                  return _buildTransportCard(context, transportOptions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 