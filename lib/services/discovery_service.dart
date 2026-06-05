import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:leaf_cloud/core/constants.dart';

class DiscoveryService {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  static const Duration _discoveryTimeout = Duration(seconds: 15);

  nsd.Discovery? _discovery;
  Process? _linuxProcess;
  bool _isSearching = false;
  Timer? _timeoutTimer;

  /// Starts searching for the LeafCloud server on the local network.
  Future<void> initDiscovery({String serviceType = '_leafcloud._tcp'}) async {
    if (_isSearching) return;
    _isSearching = true;
    ApiConstants.connectionNotifier.value = null; // Set to searching state

    debugPrint('Starting network discovery for $serviceType...');

    _timeoutTimer = Timer(_discoveryTimeout, () {
      if (ApiConstants.connectionNotifier.value == null) {
        debugPrint('Discovery timed out — no server found');
        ApiConstants.setDisconnected();
        stopDiscovery();
      }
    });

    // Linux mDNS Compatibility Layer for WSL
    if (Platform.isLinux) {
      _startLinuxDiscovery(serviceType);
      return;
    }

    try {
      _discovery = await nsd.startDiscovery(serviceType);

      _discovery!.addListener(() {
        final services = _discovery!.services;
        if (services.isNotEmpty) {
          for (final service in services) {
            final port = service.port;

            String? hostAddress;
            if (service.host != null && service.host!.isNotEmpty) {
              hostAddress = service.host;
            } else if (service.addresses != null && service.addresses!.isNotEmpty) {
              hostAddress = service.addresses!.first.address;
            }

            if (hostAddress != null && port != null) {
              if (hostAddress.endsWith('.')) {
                hostAddress = hostAddress.substring(0, hostAddress.length - 1);
              }

              final discoveredUrl = 'http://$hostAddress:$port';
              ApiConstants.updateBaseUrl(discoveredUrl);
              debugPrint('Discovered server at: $discoveredUrl');

              _timeoutTimer?.cancel();
              stopDiscovery();
              break;
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error during discovery: $e');
      _timeoutTimer?.cancel();
      ApiConstants.setDisconnected();
      _isSearching = false;
    }
  }

  /// Custom Linux mDNS query implementation using local avahi-browse
  Future<void> _startLinuxDiscovery(String serviceType) async {
    try {
      // Run avahi-browse in background mode:
      // -r: resolve service details (hostname, IP, port)
      // -p: print output in machine-parseable format (colon/semicolon delimited)
      // We remove the '-t' flag so it continuously listens for new broadcasts during the search window.
      _linuxProcess = await Process.start('avahi-browse', ['-r', '-p', serviceType]);

      _linuxProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        final parts = line.split(';');
        // Semicolon-delimited format:
        // index 0: resolved status '='
        // index 6: hostname (e.g. leafcloud-server.local)
        // index 7: IP address (e.g. 192.168.1.20)
        // index 8: port (e.g. 8000)
        if (parts.length >= 9 && parts[0] == '=') {
          final hostname = parts[6];
          final address = parts[7];
          final portVal = int.tryParse(parts[8]);

          if (portVal != null) {
            // Prefer the direct IP address over hostname because WSL/Linux often cannot
            // resolve .local mDNS hostnames out of the box.
            String hostAddress = address.isNotEmpty ? address : hostname;
            if (hostAddress.contains(':')) {
              // Wrap IPv6 addresses in square brackets for valid URL format
              hostAddress = '[$hostAddress]';
            } else if (hostAddress.endsWith('.')) {
              hostAddress = hostAddress.substring(0, hostAddress.length - 1);
            }

            final discoveredUrl = 'http://$hostAddress:$portVal';
            ApiConstants.updateBaseUrl(discoveredUrl);
            debugPrint('Linux (Avahi) Discovered server at: $discoveredUrl');

            _timeoutTimer?.cancel();
            stopDiscovery();
          }
        }
      });

      _linuxProcess!.exitCode.then((code) {
        if (ApiConstants.connectionNotifier.value == null) {
          debugPrint('Linux discovery process exited with code: $code');
        }
      });
    } catch (e) {
      debugPrint('Linux discovery failed: $e');
      _timeoutTimer?.cancel();
      ApiConstants.setDisconnected();
      _isSearching = false;
    }
  }

  Future<void> stopDiscovery() async {
    _timeoutTimer?.cancel();
    if (_linuxProcess != null) {
      _linuxProcess!.kill();
      _linuxProcess = null;
    }
    if (_discovery != null) {
      await nsd.stopDiscovery(_discovery!);
      _discovery = null;
    }
    _isSearching = false;
    debugPrint('Stopping network discovery.');
  }
}
