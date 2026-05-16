import 'package:leaf_cloud/models/user_model.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(String email, String password);
}
