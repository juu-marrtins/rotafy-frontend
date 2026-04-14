import 'package:rotafy_frontend/features/auth/login/data/models/user_login_model.dart';

abstract class LoginRepository {
  Future<String?> loginUser(UserLoginModel user);
}
