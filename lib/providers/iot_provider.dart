import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/dashboard_model.dart';
import 'package:leaf_cloud/models/history_model.dart';
import 'package:leaf_cloud/repositories/iot_repository_interface.dart';

class IotProvider extends ChangeNotifier {
  final IIotRepository _iotRepository;

  IotProvider(this._iotRepository);

  // --- Dashboard ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DashboardData? _dashboardData;
  DashboardData? get dashboardData => _dashboardData;

  Future<void> fetchDashboard(int tankId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _iotRepository.getDashboard(tankId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- History ---
  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _historyError;
  String? get historyError => _historyError;

  HistoryData? _historyData;
  HistoryData? get historyData => _historyData;

  Future<void> fetchHistory(int tankId, {int days = 7}) async {
    _isHistoryLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      _historyData = await _iotRepository.getHistory(tankId, days: days);
      _isHistoryLoading = false;
      notifyListeners();
    } catch (e) {
      _historyError = e.toString().replaceAll('Exception: ', '');
      _isHistoryLoading = false;
      notifyListeners();
    }
  }
}
