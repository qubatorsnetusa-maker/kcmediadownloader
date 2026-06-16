import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/remote_config_service.dart';
import 'home_screen.dart';
import 'walkthrough_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RemoteConfigService().initialize();

  final prefs = await SharedPreferences.getInstance();
  final showWalkthrough = prefs.getBool('showWalkthrough') ?? true;

  runApp(KCMediaDownloaderApp(showWalkthrough: showWalkthrough));
}

class KCMediaDownloaderApp extends StatelessWidget {
  final bool showWalkthrough;
  const KCMediaDownloaderApp({super.key, required this.showWalkthrough});

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
      home: showWalkthrough ? const WalkthroughScreen() : const HomeScreen(),
    );
  }
}
