import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: Duration.zero,
    ));

    // Set default values
    await _remoteConfig.setDefaults({
      'ad_cards': jsonEncode([
        {
          'title': 'Download Faster with Nexus',
          'subtitle': 'The high-performance media tool.',
          'color': '0xFF2196F3',
          'buttonText': 'Learn More',
          'buttonUrl': 'https://qubators.org'
        },
        {
          'title': 'KingsChat & CeFlix',
          'subtitle': 'Save your favorite content easily.',
          'color': '0xFF4CAF50',
          'buttonText': 'Watch Now',
          'buttonUrl': 'https://ceflix.org'
        },
        {
          'title': 'Qubators TechLabs',
          'subtitle': 'Innovating for the Gospel.',
          'color': '0xFFFF9800',
          'buttonText': 'Visit Us',
          'buttonUrl': 'https://qubators.org'
        },
      ]),
    });

    await fetchAndActivate();
  }

  Future<void> fetchAndActivate() async {
    await _remoteConfig.fetchAndActivate();
  }

  List<Map<String, String>> getAdCards() {
    final String jsonStr = _remoteConfig.getString('ad_cards');

    // If empty, try to return default values manually as a fallback
    if (jsonStr.isEmpty) {
      return [
        {
          'title': 'Download Faster with Nexus',
          'subtitle': 'The high-performance media tool.',
          'color': '0xFF2196F3',
          'buttonText': 'Learn More',
          'buttonUrl': 'https://qubators.org'
        },
      ];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final List<Map<String, String>> cards = [];

      for (var item in decoded) {
        if (item is Map) {
          cards.add(item.map((key, value) => MapEntry(key.toString(), value.toString())));
        } else if (item is List) {
          // Handle nested lists like [[{}], [{}]]
          for (var subItem in item) {
            if (subItem is Map) {
              cards.add(subItem.map((key, value) => MapEntry(key.toString(), value.toString())));
            }
          }
        }
      }
      return cards;
    } catch (e) {
      debugPrint('RemoteConfig Error parsing JSON: $e');
      // Return a single card as fallback on error
      return [
        {
          'title': 'Configuration Error',
          'subtitle': 'Please check your Firebase JSON format.',
          'color': '0xFFF44336',
          'buttonText': 'Help',
          'buttonUrl': 'https://google.com'
        }
      ];
    }
  }
}
