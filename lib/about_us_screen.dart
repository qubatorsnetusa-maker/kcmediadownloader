import 'package:flutter/material.dart';
import 'dart:ui';
import 'styles/glass_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF263238)),
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
                  child: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nexus Media Downloader',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nexus Media Downloader is developed by Qubators TechLabs, a dedicated team of Christian technology developers, designers, and innovators committed to building meaningful digital solutions.',
                          style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF455A64), fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Our Mission',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our mission is to use technology to support the spread of the Gospel, empower individuals and organizations, and create products that improve lives. Through thoughtful innovation, we develop practical tools that help people communicate, collaborate, grow, and make a positive impact in the world.',
                          style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF455A64), fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 32),
                        Center(
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
}
