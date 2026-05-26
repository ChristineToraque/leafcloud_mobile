import 'package:leaf_cloud/models/user_model.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<User> register(String name, String email, String password);
}
