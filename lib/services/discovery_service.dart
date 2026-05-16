import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:leaf_cloud/core/constants.dart';

class DiscoveryService {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  nsd.Discovery? _discovery;
  bool _isSearching = false;

  /// Starts searching for the LeafCloud server on the local network.
  /// Ensure your backend broadcasts with this service type.
  Future<void> initDiscovery({String serviceType = '_leafcloud._tcp'}) async {
    if (_isSearching) return;
    _isSearching = true;

    debugPrint('Starting network discovery for $serviceType...');

    try {
      _discovery = await nsd.startDiscovery(serviceType);
      
      _discovery!.addListener(() {
        final services = _discovery!.services;
        if (services.isNotEmpty) {
          for (final service in services) {
            final port = service.port;
            
            // Try to get the actual IP address first, fallback to host
            String? hostAddress;
            if (service.addresses != null && service.addresses!.isNotEmpty) {
              hostAddress = service.addresses!.first.address;
            } else {
              hostAddress = service.host;
            }

            if (hostAddress != null && port != null) {
              // Clean hostname if it has a trailing dot
              if (hostAddress.endsWith('.')) {
                hostAddress = hostAddress.substring(0, hostAddress.length - 1);
              }

              final discoveredUrl = 'http://$hostAddress:$port';
              ApiConstants.updateBaseUrl(discoveredUrl);
              debugPrint('Discovered server at: $discoveredUrl');
              
              stopDiscovery();
              break;
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error during discovery: $e');
      _isSearching = false;
    }
  }

  Future<void> stopDiscovery() async {
    if (_discovery != null) {
      await nsd.stopDiscovery(_discovery!);
      _discovery = null;
      _isSearching = false;
      debugPrint('Stopping network discovery.');
    }
  }
}
