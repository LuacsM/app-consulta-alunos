import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/network_utils.dart';
import 'package:consulta_alunos/core/utils/formatters.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/search/data/students_api.dart';
import 'package:consulta_alunos/features/search/models/student.dart';
import 'package:consulta_alunos/features/sync/data/students_local_dao.dart';

class StudentsRepository {
  StudentsRepository({
    required AuthRepository authRepository,
    StudentsApi? api,
    StudentsLocalDao? localDao,
  })  : _authRepository = authRepository,
        _api = api ?? StudentsApi(),
        _localDao = localDao ?? StudentsLocalDao();

  final AuthRepository _authRepository;
  final StudentsApi _api;
  final StudentsLocalDao _localDao;

  Future<List<Student>> searchByName(String nome) async {
    final query = nome.trim();
    if (query.isEmpty) return [];

    try {
      final token = await _requireToken();
      final results = await _api.searchByName(nome: query, token: token);
      await _localDao.upsertStudents(results);
      return results;
    } on ApiException {
      rethrow;
    } catch (error) {
      if (NetworkUtils.isConnectionError(error)) {
        return _localDao.searchByName(query);
      }
      rethrow;
    }
  }

  Future<Student> searchByCpf(String cpf) async {
    final digits = Formatters.digitsOnly(cpf);
    if (digits.isEmpty) {
      throw ApiException('Informe um CPF válido.');
    }

    try {
      final token = await _requireToken();
      final student = await _api.searchByCpf(cpf: digits, token: token);
      await _localDao.upsertStudents([student]);
      return student;
    } on ApiException {
      rethrow;
    } catch (error) {
      if (NetworkUtils.isConnectionError(error)) {
        final results = await _localDao.searchByCpf(digits);
        if (results.isEmpty) {
          throw ApiException('Aluno não encontrado no modo offline.');
        }
        return results.first;
      }
      rethrow;
    }
  }

  Future<String> _requireToken() async {
    final token = await _authRepository.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Sessão expirada. Faça login novamente.');
    }
    return token;
  }
}
