import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'walkthrough_screen.dart';
import 'styles/glass_styles.dart';

class LegalDisclaimerScreen extends StatelessWidget {
  final bool showWalkthrough;
  const LegalDisclaimerScreen({super.key, required this.showWalkthrough});

  Future<void> _acceptDisclaimer(BuildContext context) async {
    // 1. Request Permissions
    await [
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedLegal', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => showWalkthrough ? const WalkthroughScreen() : const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GlassStyles.radialBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                child: Text(
                  'Legal Disclaimer',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: GlassStyles.glassBlur, sigmaY: GlassStyles.glassBlur),
                      child: Container(
                        decoration: GlassStyles.glassPanelDecoration.copyWith(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Legal Disclaimer',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildSection('User Responsibility:', 'You are solely responsible for any media files you download through this application. This app serves as a tool only and does not host, store, or distribute any content.'),
                              _buildSection('Permission & Rights:', 'You confirm that you have obtained all necessary permissions, licenses, or authorizations from the copyright holders before downloading any media files.'),
                              _buildSection('No Liability:', 'This application and its developers shall not be held liable for any legal consequences, damages, or losses arising from your use of downloaded content.'),
                              _buildSection('Lawful Use:', 'You agree to use downloaded media files for lawful purposes only, in accordance with your local jurisdiction\'s laws and regulations.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: GestureDetector(
                  onTap: () => _acceptDisclaimer(context),
                  child: Container(
                    height: 64,
                    decoration: GlassStyles.glassPanelDecoration.copyWith(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'I Accept & Agree',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueGrey[900],
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[700],
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
