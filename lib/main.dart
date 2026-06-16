import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/remote_config_service.dart';
import 'home_screen.dart';
import 'walkthrough_screen.dart';
import 'legal_disclaimer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RemoteConfigService().initialize();

  final prefs = await SharedPreferences.getInstance();
  final showWalkthrough = prefs.getBool('showWalkthrough') ?? true;
  final hasAcceptedLegal = prefs.getBool('hasAcceptedLegal') ?? false;

  runApp(KCMediaDownloaderApp(
    showWalkthrough: showWalkthrough,
    hasAcceptedLegal: hasAcceptedLegal,
  ));
}

class KCMediaDownloaderApp extends StatelessWidget {
  final bool showWalkthrough;
  final bool hasAcceptedLegal;
  const KCMediaDownloaderApp({
    super.key,
    required this.showWalkthrough,
    required this.hasAcceptedLegal,
  });

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
      home: !hasAcceptedLegal
          ? LegalDisclaimerScreen(showWalkthrough: showWalkthrough)
          : (showWalkthrough ? const WalkthroughScreen() : const HomeScreen()),
    );
  }
}
