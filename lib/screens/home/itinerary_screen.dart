import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../transportasi_screen.dart'; 
import 'accommodation_selection_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final Map<String, dynamic> tripData; 

  const ItineraryScreen({super.key, required this.tripData});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDayIndex = 0; 
  List<DateTime> _days = []; 
  
  final Map<int, TransportOption> _transportPerDay = {};
  final Map<int, AccommodationOption> _accommodationPerDay = {};

  @override
  void initState() {
    super.initState();
    _generateDays();
  }

  void _generateDays() {
    try {
      final startStr = widget.tripData['tanggal_berangkat'];
      final endStr = widget.tripData['tanggal_kembali'];

      if (startStr != null && endStr != null) {
        final startDate = DateTime.parse(startStr);
        final endDate = DateTime.parse(endStr);
        int daysCount = endDate.difference(startDate).inDays + 1;
        if (daysCount <= 0) daysCount = 1;

        for (int i = 0; i < daysCount; i++) {
          _days.add(startDate.add(Duration(days: i)));
        }
      } else {
        _days.add(DateTime.now());
      }
    } catch (e) {
      _days.add(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tripTitle = widget.tripData['judul'] ?? "Trip Tanpa Judul";

    // Ambil Data State untuk Hari yang Dipilih
    final currentTransport = _transportPerDay[_selectedDayIndex];
    final currentAccommodation = _accommodationPerDay[_selectedDayIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tripTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _days.isEmpty 
        ? const Center(child: Text("Data tanggal tidak valid"))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. INFO CARD (DATA YANG DIINPUT SAAT BUAT TRIP) ---
                _buildTripInfoCard(), 

                const SizedBox(height: 20),
                
                // --- 2. DAY TABS ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(_days.length, (index) {
                      final date = _days[index];
                      final dateStr = DateFormat("d MMM").format(date);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: _buildDayChip("Day ${index + 1}", dateStr, _selectedDayIndex == index),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- 3. TIMELINE KONTEN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rencana Hari ke-${_selectedDayIndex + 1}", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // Transportasi
                      _buildTimelineItem(
                        context,
                        title: "Transportasi",
                        iconColor: Colors.blue,
                        content: currentTransport != null 
                          ? _buildTransportCard(currentTransport)
                          : _buildAddButton("Transportasi", () async { 
                              final result = await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => const TransportSelectionScreen())
                              );
                              if (result != null && result is TransportOption) {
                                setState(() {
                                  _transportPerDay[_selectedDayIndex] = result; 
                                });
                              }
                            }),
                      ),
                      const SizedBox(height: 20),
                      _buildEmptyItemCard(),
                      const SizedBox(height: 40),

                      // Akomodasi
                      _buildTimelineItem(
                        context,
                        title: "Akomodasi",
                        iconColor: Colors.orange, 
                        content: currentAccommodation != null
                          ? _buildAccommodationCard(currentAccommodation) 
                          : _buildAddButton("Akomodasi", () async { 
                              final result = await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => const AccommodationSelectionScreen())
                              );
                              if (result != null && result is AccommodationOption) {
                                setState(() {
                                  _accommodationPerDay[_selectedDayIndex] = result;
                                });
                              }
                            }),
                      ),
                      _buildEmptyItemCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }

  // --- WIDGET BARU: MENAMPILKAN DATA INPUTAN ---
  Widget _buildTripInfoCard() {
    // Format Uang Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Ambil Data dari tripData (Supabase)
    final int pax = widget.tripData['jumlah_orang'] ?? 1;
    final double budgetMin = (widget.tripData['budget_min'] ?? 0).toDouble();
    final double budgetMax = (widget.tripData['budget_max'] ?? 0).toDouble();
    
    // Format Tanggal Cantik (12 Des 2025)
    String dateRange = "-";
    try {
      if (_days.isNotEmpty) {
        final start = DateFormat("d MMM yyyy").format(_days.first);
        final end = DateFormat("d MMM yyyy").format(_days.last);
        dateRange = "$start - $end";
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Abu-abu sangat muda
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Baris 1: Tanggal & Peserta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(dateRange, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text("$pax Orang", style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          // Baris 2: Budget
          Row(
            children: [
              const Icon(Icons.wallet, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Budget: ${currencyFormat.format(budgetMin)} - ${currencyFormat.format(budgetMax)}",
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER LAINNYA ---

  Widget _buildDayChip(String day, String date, bool isActive) {
    final color = isActive ? const Color(0xFF2D79C7) : Colors.grey[200];
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          Text(date, style: TextStyle(color: isActive ? Colors.white70 : Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, {required String title, required Color iconColor, required Widget content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
          Container(width: 2, height: 120, color: Colors.grey[300]),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              content, 
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(String type, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.add, color: Colors.blue[700]), 
            Text(type == "Transportasi" ? "Mau naik apa?" : "Mau nginep dimana?", style: TextStyle(color: Colors.blue[700]))
          ],
        ),
      ),
    );
  }

  Widget _buildTransportCard(TransportOption data) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D79C7), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 20), 
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(data.departureTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_right_alt, color: Colors.grey)),
                  Text(data.arrivalTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Text("${data.origin} → ${data.destination}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.classType, style: const TextStyle(color: Colors.grey)),
                  Text("Rp${data.price.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFF2D79C7), fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        Positioned(
          top: 0, right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => setState(() => _transportPerDay.remove(_selectedDayIndex)),
          ),
        )
      ],
    );
  }

  Widget _buildAccommodationCard(AccommodationOption data) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12), 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 1.5), 
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(data.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(" ${data.rating}", style: const TextStyle(fontSize: 12))]),
                    Text("Rp${data.pricePerNight.toStringAsFixed(0)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -5, right: -5,
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => setState(() => _accommodationPerDay.remove(_selectedDayIndex)),
          ),
        )
      ],
    );
  }

  Widget _buildEmptyItemCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Container(
        height: 50,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text("-", style: TextStyle(color: Colors.grey))),
      ),
    );
  }
}