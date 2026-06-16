import 'package:flutter/material.dart';
import 'dart:ui';
import 'styles/glass_styles.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Terms & Conditions', style: TextStyle(color: Colors.blueGrey[900], fontWeight: FontWeight.bold)),
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
                          'Terms and Conditions',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                        ),
                        const SizedBox(height: 24),
                        _buildSection(
                          '1. Acceptance of Terms',
                          'By accessing and using this application, you agree to be bound by these Terms and Conditions and all applicable laws and regulations.',
                        ),
                        _buildSection(
                          '2. Use License',
                          'Permission is granted to use this app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
                        ),
                        _buildSection(
                          '3. Disclaimer',
                          'The materials on this app are provided on an \'as is\' basis. The developers make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                        ),
                        _buildSection(
                          '4. Limitations',
                          'In no event shall the app or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on the app.',
                        ),
                        _buildSection(
                          '5. Links',
                          'The developers have not reviewed all of the sites linked to its app and are not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by the developers of the site.',
                        ),
                        _buildSection(
                          '6. Privacy Policy',
                          'We respect your privacy. This application does not collect, store, or share any personal data from its users. Any media downloaded is processed locally on your device and saved directly to your gallery. We do not have access to your files or download history. We may use anonymous device identifiers and cloud-based configuration services to provide a better and more up-to-date user experience.',
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.blueGrey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
