import 'package:local_auth/local_auth.dart';

class DeviceAuthException implements Exception {
  DeviceAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DeviceAuthService {
  DeviceAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> authenticateForOfflineSession() async {
    final isSupported = await _localAuth.isDeviceSupported();
    if (!isSupported) {
      throw DeviceAuthException(
        'Este dispositivo não oferece autenticação por senha, '
        'impressão digital ou reconhecimento facial.',
      );
    }

    try {
      return await _localAuth.authenticate(
        localizedReason:
            'Confirme sua identidade para iniciar a sessão offline.',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on DeviceAuthException {
      rethrow;
    } catch (_) {
      throw DeviceAuthException(
        'Não foi possível concluir a autenticação do dispositivo.',
      );
    }
  }
}
