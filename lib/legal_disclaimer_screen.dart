import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'walkthrough_screen.dart';
import 'terms_and_conditions_screen.dart';

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
          // Apple-style Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF64B5F6), // Blue
                  Color(0xFF81C784), // Green
                  Color(0xFFFFB74D), // Orange
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
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
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
                                  'You are solely responsible for any media files you download through this application.',
                                ),
                                _buildGlassBullet(
                                  'Permission & Rights:',
                                  'You confirm that you have obtained all necessary permissions from the copyright holders.',
                                ),
                                _buildGlassBullet(
                                  'No Liability:',
                                  'The developers shall not be held liable for any legal consequences or damages.',
                                ),
                                _buildGlassBullet(
                                  'Lawful Use:',
                                  'You agree to use downloaded media files for lawful purposes only.',
                                ),
                                _buildGlassBullet(
                                  'Indemnification:',
                                  'You agree to indemnify and hold harmless the developers from any claims.',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ElevatedButton(
                        onPressed: () => _acceptDisclaimer(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          foregroundColor: Colors.blue[900],
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('I Accept & Agree', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Terms & Conditions link at the very bottom
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                    );
                  },
                  child: const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
          Text(body, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}
