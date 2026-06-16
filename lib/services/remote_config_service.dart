import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Set default values
    await _remoteConfig.setDefaults({
      'ad_cards': jsonEncode([
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
      ]),
    });

    await fetchAndActivate();
  }

  Future<void> fetchAndActivate() async {
    await _remoteConfig.fetchAndActivate();
  }

  List<Map<String, String>> getAdCards() {
    final String jsonStr = _remoteConfig.getString('ad_cards');
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => Map<String, String>.from(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
