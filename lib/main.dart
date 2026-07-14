import 'package:flutter/material.dart';
import 'screens/aura_screen.dart';

void main() {
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C9A95),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuraScreen(),
    );
  }
}