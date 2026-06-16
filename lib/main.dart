import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/remote_config_service.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RemoteConfigService().initialize();
  runApp(const KCMediaDownloaderApp());
}

class KCMediaDownloaderApp extends StatelessWidget {
  const KCMediaDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
