import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _customHostKey = 'jrms_custom_api_host';
  static String? _customHost;

  /// Initialize custom host IP from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customHost = prefs.getString(_customHostKey);
    } catch (e) {
      debugPrint('ApiConfig init error: $e');
    }
  }

  /// Set custom backend host IP (for physical Android device LAN testing)
  static Future<void> setCustomHost(String? host) async {
    _customHost = host;
    final prefs = await SharedPreferences.getInstance();
    if (host == null || host.isEmpty) {
      await prefs.remove(_customHostKey);
    } else {
      await prefs.setString(_customHostKey, host);
    }
  }

  static String get currentCustomHost => _customHost ?? '';

  /// Base REST API Host URL (dynamic per platform/network)
  static String get baseUrl {
    if (_customHost != null && _customHost!.isNotEmpty) {
      String host = _customHost!;
      if (!host.startsWith('http://') && !host.startsWith('https://')) {
        host = 'http://$host';
      }
      if (!host.endsWith('/api')) {
        host = host.endsWith('/') ? '${host}api' : '$host/api';
      }
      return host;
    }

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Default Android emulator host loopback address
        return 'http://10.0.2.2:5000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:5000/api';
    }
  }

  /// Base Media/Static Uploads Host URL
  static String get mediaBaseUrl {
    final base = baseUrl;
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }
}
