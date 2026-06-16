import 'package:flutter/material.dart';
import 'dart:ui';
import 'styles/glass_styles.dart';

class LegalDisclaimerViewScreen extends StatelessWidget {
  const LegalDisclaimerViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Legal Disclaimer', style: TextStyle(color: Colors.blueGrey[900], fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blueGrey[900]),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: GlassStyles.radialBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: GlassStyles.glassBlur, sigmaY: GlassStyles.glassBlur),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: GlassStyles.glassPanelDecoration.copyWith(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legal Disclaimer',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                        ),
                        const SizedBox(height: 24),
                        _buildPoint('User Responsibility:', 'You are solely responsible for any media files you download through this application. This app serves as a tool only and does not host, store, or distribute any content.'),
                        _buildPoint('Permission & Rights:', 'You confirm that you have obtained all necessary permissions, licenses, or authorizations from the copyright holders before downloading any media files.'),
                        _buildPoint('No Liability:', 'This application and its developers shall not be held liable for any legal consequences, damages, or losses arising from your use of downloaded content.'),
                        _buildPoint('Lawful Use:', 'You agree to use downloaded media files for lawful purposes only, in accordance with your local jurisdiction\'s laws and regulations.'),
                        _buildPoint('Indemnification:', 'You agree to indemnify and hold harmless this application, its developers, and affiliates from any claims, damages, or legal actions resulting from your use of this service.'),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Qubators Network 2026',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoint(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey[900])),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 14, color: Colors.blueGrey[700], height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
