import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const KCMediaDownloaderApp());
}

class KCMediaDownloaderApp extends StatelessWidget {
  const KCMediaDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KC Media Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
