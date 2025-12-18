import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/constants.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Variabel untuk Gambar Profil
  String? _currentAvatarUrl;
  File? _newAvatarFile;

  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 1. Load Data Awal
  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      final data = await Supabase.instance.client
          .from('pengguna')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? user.email!;
          _currentAvatarUrl = data['foto_profil'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat profil: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi Helper: Pilih Gambar dari Galeri
  Future<void> _pickImage() async {
    try {
      // Pilih gambar dengan kualitas sedikit dikompres agar upload cepat
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 70, 
      );
      
      if (pickedFile != null) {
        setState(() {
          _newAvatarFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengambil gambar")));
    }
  }

  // Fungsi Helper: Upload ke Supabase Storage
  Future<String?> _uploadImage(File imageFile, String folderName) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      // Nama file unik: userID_timestamp.ext
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$folderName/$fileName';

      // 1. Upload Binary ke Bucket 'images'
      await Supabase.instance.client.storage.from('images').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );

      // 2. Ambil Public URL
      return Supabase.instance.client.storage.from('images').getPublicUrl(filePath);
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }

  // 2. Simpan Perubahan (Text + Gambar)
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username tidak boleh kosong")));
      setState(() => _isSaving = false);
      return;
    }

    try {
      String? finalAvatarUrl = _currentAvatarUrl;

      // Upload Avatar Baru (jika ada file lokal dipilih)
      if (_newAvatarFile != null) {
        final url = await _uploadImage(_newAvatarFile!, 'avatars');
        if (url != null) finalAvatarUrl = url;
      }

      // Update Database
      final updates = {
        'username': newUsername,
        'foto_profil': finalAvatarUrl,
      };

      await Supabase.instance.client
          .from('pengguna')
          .update(updates)
          .eq('email', user.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil berhasil diperbarui!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e. Pastikan Bucket 'images' ada.")));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION PROFILE PICTURE ---
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _newAvatarFile != null
                              ? FileImage(_newAvatarFile!) as ImageProvider
                              : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(_currentAvatarUrl!)
                                  : null,
                          child: (_newAvatarFile == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        // Icon Kamera Overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "Ketuk untuk mengganti foto profil",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 30),

                // --- FORM FIELDS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      const Text("Username", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: "Masukkan username",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Email (Read Only)
                      const Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: const Icon(Icons.lock, size: 18, color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- TOMBOL ACTION ---
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Batal", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSaving 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}