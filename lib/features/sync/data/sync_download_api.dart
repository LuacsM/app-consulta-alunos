import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/config/api_config.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/api_response_parser.dart';
import 'package:consulta_alunos/features/sync/models/sync_download_result.dart';

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
        headers: {'accept': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Future<SyncDownloadResult> downloadArchive({
    required String token,
    required String savePath,
    String? clientMaxSyncUpdatedAt,
    DownloadProgressCallback? onProgress,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/alunos/sync-download',
        queryParameters: {
          if (clientMaxSyncUpdatedAt != null &&
              clientMaxSyncUpdatedAt.isNotEmpty)
            'client_max_sync_updated_at': clientMaxSyncUpdatedAt,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 307) {
        final location = response.headers.value('location');
        if (location == null || location.isEmpty) {
          throw ApiException(
            'Resposta inválida do servidor de sincronização.',
          );
        }

        await _downloadFromUrl(
          url: location,
          savePath: savePath,
          onProgress: onProgress,
        );
        return SyncDownloadResult.downloaded(savePath);
      }

      if (response.statusCode == 200) {
        final body = ApiResponseParser.decodeObjectFrom(response.data);
        if (_isUpToDateResponse(body)) {
          return SyncDownloadResult.upToDate(
            maxSyncUpdatedAt:
                _extractMaxSyncUpdatedAt(body) ?? clientMaxSyncUpdatedAt,
            generatedAt: body['generated_at'] as String?,
            message: body['message'] as String?,
            total: body['total'] as int?,
          );
        }

        throw ApiException(
          _extractErrorMessage(body) ?? 'Não foi possível baixar os dados.',
          statusCode: response.statusCode,
        );
      }

      final body = ApiResponseParser.decodeObjectFrom(response.data);
      throw ApiException(
        ApiResponseParser.extractDetail(body) ??
            'Não foi possível baixar os dados.',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<void> _downloadFromUrl({
    required String url,
    required String savePath,
    DownloadProgressCallback? onProgress,
  }) async {
    final downloader = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 30),
        headers: {'accept': 'application/gzip'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final response = await downloader.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      deleteOnError: true,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Não foi possível baixar os dados.',
        statusCode: response.statusCode,
      );
    }
  }

  bool _isUpToDateResponse(Map<String, dynamic> body) {
    if (body['status'] == 'client_up_to_date') return true;

    final downloadRequired = body['download_required'];
    if (downloadRequired is bool) return !downloadRequired;

    return false;
  }

  String? _extractMaxSyncUpdatedAt(Map<String, dynamic> body) {
    for (final key in [
      'server_max_sync_updated_at',
      'max_sync_updated_at',
      'client_max_sync_updated_at',
    ]) {
      final value = body[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _extractErrorMessage(Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    return ApiResponseParser.extractDetail(body);
  }

  ApiException _mapDioError(DioException error) {
    final response = error.response;
    if (response != null) {
      final body = ApiResponseParser.decodeObjectFrom(response.data);
      return ApiException(
        ApiResponseParser.extractDetail(body) ??
            'Não foi possível baixar os dados.',
        statusCode: response.statusCode,
      );
    }

    return ApiException(
      switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'A atualização demorou demais. Tente novamente.',
        DioExceptionType.connectionError =>
          'Sem conexão com a internet. Verifique sua rede.',
        _ => 'Não foi possível baixar os dados.',
      },
    );
  }
}
