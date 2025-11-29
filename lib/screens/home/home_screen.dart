import 'package:flutter/material.dart';
import '../../shared/constants.dart';
import 'explore_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExploreTab(),      // Halaman Jelajahi
    const Center(child: Text("Halaman Petualanganku")), // Placeholder
    const ProfileTab(),      // Halaman Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Konten Utama
          _pages[_selectedIndex],

          // Bottom Navigation Bar Custom (Floating)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kBlack.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.travel_explore, "Jelajahi", 0),
                  _buildNavItem(Icons.map_outlined, "Petualanganku", 1),
                  _buildNavItem(Icons.person_outline, "Profil", 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: kFontSizeXXS,
              fontWeight: isSelected ? kFontWeightBold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
