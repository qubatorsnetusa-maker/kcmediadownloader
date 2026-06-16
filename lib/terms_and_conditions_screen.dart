import 'package:flutter/material.dart';
import 'dart:ui';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Same Orange and Purple Gradient Background
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms and Conditions',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '1. Acceptance of Terms\nBy accessing and using this application, you agree to be bound by these Terms and Conditions and all applicable laws and regulations.\n\n'
                            '2. Use License\nPermission is granted to use this app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.\n\n'
                            '3. Disclaimer\nThe materials on this app are provided on an \'as is\' basis. The developers make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.\n\n'
                            '4. Limitations\nIn no event shall the app or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on the app.\n\n'
                            '5. Accuracy of Materials\nThe materials appearing on the app could include technical, typographical, or photographic errors. The developers do not warrant that any of the materials on its app are accurate, complete or current.\n\n'
                            '6. Links\nThe developers have not reviewed all of the sites linked to its app and are not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by the developers of the site.',
                            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
