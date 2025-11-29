import 'package:flutter/material.dart';
import 'package:tekber_tripid/shared/constants.dart';
import 'screens/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';




void main() async {
  await Supabase.initialize(
    url: 'https://vtjubyiuuhwzqkegojzs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0anVieWl1dWh3enFrZWdvanpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzODY2NTEsImV4cCI6MjA3OTk2MjY1MX0.cMmUGLNszAoqWmk3yhzwCdMIAeL5rZce5FHyQvTY0fc',
);
  
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripID',
      theme: ThemeData(
        primaryColor: kPrimaryBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryBlue),
        useMaterial3: true,
        fontFamily: kFontFamilyJakarta,
      ),
      home: const SplashScreen(),
    );
  }
}
