import 'package:leaf_cloud/models/system_config_model.dart';

abstract class IConfigRepository {
  Future<SystemConfig> getConfig();
  Future<void> saveConfig(SystemConfig config);
}
