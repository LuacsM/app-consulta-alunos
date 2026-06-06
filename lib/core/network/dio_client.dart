import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/config/api_config.dart';

class DioClient {
  DioClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'accept': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
}
