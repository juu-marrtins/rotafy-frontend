import '../../data/models/user_model.dart';
import '../repositories/register_repository.dart';

class RegisterUser {
  final RegisterRepository _repository;

  RegisterUser(this._repository);

  Future<String?> call(UserModel user) async {
    if (user.name.trim().length < 3) {
      return 'Nome deve ter ao menos 3 caracteres';
    }

    if (!user.email.contains('@edu')) {
      return 'Use um e-mail institucional';
    }

    return _repository.registerUser(user);
  }
}