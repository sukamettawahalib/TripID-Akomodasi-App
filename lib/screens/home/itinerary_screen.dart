import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/itinerary_service.dart';

class ItineraryScreen extends StatefulWidget {
  final Map<String, dynamic> tripData; 

  const ItineraryScreen({super.key, required this.tripData});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDayIndex = 0; 
  final List<DateTime> _days = []; 
  
  // Note storage for each day
  final Map<int, List<Map<String, dynamic>>> _activityNotesPerDay = {};
  final Map<int, List<Map<String, dynamic>>> _transportNotesPerDay = {};
  
  // Service
  final _itineraryService = ItineraryService();
  bool _isLoadingNotes = false;

  @override
  void initState() {
    super.initState();
    _generateDays();
    _loadNotesFromDatabase();
  }
  
  Future<void> _loadNotesFromDatabase() async {
    setState(() => _isLoadingNotes = true);
    
    try {
      final tripId = widget.tripData['id_petualangan'] as int?;
      if (tripId == null) return;
      
      final organizedNotes = await _itineraryService.loadNotesForTrip(tripId);
      
      setState(() {
        organizedNotes.forEach((dayIndex, notesByType) {
          _activityNotesPerDay[dayIndex] = notesByType['aktivitas'] ?? [];
          _transportNotesPerDay[dayIndex] = notesByType['transportasi'] ?? [];
        });
      });
    } catch (e) {
      print('Error loading notes: $e');
    } finally {
      setState(() => _isLoadingNotes = false);
    }
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

                      // Aktivitas Section
                      _buildTimelineItem(
                        context,
                        title: "Aktivitas",
                        iconColor: Colors.blue,
                        content: const SizedBox(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Activity Notes Section
                      _buildNotesSection(
                        "Catatan Aktivitas",
                        _activityNotesPerDay[_selectedDayIndex] ?? [],
                        (note) async {
                          final tripId = widget.tripData['id_petualangan'] as int?;
                          if (tripId == null) return;
                          
                          final savedNote = await _itineraryService.saveNote(
                            idPetualangan: tripId,
                            hariKe: _selectedDayIndex,
                            tipeCatatan: 'aktivitas',
                            waktu: note['time'],
                            konten: note['content']!,
                          );
                          
                          if (savedNote != null) {
                            setState(() {
                              if (!_activityNotesPerDay.containsKey(_selectedDayIndex)) {
                                _activityNotesPerDay[_selectedDayIndex] = [];
                              }
                              _activityNotesPerDay[_selectedDayIndex]!.add({
                                'id': savedNote['id_catatan'],
                                'time': savedNote['waktu'] ?? '',
                                'content': savedNote['konten'],
                              });
                            });
                          }
                        },
                        (index) async {
                          final note = _activityNotesPerDay[_selectedDayIndex]?[index];
                          if (note != null && note['id'] != null) {
                            final success = await _itineraryService.deleteNote(note['id']);
                            if (success) {
                              setState(() {
                                _activityNotesPerDay[_selectedDayIndex]?.removeAt(index);
                              });
                            }
                          }
                        },
                      ),
                      
                      const SizedBox(height: 40),

                      // Transportasi
                      _buildTimelineItem(
                        context,
                        title: "Transportasi",
                        iconColor: Colors.blue,
                        content: const SizedBox(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Transport Notes Section
                      _buildNotesSection(
                        "Catatan Transportasi",
                        _transportNotesPerDay[_selectedDayIndex] ?? [],
                        (note) async {
                          final tripId = widget.tripData['id_petualangan'] as int?;
                          if (tripId == null) return;
                          
                          final savedNote = await _itineraryService.saveNote(
                            idPetualangan: tripId,
                            hariKe: _selectedDayIndex,
                            tipeCatatan: 'transportasi',
                            waktu: note['time'],
                            konten: note['content']!,
                          );
                          
                          if (savedNote != null) {
                            setState(() {
                              if (!_transportNotesPerDay.containsKey(_selectedDayIndex)) {
                                _transportNotesPerDay[_selectedDayIndex] = [];
                              }
                              _transportNotesPerDay[_selectedDayIndex]!.add({
                                'id': savedNote['id_catatan'],
                                'time': savedNote['waktu'] ?? '',
                                'content': savedNote['konten'],
                              });
                            });
                          }
                        },
                        (index) async {
                          final note = _transportNotesPerDay[_selectedDayIndex]?[index];
                          if (note != null && note['id'] != null) {
                            final success = await _itineraryService.deleteNote(note['id']);
                            if (success) {
                              setState(() {
                                _transportNotesPerDay[_selectedDayIndex]?.removeAt(index);
                              });
                            }
                          }
                        },
                      ),
                      
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
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

  // Note-taking section widget
  Widget _buildNotesSection(
    String title,
    List<Map<String, dynamic>> notes,
    Future<void> Function(Map<String, String>) onAddNote,
    Future<void> Function(int) onDeleteNote,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display existing notes
          ...notes.asMap().entries.map((entry) {
            final index = entry.key;
            final note = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note['time'] != null && note['time']!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                note['time']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        if (note['time'] != null && note['time']!.isNotEmpty)
                          const SizedBox(height: 6),
                        Text(
                          note['content']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onDeleteNote(index),
                  ),
                ],
              ),
            );
          }),
          
          // Add note button
          InkWell(
            onTap: () => _showAddNoteDialog(title, onAddNote),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF80DEEA), width: 2, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color(0xFF0097A7), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Buat catatan",
                    style: TextStyle(color: Color(0xFF0097A7), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog to add note
  void _showAddNoteDialog(String title, Function(Map<String, String>) onAddNote) {
    final timeController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Waktu (opsional)',
                  hintText: '09:00',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tulis catatan di sini...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.trim().isNotEmpty) {
                onAddNote({
                  'time': timeController.text.trim(),
                  'content': contentController.text.trim(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}