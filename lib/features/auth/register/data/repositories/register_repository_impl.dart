import '../../domain/repositories/register_repository.dart';
import '../datasources/register_remote_datasource.dart';
import '../models/user_model.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDatasource _datasource;

  RegisterRepositoryImpl(this._datasource);

	@override
	Future<String?> registerUser(UserModel user) async {
		try {
			await _datasource.register(user);
			return null;
		} catch (e) {
			return 'Erro ao realizar cadastro. Tente novamente.';
		}
	}
}