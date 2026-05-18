import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leaf_cloud/repositories/iot_repository_interface.dart';
import 'package:leaf_cloud/services/notification_service.dart';
import 'package:leaf_cloud/providers/config_provider.dart';

class AlertProvider extends ChangeNotifier {
  final IIotRepository _repository;
  final NotificationService _notificationService = NotificationService();
  final ConfigProvider _configProvider;

  Timer? _pollingTimer;
  bool _isPolling = false;

  AlertProvider(this._repository, this._configProvider) {
    _configProvider.addListener(_onConfigChanged);
    _startPolling();
  }

  void _onConfigChanged() {
    // If the active tank changes, we might want to reset polling or just continue
    // Since we always poll for the active tank, we just keep going.
    // If no active tank, polling will just fail or we can skip it.
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    
    // Poll every 5 minutes as per documentation
    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkAlerts());
    
    // Also check immediately on start
    _checkAlerts();
  }

  Future<void> _checkAlerts() async {
    final activeConfig = _configProvider.activeConfig;
    if (activeConfig == null || activeConfig.id == null) return;

    try {
      final status = await _repository.getAlertStatus(activeConfig.id!);
      if (status.hasAlert) {
        await _notificationService.showAlertNotification(
          id: activeConfig.id!,
          title: 'LeafCloud ${status.level}',
          body: status.message ?? 'Top-up required for ${activeConfig.tankName}',
        );
      }
    } catch (e) {
      debugPrint('Error polling alerts: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _configProvider.removeListener(_onConfigChanged);
    super.dispose();
  }
}
