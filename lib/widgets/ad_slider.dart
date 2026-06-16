import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdSlider extends StatelessWidget {
  const AdSlider({super.key});

  final List<Map<String, String>> ads = const [
    {
      'title': 'Download Faster with KC Downloader',
      'subtitle': 'The best tool for KingsChat media.',
      'color': '0xFF2196F3'
    },
    {
      'title': 'CeFlix Content Offline',
      'subtitle': 'Save your favorite videos easily.',
      'color': '0xFF4CAF50'
    },
    {
      'title': 'Simple & Secure',
      'subtitle': 'Your privacy is our priority.',
      'color': '0xFFFF9800'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 120.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: ads.map((ad) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Color(int.parse(ad['color']!)),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad['title']!,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      ad['subtitle']!,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
