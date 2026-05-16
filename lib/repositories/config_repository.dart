import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/system_config_model.dart';
import 'package:leaf_cloud/repositories/config_repository_interface.dart';

class ConfigRepository implements IConfigRepository {
  final http.Client _client;

  ConfigRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<SystemConfig> getConfig() async {
    // Assuming there's a GET endpoint for the latest config
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/config'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return SystemConfig.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load configuration');
    }
  }

  @override
  Future<void> saveConfig(SystemConfig config) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/config'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(config.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      String errorMessage = 'Failed to save configuration';
      if (data is Map && data.containsKey('detail')) {
        errorMessage = data['detail'].toString();
      }
      throw Exception(errorMessage);
    }
  }
}
