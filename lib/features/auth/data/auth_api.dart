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
}
