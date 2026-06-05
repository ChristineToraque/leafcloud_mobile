import 'package:flutter/material.dart';

class ApiConstants {
  static String? _discoveredBaseUrl;
  static String? token;
  static String? refreshToken;
  
  /// ValueNotifier to track the connection status and discovered URL globally.
  static final ValueNotifier<String?> connectionNotifier = ValueNotifier<String?>(null);

  /// Returns the discovered URL if available, otherwise falls back to the default localhost IP.
  static String get baseUrl => (_discoveredBaseUrl == null || _discoveredBaseUrl == 'disconnected')
      ? 'http://127.0.0.1:8000'
      : _discoveredBaseUrl!;

  static String get loginEndpoint => '$baseUrl/api/v1/auth/login';
  static String get registerEndpoint => '$baseUrl/api/v1/auth/register';

  /// Dynamically updates the base URL (used by discovery service)
  static void updateBaseUrl(String newUrl) {
    _discoveredBaseUrl = newUrl;
    connectionNotifier.value = newUrl;
  }

  /// Explicitly marks the client as disconnected from any server
  static void setDisconnected() {
    _discoveredBaseUrl = null;
    connectionNotifier.value = 'disconnected';
  }

  /// Normalizes an image URL from the API to use the current dynamic baseUrl.
  static String normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    try {
      final parsedUri = Uri.parse(url);
      String path = parsedUri.path;
      if (!path.startsWith('/')) {
        path = '/$path';
      }
      final query = parsedUri.hasQuery ? '?${parsedUri.query}' : '';
      return '$baseUrl$path$query';
    } catch (_) {
      if (url.startsWith('/')) {
        return '$baseUrl$url';
      }
      return url;
    }
  }
}
