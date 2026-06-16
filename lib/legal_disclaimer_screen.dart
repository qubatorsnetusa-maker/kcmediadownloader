import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'walkthrough_screen.dart';

class LegalDisclaimerScreen extends StatelessWidget {
  final bool showWalkthrough;
  const LegalDisclaimerScreen({super.key, required this.showWalkthrough});

  Future<void> _acceptDisclaimer(BuildContext context) async {
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
      body: Stack(
        children: [
          // Orange and Purple Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF9800), // Orange
                  Color(0xFF9C27B0), // Purple
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Legal Disclaimer',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), // Increased blur
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), // Reduced opacity for more effect
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'By using this application, you acknowledge and agree that:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 24),
                                _buildGlassBullet(
                                  'User Responsibility:',
                                  'You are solely responsible for any media files you download through this application. This app serves as a tool only and does not host, store, or distribute any content.',
                                ),
                                _buildGlassBullet(
                                  'Permission & Rights:',
                                  'You confirm that you have obtained all necessary permissions, licenses, or authorizations from the copyright holders before downloading any media files. It is your responsibility to ensure compliance with applicable copyright laws, terms of service, and intellectual property rights.',
                                ),
                                _buildGlassBullet(
                                  'No Liability:',
                                  'This application and its developers shall not be held liable for any legal consequences, damages, or losses arising from your use of downloaded content, including but not limited to copyright infringement claims, misuse, or unauthorized distribution.',
                                ),
                                _buildGlassBullet(
                                  'Lawful Use:',
                                  'You agree to use downloaded media files for lawful purposes only, in accordance with your local jurisdiction\'s laws and regulations.',
                                ),
                                _buildGlassBullet(
                                  'Indemnification:',
                                  'You agree to indemnify and hold harmless this application, its developers, and affiliates from any claims, damages, or legal actions resulting from your use of this service.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ElevatedButton(
                        onPressed: () => _acceptDisclaimer(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.85),
                          foregroundColor: const Color(0xFF9C27B0), // Purple text
                          minimumSize: const Size(double.infinity, 60),
                          shape: const StadiumBorder(), // Full rounded edges
                          elevation: 0,
                        ),
                        child: const Text('I Accept & Agree', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBullet(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }
}
