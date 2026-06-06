import 'package:consulta_alunos/features/auth/models/user_info.dart';

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.infoUsuario,
  });

  final String accessToken;
  final String tokenType;
  final UserInfo infoUsuario;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      infoUsuario: UserInfo.fromJson(
        json['info_usuario'] as Map<String, dynamic>,
      ),
    );
  }
}
