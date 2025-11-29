import 'package:flutter/material.dart';
import 'package:tekber_tripid/shared/constants.dart';
import 'screens/splash/splash_screen.dart';

void main() {
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
