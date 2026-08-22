import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/api_response_parser.dart';
import 'package:consulta_alunos/core/network/dio_client.dart';
import 'package:consulta_alunos/features/auth/models/login_response.dart';

class AuthApi {
  AuthApi({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/usuarios/login',
      data: {
        'email': email,
        'senha': password,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    final body = ApiResponseParser.decodeObjectFrom(response.data);

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(body);
    }

    throw ApiException(
      ApiResponseParser.extractDetail(body) ?? 'Erro ao fazer login.',
      statusCode: response.statusCode,
    );
  }

  Future<bool> verifyToken(String token) async {
    final response = await _dio.get<dynamic>(
      '/usuarios/verificar-token/$token',
    );

    if (response.statusCode == 200) return true;

    final body = ApiResponseParser.decodeObjectFrom(response.data);
    throw ApiException(
      ApiResponseParser.extractDetail(body) ?? 'Token inválido ou expirado!',
      statusCode: response.statusCode,
    );
  }

  Future<void> logout(String token) async {
    final response = await _dio.post<dynamic>(
      '/usuarios/logout',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    final body = ApiResponseParser.decodeObjectFrom(response.data);
    throw ApiException(
      ApiResponseParser.extractDetail(body) ?? 'Erro ao encerrar sessão.',
      statusCode: response.statusCode,
    );
  }

  Future<String> changePassword({
    required String token,
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.put<dynamic>(
      '/usuarios/alterar-senha/$userId',
      data: {
        'senha_atual': currentPassword,
        'senha_nova': newPassword,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is String && data.isNotEmpty) return data;
      return 'Senha atualizada com sucesso!';
    }

    final body = ApiResponseParser.decodeObjectFrom(response.data);
    throw ApiException(
      ApiResponseParser.extractDetail(body) ??
          'Não foi possível alterar a senha.',
      statusCode: response.statusCode,
    );
  }

  Future<String> recoverPassword({
    required String cpf,
    required String phone,
    required String newPassword,
  }) async {
    final response = await _dio.put<dynamic>(
      '/usuarios/recuperar-senha',
      data: {
        'cpf': cpf,
        'telefone': phone,
        'senha_nova': newPassword,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode == 200) {
      final body = ApiResponseParser.decodeObjectFrom(response.data);
      final message = body['mensagem'];
      if (message is String && message.isNotEmpty) return message;
      if (response.data is String && (response.data as String).isNotEmpty) {
        return response.data as String;
      }
      return 'Senha redefinida com sucesso!';
    }

    final body = ApiResponseParser.decodeObjectFrom(response.data);
    throw ApiException(
      ApiResponseParser.extractDetail(body) ??
          'Não foi possível recuperar a senha.',
      statusCode: response.statusCode,
    );
  }
}
