import 'package:rotafy_frontend/features/auth/login/data/models/user_login_model.dart';
import 'package:rotafy_frontend/features/auth/login/domain/repositories/login_repository.dart';
import 'package:rotafy_frontend/features/auth/login/data/datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDatasource _datasource = LoginRemoteDatasource();

  @override
  Future<String?> loginUser(UserLoginModel user) async {
    return await _datasource.login(user.email, user.password ?? '');
  }
}