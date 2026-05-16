import 'package:flutter/material.dart';

class ApiConstants {
  static String? _discoveredBaseUrl;
  
  /// ValueNotifier to track the connection status and discovered URL globally.
  static final ValueNotifier<String?> connectionNotifier = ValueNotifier<String?>(null);

  /// Returns the discovered URL if available, otherwise falls back to the default localhost.
  static String get baseUrl => _discoveredBaseUrl ?? 'http://localhost:8000';

  static String get loginEndpoint => '$baseUrl/auth/login';

  /// Dynamically updates the base URL (used by discovery service)
  static void updateBaseUrl(String newUrl) {
    _discoveredBaseUrl = newUrl;
    connectionNotifier.value = newUrl;
  }
}
