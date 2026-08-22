import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/api_response_parser.dart';
import 'package:consulta_alunos/core/network/dio_client.dart';
import 'package:consulta_alunos/features/search/models/student.dart';

class StudentsApi {
  StudentsApi({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  Future<List<Student>> searchByName({
    required String nome,
    required String token,
  }) async {
    final response = await _dio.get<dynamic>(
      '/alunos/buscar-por-nome',
      queryParameters: {'nome': nome},
      options: Options(headers: _authHeaders(token)),
    );

    if (response.statusCode == 200) {
      return ApiResponseParser
          .decodeListFrom(response.data)
          .map((item) => Student.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _errorFromResponse(response);
  }

  Future<List<Student>> searchByCpf({
    required String cpf,
    required String token,
  }) async {
    final response = await _dio.get<dynamic>(
      '/alunos/buscar-por-cpf',
      queryParameters: {'cpf': cpf},
      options: Options(headers: _authHeaders(token)),
    );

    if (response.statusCode == 200) {
      return ApiResponseParser
          .decodeStudentListFrom(response.data)
          .map((item) => Student.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _errorFromResponse(response);
  }

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
      };

  ApiException _errorFromResponse(Response<dynamic> response) {
    final body = ApiResponseParser.decodeObjectFrom(response.data);
    return ApiException(
      ApiResponseParser.extractDetail(body) ?? 'Erro ao buscar aluno.',
      statusCode: response.statusCode,
    );
  }
}
