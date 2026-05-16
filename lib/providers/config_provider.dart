import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/system_config_model.dart';
import 'package:leaf_cloud/repositories/config_repository_interface.dart';

class ConfigProvider extends ChangeNotifier {
  final IConfigRepository _configRepository;

  ConfigProvider(this._configRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SystemConfig? _config;
  SystemConfig? get config => _config;

  Future<void> fetchConfig() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _config = await _configRepository.getConfig();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveConfig(SystemConfig config) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _configRepository.saveConfig(config);
      _config = config;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
