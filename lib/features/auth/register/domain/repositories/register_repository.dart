import '../../data/models/user_model.dart';

abstract class RegisterRepository {
  Future<String?> registerUser(UserModel user);
}