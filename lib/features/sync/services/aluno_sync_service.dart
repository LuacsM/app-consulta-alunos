import 'package:dio/dio.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/api_response_parser.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/sync/data/students_local_dao.dart';
import 'package:consulta_alunos/features/sync/data/students_sync_api.dart';
import 'package:consulta_alunos/features/sync/data/sync_storage.dart';
import 'package:consulta_alunos/features/sync/models/sync_checkpoint.dart';
import 'package:consulta_alunos/features/sync/models/sync_result.dart';

typedef SyncProgressCallback = void Function(SyncProgress progress);

class AlunoSyncService {
  AlunoSyncService({
    required AuthRepository authRepository,
    StudentsSyncApi? syncApi,
    StudentsLocalDao? localDao,
    SyncStorage? syncStorage,
  })  : _authRepository = authRepository,
        _syncApi = syncApi ?? StudentsSyncApi(),
        _localDao = localDao ?? StudentsLocalDao(),
        _syncStorage = syncStorage ?? SyncStorage();

  final AuthRepository _authRepository;
  final StudentsSyncApi _syncApi;
  final StudentsLocalDao _localDao;
  final SyncStorage _syncStorage;

  Future<SyncResult> syncStudents({
    SyncProgressCallback? onProgress,
    bool resume = false,
  }) async {
    final token = await _authRepository.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Sessão expirada. Faça login novamente.');
    }

    SyncCheckpoint? initialCheckpoint;
    if (resume) {
      initialCheckpoint = await _syncStorage.getCheckpoint();
      if (initialCheckpoint == null || !initialCheckpoint.isValid) {
        throw ApiException('Não há sincronização pendente para continuar.');
      }
    } else {
      await _syncStorage.clearCheckpoint();
    }

    try {
      String? cursorUpdatedAt = initialCheckpoint?.cursorUpdatedAt;
      String? cursorCodAluno = initialCheckpoint?.cursorCodAluno;
      var hasNext = true;
      String? serverSyncAt = initialCheckpoint?.serverSyncAt;
      var pagesProcessed = initialCheckpoint?.pagesProcessed ?? 0;
      var itemsProcessed = initialCheckpoint?.itemsProcessed ?? 0;
      var sessionPagesProcessed = 0;
      var sessionItemsProcessed = 0;
      int? total = initialCheckpoint?.totalExpected;

      if (initialCheckpoint != null) {
        onProgress?.call(
          SyncProgress(
            pagesProcessed: pagesProcessed,
            itemsProcessed: itemsProcessed,
            total: total,
          ),
        );
      }

      while (hasNext) {
        final previousCursorUpdatedAt = cursorUpdatedAt;
        final previousCursorCodAluno = cursorCodAluno;

        final page = await _syncApi.fetchPage(
          token: token,
          cursorUpdatedAt: cursorUpdatedAt,
          cursorCodAluno: cursorCodAluno,
        );

        await _localDao.applySyncBatch(page.items);

        pagesProcessed++;
        sessionPagesProcessed++;
        itemsProcessed += page.items.length;
        sessionItemsProcessed += page.items.length;
        total ??= page.total;
        serverSyncAt = page.serverSyncAt ?? serverSyncAt;

        onProgress?.call(
          SyncProgress(
            pagesProcessed: pagesProcessed,
            itemsProcessed: itemsProcessed,
            total: total,
          ),
        );

        hasNext = page.hasNext;
        cursorUpdatedAt = page.nextCursorUpdatedAt;
        cursorCodAluno = page.nextCursorCodAluno;

        if (hasNext &&
            cursorUpdatedAt != null &&
            cursorCodAluno != null) {
          await _syncStorage.saveCheckpoint(
            SyncCheckpoint(
              cursorUpdatedAt: cursorUpdatedAt,
              cursorCodAluno: cursorCodAluno,
              itemsProcessed: itemsProcessed,
              pagesProcessed: pagesProcessed,
              totalExpected: total,
              serverSyncAt: serverSyncAt,
            ),
          );
        }

        if (hasNext &&
            cursorUpdatedAt == null &&
            cursorCodAluno == null) {
          break;
        }

        if (hasNext &&
            pagesProcessed > 1 &&
            cursorUpdatedAt == previousCursorUpdatedAt &&
            cursorCodAluno == previousCursorCodAluno) {
          break;
        }
      }

      final completedFully = !hasNext;

      if (completedFully) {
        await _syncStorage.clearCheckpoint();
        if (serverSyncAt != null && serverSyncAt.isNotEmpty) {
          await _syncStorage.saveLastSyncAt(serverSyncAt);
        }
      }

      return SyncResult(
        pagesProcessed: pagesProcessed,
        itemsProcessed: itemsProcessed,
        completedFully: completedFully,
        serverSyncAt: serverSyncAt,
        totalExpected: total,
        resumedFromCheckpoint: initialCheckpoint != null,
        sessionPagesProcessed: sessionPagesProcessed,
        sessionItemsProcessed: sessionItemsProcessed,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException error) {
    final response = error.response;
    if (response != null) {
      final body = ApiResponseParser.decodeObjectFrom(response.data);
      return ApiException(
        ApiResponseParser.extractDetail(body) ?? 'Erro ao sincronizar alunos.',
        statusCode: response.statusCode,
      );
    }

    return ApiException(
      switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'Tempo esgotado ao conectar com o servidor.',
        DioExceptionType.connectionError =>
          'Sem conexão com o servidor. Verifique se a API está ativa.',
        _ => 'Falha na comunicação com o servidor.',
      },
    );
  }

  Future<String?> getLastSyncAt() => _syncStorage.getLastSyncAt();

  Future<SyncCheckpoint?> getPendingCheckpoint() => _syncStorage.getCheckpoint();

  Future<void> clearPendingCheckpoint() => _syncStorage.clearCheckpoint();

  Future<int> getLocalStudentCount() => _localDao.countStudents();
}
