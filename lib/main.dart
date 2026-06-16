import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'services/remote_config_service.dart';
import 'services/notification_service.dart';
import 'services/downloader_service.dart';
import 'home_screen.dart';
import 'walkthrough_screen.dart';
import 'legal_disclaimer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RemoteConfigService().initialize();
  await FlutterDownloader.initialize(debug: true);
  await NotificationService.initialize();
  DownloaderService.initialize();

  // Request essential permissions on startup
  await [
    Permission.storage,
    Permission.photos,
    Permission.videos,
    Permission.notification,
  ].request();

  final prefs = await SharedPreferences.getInstance();
  final showWalkthrough = prefs.getBool('showWalkthrough') ?? true;
  final hasAcceptedLegal = prefs.getBool('hasAcceptedLegal') ?? false;

  runApp(NexusMediaDownloaderApp(
    showWalkthrough: showWalkthrough,
    hasAcceptedLegal: hasAcceptedLegal,
  ));
}

class NexusMediaDownloaderApp extends StatelessWidget {
  final bool showWalkthrough;
  final bool hasAcceptedLegal;
  const NexusMediaDownloaderApp({
    super.key,
    required this.showWalkthrough,
    required this.hasAcceptedLegal,
  });

  @override
  Widget build(BuildContext context) {
    const String fontFamily = 'PlusJakartaSans';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Media Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          surface: const Color(0xFFF0F4F8),
        ),
        useMaterial3: true,
        fontFamily: fontFamily,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: fontFamily),
          displayMedium: TextStyle(fontFamily: fontFamily),
          displaySmall: TextStyle(fontFamily: fontFamily),
          headlineLarge: TextStyle(fontFamily: fontFamily),
          headlineMedium: TextStyle(fontFamily: fontFamily),
          headlineSmall: TextStyle(fontFamily: fontFamily),
          titleLarge: TextStyle(fontFamily: fontFamily),
          titleMedium: TextStyle(fontFamily: fontFamily),
          titleSmall: TextStyle(fontFamily: fontFamily),
          bodyLarge: TextStyle(fontFamily: fontFamily),
          bodyMedium: TextStyle(fontFamily: fontFamily),
          bodySmall: TextStyle(fontFamily: fontFamily),
          labelLarge: TextStyle(fontFamily: fontFamily),
          labelMedium: TextStyle(fontFamily: fontFamily),
          labelSmall: TextStyle(fontFamily: fontFamily),
        ),
      ),
      home: !hasAcceptedLegal
          ? LegalDisclaimerScreen(showWalkthrough: showWalkthrough)
          : (showWalkthrough ? const WalkthroughScreen() : const HomeScreen()),
    );
  }
}
