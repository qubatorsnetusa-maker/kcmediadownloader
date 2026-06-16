import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../services/remote_config_service.dart';

class AdSlider extends StatelessWidget {
  const AdSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final ads = RemoteConfigService().getAdCards();

    if (ads.isEmpty) return const SizedBox.shrink();

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
