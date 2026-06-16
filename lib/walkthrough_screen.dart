import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'styles/glass_styles.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({super.key});

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWalkthrough', false);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
        child: IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: [
            _buildPage(
              context,
              "Welcome to KC Downloader",
              "The easiest way to download media from KingsChat and CeFlix.",
              Icons.download_for_offline,
              Colors.blue,
            ),
            _buildPage(
              context,
              "Simple Copy & Paste",
              "Just copy the post link and paste it here. We'll handle the rest!",
              Icons.link,
              Colors.green,
            ),
            _buildPage(
              context,
              "High Quality Media",
              "Download videos and images in the best available resolution.",
              Icons.high_quality,
              Colors.orange,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
          next: const Icon(Icons.arrow_forward, color: Colors.blue),
          done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
          curve: Curves.fastOutSlowIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Color(0xFFBDBDBD),
            activeSize: Size(22.0, 10.0),
            activeColor: Colors.blue,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }

  PageViewModel _buildPage(BuildContext context, String title, String body, IconData icon, Color color) {
    return PageViewModel(
      title: title,
      body: body,
      image: Center(child: Icon(icon, size: 175, color: color.withValues(alpha: 0.8))),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.blueGrey[900], letterSpacing: -0.5),
        bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.blueGrey[700], fontWeight: FontWeight.w500),
        pageColor: Colors.transparent,
        contentMargin: const EdgeInsets.all(24),
      ),
    );
  }
}
