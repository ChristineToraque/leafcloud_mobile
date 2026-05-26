import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/user_model.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';

class AuthRepository implements IAuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Check if the response is JSON
      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server returned a non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        String errorMessage = 'Login failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            errorMessage = data['detail'][0]['msg'] ?? errorMessage;
          } else {
            errorMessage = data['detail'].toString();
          }
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server returned a non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(data);
      } else {
        String errorMessage = 'Registration failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            errorMessage = data['detail'][0]['msg'] ?? errorMessage;
          } else {
            errorMessage = data['detail'].toString();
          }
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
