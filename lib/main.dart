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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          surface: const Color(0xFFF0F4F8),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Inter'),
          displayMedium: TextStyle(fontFamily: 'Inter'),
          displaySmall: TextStyle(fontFamily: 'Inter'),
          headlineLarge: TextStyle(fontFamily: 'Inter'),
          headlineMedium: TextStyle(fontFamily: 'Inter'),
          headlineSmall: TextStyle(fontFamily: 'Inter'),
          titleLarge: TextStyle(fontFamily: 'Inter'),
          titleMedium: TextStyle(fontFamily: 'Inter'),
          titleSmall: TextStyle(fontFamily: 'Inter'),
          bodyLarge: TextStyle(fontFamily: 'Inter'),
          bodyMedium: TextStyle(fontFamily: 'Inter'),
          bodySmall: TextStyle(fontFamily: 'Inter'),
          labelLarge: TextStyle(fontFamily: 'Inter'),
          labelMedium: TextStyle(fontFamily: 'Inter'),
          labelSmall: TextStyle(fontFamily: 'Inter'),
        ),
      ),
      home: !hasAcceptedLegal
          ? LegalDisclaimerScreen(showWalkthrough: showWalkthrough)
          : (showWalkthrough ? const WalkthroughScreen() : const HomeScreen()),
    );
  }
}
