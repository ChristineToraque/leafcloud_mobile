import 'package:flutter/material.dart';
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/user_model.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  bool get isAdmin => _loginResponse?.user?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loginResponse = await _authRepository.login(email, password);
      ApiConstants.token = _loginResponse?.token;
      ApiConstants.refreshToken = _loginResponse?.refreshToken;
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

  Future<void> logout() async {
    final accessToken = ApiConstants.token;
    final refreshToken = ApiConstants.refreshToken;

    // Clear local session state instantly
    _loginResponse = null;
    ApiConstants.token = null;
    ApiConstants.refreshToken = null;
    notifyListeners();

    // Invoke server logout in the background
    if (accessToken != null && refreshToken != null) {
      try {
        await _authRepository.logout(accessToken, refreshToken);
      } catch (e) {
        debugPrint('Server-side logout request failed: $e');
      }
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(name, email, password);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
