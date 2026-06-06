import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/features/auth/data/auth_api.dart';
import 'package:consulta_alunos/features/auth/data/auth_storage.dart';
import 'package:consulta_alunos/features/auth/models/user_info.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? api,
    AuthStorage? storage,
  })  : _api = api ?? AuthApi(),
        _storage = storage ?? AuthStorage();

  final AuthApi _api;
  final AuthStorage _storage;

  Future<UserInfo> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.login(email: email, password: password);
    await _storage.saveSession(
      accessToken: response.accessToken,
      user: response.infoUsuario,
    );
    return response.infoUsuario;
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      return await _api.verifyToken(token);
    } on ApiException {
      await _storage.clear();
      return false;
    } catch (_) {
      // API indisponível: mantém sessão local com token salvo
      return true;
    }
  }

  Future<String?> getToken() => _storage.getToken();

  Future<UserInfo?> getCurrentUser() => _storage.getUser();

  Future<void> logout() => _storage.clear();
}
