import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan flutter pub add intl sudah dijalankan
import '../../services/trip_service.dart';

class CreateTripScreen extends StatefulWidget {
  final String? initialTitle; // 1. Variabel untuk menerima judul dari luar
  final String? initialImageUrl; // <--- 1. Tambah ini

const CreateTripScreen({super.key, this.initialTitle, this.initialImageUrl});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  // --- CONTROLLERS ---
  // 2. Gunakan 'late' untuk judul karena akan diisi di initState
  late TextEditingController _judulController;
  
  final _berangkatController = TextEditingController();
  final _kembaliController = TextEditingController();
  final _orangController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 3. Isi judul otomatis saat halaman dibuka
    // Jika ada kiriman judul, pakai itu. Jika tidak, kosongkan.
    _judulController = TextEditingController(text: widget.initialTitle ?? "");
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar hemat memori
    _judulController.dispose();
    _berangkatController.dispose();
    _kembaliController.dispose();
    _orangController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  // --- LOGIC: DATE PICKER ---
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B7FCC), // Warna Kalender
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Tampilkan format user-friendly (DD/MM/YYYY)
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- LOGIC: SAVE TRIP ---
  Future<void> _saveTrip() async {
    if (_judulController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul tidak boleh kosong")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Format Input (dari TextField): dd/MM/yyyy (31/12/2025)
      final inputFormat = DateFormat('dd/MM/yyyy');
      // Format Output (ke Database): yyyy-MM-dd (2025-12-31)
      final outputFormat = DateFormat('yyyy-MM-dd');

      // Konversi Tanggal agar Supabase tidak error
      String tglBerangkatSQL = "";
      String tglKembaliSQL = "";

      if (_berangkatController.text.isNotEmpty) {
        tglBerangkatSQL = outputFormat.format(inputFormat.parse(_berangkatController.text));
      }
      if (_kembaliController.text.isNotEmpty) {
        tglKembaliSQL = outputFormat.format(inputFormat.parse(_kembaliController.text));
      }

      await TripService().createTrip(
        judul: _judulController.text,
        tglBerangkat: tglBerangkatSQL,
        tglKembali: tglKembaliSQL,
        jumlahOrang: int.tryParse(_orangController.text) ?? 1,
        budgetMin: double.tryParse(_budgetMinController.text) ?? 0,
        budgetMax: double.tryParse(_budgetMaxController.text) ?? 0,
        imageUrl: widget.initialImageUrl,
      );

      if (mounted) {
        // Berhasil simpan -> Kembali ke halaman sebelumnya
        Navigator.pop(context, true); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            const Text(
              "Rencanakan Petualangan\nyang Tak Terlupakan",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
                height: 1.2,
                fontFamily: 'Poppins', 
              ),
            ),
            const SizedBox(height: 32),

            // --- FORM JUDUL ---
            _buildLabel("Judul petualanganmu"),
            _buildInputField(
              controller: _judulController,
              hint: "Buat nama yang keren",
            ),

            const SizedBox(height: 24),

            // --- FORM TANGGAL (ROW) ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tanggal berangkat"),
                      _buildInputField(
                        controller: _berangkatController,
                        hint: "DD/MM/YYYY",
                        isReadOnly: true,
                        onTap: () => _selectDate(context, _berangkatController),
                        suffixIcon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tanggal kembali"),
                      _buildInputField(
                        controller: _kembaliController,
                        hint: "DD/MM/YYYY",
                        isReadOnly: true,
                        onTap: () => _selectDate(context, _kembaliController),
                        suffixIcon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- FORM JUMLAH ORANG ---
            _buildLabel("Jumlah orang"),
            SizedBox(
              width: 120, 
              child: _buildInputField(
                controller: _orangController,
                hint: "1",
                inputType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // --- FORM BUDGET (ROW) ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Budget minimum"),
                      _buildInputField(
                        controller: _budgetMinController,
                        hint: "Rp 0",
                        inputType: TextInputType.number,
                        prefixText: "Rp ",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Budget maksimum"),
                      _buildInputField(
                        controller: _budgetMaxController,
                        hint: "Rp 0",
                        inputType: TextInputType.number,
                        prefixText: "Rp ",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Rekomendasi 1.000.000 - 2.000.000",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),

            const SizedBox(height: 50),

            // --- BUTTON SUBMIT ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B7FCC), 
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Buat petualangan!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: LABEL TEXT ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600, 
          color: Color(0xFF111111),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: INPUT FIELD CANTIK ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isReadOnly = false,
    VoidCallback? onTap,
    TextInputType inputType = TextInputType.text,
    IconData? suffixIcon,
    String? prefixText,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        keyboardType: inputType,
        textAlign: textAlign,
        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          suffixIcon: suffixIcon != null 
              ? Icon(suffixIcon, color: Colors.grey[400], size: 20) 
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B7FCC), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}