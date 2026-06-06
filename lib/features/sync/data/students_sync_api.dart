import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/api_response_parser.dart';
import 'package:consulta_alunos/core/network/dio_client.dart';
import 'package:consulta_alunos/features/sync/models/sync_response.dart';

class StudentsSyncApi {
  StudentsSyncApi({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  Future<SyncResponse> fetchPage({
    required String token,
    int size = 500,
    String? updatedAfter,
    String? cursorUpdatedAt,
    String? cursorCodAluno,
    String? codEscola,
  }) async {
    final response = await _dio.get<dynamic>(
      '/alunos/sync',
      queryParameters: {
        'size': size,
        'updated_after': ?updatedAfter,
        'cursor_updated_at': ?cursorUpdatedAt,
        'cursor_cod_aluno': ?cursorCodAluno,
        'cod_escola': ?codEscola,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return SyncResponse.fromJson(
        ApiResponseParser.decodeObjectFrom(response.data),
      );
    }

    final body = ApiResponseParser.decodeObjectFrom(response.data);
    throw ApiException(
      ApiResponseParser.extractDetail(body) ?? 'Erro ao sincronizar alunos.',
      statusCode: response.statusCode,
    );
  }
}
