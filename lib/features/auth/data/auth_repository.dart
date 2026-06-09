import 'package:consulta_alunos/core/auth/device_auth_service.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/network_utils.dart';
import 'package:consulta_alunos/features/auth/data/auth_api.dart';
import 'package:consulta_alunos/features/auth/data/auth_storage.dart';
import 'package:consulta_alunos/features/auth/models/session_check_result.dart';
import 'package:consulta_alunos/features/auth/models/user_info.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? api,
    AuthStorage? storage,
    DeviceAuthService? deviceAuth,
  })  : _api = api ?? AuthApi(),
        _storage = storage ?? AuthStorage(),
        _deviceAuth = deviceAuth ?? DeviceAuthService();

  final AuthApi _api;
  final AuthStorage _storage;
  final DeviceAuthService _deviceAuth;

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

  /// Valida o token online. Sem internet + sessão salva → opção offline.
  Future<SessionCheckResult> checkSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      return SessionCheckResult.unauthenticated();
    }

    try {
      final isValid = await _api.verifyToken(token);
      return isValid
          ? SessionCheckResult.authenticated()
          : SessionCheckResult.unauthenticated();
    } on ApiException {
      return SessionCheckResult.unauthenticated();
    } catch (error) {
      if (NetworkUtils.isConnectionError(error) && await hasStoredSession()) {
        return SessionCheckResult.offlineAvailable();
      }
      return SessionCheckResult.unauthenticated();
    }
  }

  /// Indica se já houve login bem-sucedido anteriormente neste dispositivo.
  Future<bool> hasStoredSession() async {
    final token = await _storage.getToken();
    final user = await _storage.getUser();
    return token != null &&
        token.isNotEmpty &&
        user != null;
  }

  Future<bool> startOfflineSession() async {
    if (!await hasStoredSession()) {
      throw ApiException(
        'Não há sessão anterior neste dispositivo para entrar offline.',
      );
    }

    final authenticated = await _deviceAuth.authenticateForOfflineSession();
    if (!authenticated) {
      throw ApiException('Autenticação do dispositivo cancelada.');
    }

    return true;
  }

  Future<String?> getToken() => _storage.getToken();

  Future<UserInfo?> getCurrentUser() => _storage.getUser();

  Future<void> logout() => _storage.clear();
}
