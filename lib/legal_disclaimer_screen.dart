import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      appBar: AppBar(
        title: const Text('Legal Disclaimer'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please read and accept these terms before using the app.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildBulletPoint(
                        'User Responsibility:',
                        'You are solely responsible for any media files you download through this application. This app serves as a tool only and does not host, store, or distribute any content.',
                      ),
                      _buildBulletPoint(
                        'Permission & Rights:',
                        'You confirm that you have obtained all necessary permissions, licenses, or authorizations from the copyright holders before downloading any media files. It is your responsibility to ensure compliance with applicable copyright laws, terms of service, and intellectual property rights.',
                      ),
                      _buildBulletPoint(
                        'No Liability:',
                        'This application and its developers shall not be held liable for any legal consequences, damages, or losses arising from your use of downloaded content, including but not limited to copyright infringement claims, misuse, or unauthorized distribution.',
                      ),
                      _buildBulletPoint(
                        'Lawful Use:',
                        'You agree to use downloaded media files for lawful purposes only, in accordance with your local jurisdiction\'s laws and regulations.',
                      ),
                      _buildBulletPoint(
                        'Indemnification:',
                        'You agree to indemnify and hold harmless this application, its developers, and affiliates from any claims, damages, or legal actions resulting from your use of this service.',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'By proceeding, you affirm that you have read, understood, and accepted these terms.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _acceptDisclaimer(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('I Accept & Agree', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}
