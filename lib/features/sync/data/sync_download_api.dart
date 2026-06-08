import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/config/api_config.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/api_response_parser.dart';
typedef DownloadProgressCallback = void Function(int received, int total);

class SyncDownloadApi {
  SyncDownloadApi({Dio? dio}) : _dio = dio ?? _createDownloadDio();

  final Dio _dio;

  static Dio _createDownloadDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 30),
        headers: {'accept': 'application/gzip'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Future<void> downloadArchive({
    required String token,
    required String savePath,
    String? updatedAfter,
    String? codEscola,
    DownloadProgressCallback? onProgress,
  }) async {
    try {
      final response = await _dio.download(
        '/alunos/sync-download',
        savePath,
        queryParameters: {
          'updated_after': ?updatedAfter,
          'cod_escola': ?codEscola,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: onProgress,
        deleteOnError: true,
      );

      if (response.statusCode != 200) {
        final body = ApiResponseParser.decodeObjectFrom(response.data);
        throw ApiException(
          ApiResponseParser.extractDetail(body) ??
              'Erro ao baixar arquivo de sincronização.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  ApiException _mapDioError(DioException error) {
    final response = error.response;
    if (response != null) {
      final body = ApiResponseParser.decodeObjectFrom(response.data);
      return ApiException(
        ApiResponseParser.extractDetail(body) ??
            'Erro ao baixar arquivo de sincronização.',
        statusCode: response.statusCode,
      );
    }

    return ApiException(
      switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'Tempo esgotado ao baixar o arquivo de sincronização.',
        DioExceptionType.connectionError =>
          'Sem conexão com o servidor. Verifique sua internet.',
        _ => 'Falha ao baixar o arquivo de sincronização.',
      },
    );
  }
}
