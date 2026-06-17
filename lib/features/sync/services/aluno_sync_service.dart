import 'dart:io';

import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/sync/data/students_local_dao.dart';
import 'package:consulta_alunos/features/sync/data/sync_download_api.dart';
import 'package:consulta_alunos/features/sync/data/sync_storage.dart';
import 'package:consulta_alunos/features/sync/models/sync_dump_checkpoint.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';
import 'package:consulta_alunos/features/sync/models/sync_result.dart';
import 'package:consulta_alunos/features/sync/services/jsonl_gzip_importer.dart';
import 'package:path_provider/path_provider.dart';

typedef SyncProgressCallback = void Function(SyncProgress progress);

class AlunoSyncService {
  AlunoSyncService({
    required AuthRepository authRepository,
    SyncDownloadApi? downloadApi,
    JsonlGzipImporter? importer,
    StudentsLocalDao? localDao,
    SyncStorage? syncStorage,
  })  : _authRepository = authRepository,
        _downloadApi = downloadApi ?? SyncDownloadApi(),
        _importer = importer ?? JsonlGzipImporter(),
        _localDao = localDao ?? StudentsLocalDao(),
        _syncStorage = syncStorage ?? SyncStorage();

  final AuthRepository _authRepository;
  final SyncDownloadApi _downloadApi;
  final JsonlGzipImporter _importer;
  final StudentsLocalDao _localDao;
  final SyncStorage _syncStorage;

  static const _archiveFileName = 'alunos_sync.jsonl.gz';

  Future<SyncResult> syncStudents({
    SyncProgressCallback? onProgress,
    bool resume = false,
    bool fullSync = false,
  }) async {
    final token = await _authRepository.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Sessão expirada. Faça login novamente.');
    }

    SyncDumpCheckpoint? checkpoint;
    if (resume) {
      checkpoint = await _syncStorage.getCheckpoint();
      if (checkpoint == null || !checkpoint.isValid) {
        throw ApiException('Não há sincronização pendente para continuar.');
      }
      final archive = File(checkpoint.archivePath);
      if (!await archive.exists()) {
        await _syncStorage.clearCheckpoint();
        throw ApiException(
          'Não foi possível continuar. Inicie uma nova sincronização.',
        );
      }
    } else {
      await _clearPreviousSyncFiles();
      await _syncStorage.clearCheckpoint();
    }

    var incremental = false;

    try {
      final archivePath = checkpoint?.archivePath ?? await _archivePath();

      if (checkpoint == null) {
        final clientMaxSyncUpdatedAt =
            fullSync ? null : await _syncStorage.getLastSyncAt();
        incremental =
            clientMaxSyncUpdatedAt != null && clientMaxSyncUpdatedAt.isNotEmpty;

        onProgress?.call(
          const SyncProgress(phase: SyncPhase.preparing),
        );

        var downloadStarted = false;
        await _downloadApi.downloadArchive(
          token: token,
          savePath: archivePath,
          clientMaxSyncUpdatedAt: incremental ? clientMaxSyncUpdatedAt : null,
          onProgress: (received, total) {
            if (!downloadStarted && (received > 0 || total > 0)) {
              downloadStarted = true;
            }
            onProgress?.call(
              SyncProgress(
                phase: downloadStarted
                    ? SyncPhase.downloading
                    : SyncPhase.preparing,
                downloadProgress:
                    total > 0 ? received / total : null,
              ),
            );
          },
        );

        await _syncStorage.saveCheckpoint(
          SyncDumpCheckpoint(
            phase: SyncDumpPhase.importing,
            archivePath: archivePath,
            linesProcessed: 0,
          ),
        );
      }

      final skipLines = checkpoint?.linesProcessed ?? 0;

      final importResult = await _importer.importFile(
        archivePath: archivePath,
        skipAlunoLines: skipLines,
        onProgress: ({
          required int itemsProcessed,
          required int total,
          required String generatedAt,
        }) {
          onProgress?.call(
            SyncProgress(
              phase: SyncPhase.importing,
              itemsProcessed: itemsProcessed,
              total: total,
            ),
          );

          _syncStorage.saveCheckpoint(
            SyncDumpCheckpoint(
              phase: SyncDumpPhase.importing,
              archivePath: archivePath,
              linesProcessed: itemsProcessed,
              totalExpected: total,
              generatedAt: generatedAt,
            ),
          );
        },
      );

      final finalGeneratedAt = importResult.metadata.generatedAt;
      final clientSyncVersion = importResult.metadata.clientSyncVersion;
      final totalExpected = importResult.metadata.total;

      final completedFully = importResult.itemsProcessed >= totalExpected;

      if (completedFully) {
        await _syncStorage.clearCheckpoint();
        if (clientSyncVersion.isNotEmpty) {
          await _syncStorage.saveLastSyncAt(clientSyncVersion);
        }
        try {
          await File(archivePath).delete();
        } catch (_) {}
      }

      return SyncResult(
        itemsProcessed: importResult.itemsProcessed,
        completedFully: completedFully,
        totalExpected: totalExpected,
        generatedAt: finalGeneratedAt,
        resumedFromCheckpoint: checkpoint != null,
        incremental: incremental,
      );
    } on ApiException {
      rethrow;
    } on FormatException catch (_) {
      throw ApiException(
        'Não foi possível usar os dados baixados. Tente sincronizar novamente.',
      );
    } catch (error) {
      throw ApiException('Não foi possível sincronizar. Tente novamente.');
    }
  }

  Future<String> _archivePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}${Platform.pathSeparator}$_archiveFileName';
  }

  Future<void> _clearPreviousSyncFiles() async {
    final path = await _archivePath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String?> getLastSyncAt() => _syncStorage.getLastSyncAt();

  Future<SyncDumpCheckpoint?> getPendingCheckpoint() =>
      _syncStorage.getCheckpoint();

  Future<void> clearPendingCheckpoint() async {
    final checkpoint = await _syncStorage.getCheckpoint();
    if (checkpoint != null) {
      try {
        await File(checkpoint.archivePath).delete();
      } catch (_) {}
    }
    await _syncStorage.clearCheckpoint();
  }

  Future<int> getLocalStudentCount() => _localDao.countStudents();
}
