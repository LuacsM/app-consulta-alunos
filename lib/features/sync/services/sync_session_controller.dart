import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/features/sync/models/sync_dump_checkpoint.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';
import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';
import 'package:consulta_alunos/features/sync/services/sync_foreground_service.dart';

/// Orquestra a sincronização no nível do app para sobreviver à navegação
/// e restaurar o estado ao retornar do segundo plano.
class SyncSessionController extends ChangeNotifier with WidgetsBindingObserver {
  SyncSessionController(this._syncService) {
    WidgetsBinding.instance.addObserver(this);
    _restoreRunningSession();
  }

  final AlunoSyncService _syncService;

  String? _lastSyncAt;
  int _studentCount = 0;
  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  String? _progressMessage;
  double? _syncProgress;
  SyncPhase? _syncPhase;
  SyncDumpCheckpoint? _pendingCheckpoint;

  String? get lastSyncAt => _lastSyncAt;
  int get studentCount => _studentCount;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get progressMessage => _progressMessage;
  double? get syncProgress => _syncProgress;
  SyncPhase? get syncPhase => _syncPhase;
  bool get hasPendingSync =>
      _pendingCheckpoint != null && _pendingCheckpoint!.isValid;

  String? get pendingSyncMessage {
    final checkpoint = _pendingCheckpoint;
    if (checkpoint == null || !checkpoint.isValid) return null;

    if (checkpoint.totalExpected != null) {
      return 'Importação incompleta: ${checkpoint.linesProcessed} de '
          '${checkpoint.totalExpected} alunos.';
    }

    return 'Importação incompleta: ${checkpoint.linesProcessed} alunos '
        'processados.';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreRunningSession();
    }
  }

  Future<void> load() async {
    try {
      _lastSyncAt = await _syncService.getLastSyncAt();
      _studentCount = await _syncService.getLocalStudentCount();
      _pendingCheckpoint = await _syncService.getPendingCheckpoint();
      _errorMessage = null;
      await _restoreRunningSession();
    } catch (e) {
      _errorMessage = 'Não foi possível ler os dados locais: $e';
    }
    notifyListeners();
  }

  Future<void> syncNow() async {
    await _runSync(resume: hasPendingSync);
  }

  Future<void> restartSync() async {
    await _syncService.clearPendingCheckpoint();
    _pendingCheckpoint = null;
    await _runSync(resume: false, fullSync: true);
  }

  Future<void> _restoreRunningSession() async {
    if (!await _isForegroundServiceRunning()) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    _pendingCheckpoint = await _syncService.getPendingCheckpoint();

    if (_pendingCheckpoint != null && _pendingCheckpoint!.isValid) {
      _syncPhase = SyncPhase.importing;
      _syncProgress = _pendingCheckpoint!.progressFraction;
      _progressMessage = _pendingCheckpoint!.totalExpected != null
          ? 'Importando ${_pendingCheckpoint!.linesProcessed} de '
              '${_pendingCheckpoint!.totalExpected} alunos...'
          : 'Importando ${_pendingCheckpoint!.linesProcessed} alunos...';
    } else {
      _syncPhase = SyncPhase.preparing;
      _syncProgress = null;
      _progressMessage = _lastSyncAt == null
          ? 'Servidor preparando arquivo de sincronização...'
          : 'Buscando alterações desde a última sincronização...';
    }

    notifyListeners();
  }

  Future<void> _runSync({required bool resume, bool fullSync = false}) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    _progressMessage = resume
        ? 'Retomando importação...'
        : fullSync || _lastSyncAt == null
            ? 'Servidor preparando arquivo de sincronização...'
            : 'Buscando alterações desde a última sincronização...';
    _syncProgress = resume ? _pendingCheckpoint?.progressFraction : null;
    _syncPhase = resume ? SyncPhase.importing : SyncPhase.preparing;
    notifyListeners();

    try {
      try {
        await SyncForegroundService.requestPermissions();
        await SyncForegroundService.start(resume: resume);
      } catch (_) {
        // A sincronização continua mesmo se a notificação falhar.
      }

      final result = await _syncService.syncStudents(
        resume: resume,
        fullSync: fullSync,
        onProgress: (progress) {
          _syncPhase = progress.phase;
          _syncProgress = progress.overallProgressFraction;

          _progressMessage = switch (progress.phase) {
            SyncPhase.preparing => fullSync || _lastSyncAt == null
                ? 'Servidor preparando arquivo de sincronização...'
                : 'Buscando alterações desde a última sincronização...',
            SyncPhase.downloading => progress.downloadProgress != null
                ? 'Baixando arquivo '
                    '(${(progress.downloadProgress! * 100).toStringAsFixed(0)}%)...'
                : 'Baixando arquivo compactado...',
            SyncPhase.importing => progress.total != null
                ? 'Importando ${progress.itemsProcessed} de '
                    '${progress.total} alunos...'
                : 'Importando ${progress.itemsProcessed} alunos...',
          };

          notifyListeners();
          SyncForegroundService.updateProgress(progress);
        },
      );

      _lastSyncAt = await _syncService.getLastSyncAt();
      _studentCount = await _syncService.getLocalStudentCount();
      _pendingCheckpoint = await _syncService.getPendingCheckpoint();
      _progressMessage = null;
      _syncProgress = result.completedFully ? 1.0 : _syncProgress;

      if (!result.completedFully && result.totalExpected != null) {
        _successMessage =
            'Importação pausada em ${result.itemsProcessed} de '
            '${result.totalExpected} aluno(s). Toque em "Continuar sincronização".';
      } else if (result.incremental) {
        _successMessage = result.itemsProcessed == 0
            ? 'Nenhuma alteração encontrada desde a última sincronização.'
            : 'Atualização concluída: ${result.itemsProcessed} aluno(s) '
                'atualizados.';
      } else {
        _successMessage =
            'Sincronização concluída: ${result.itemsProcessed} aluno(s) '
            'importados do arquivo JSONL.';
      }

      await SyncForegroundService.finish(message: _successMessage!);
    } on ApiException catch (e) {
      _progressMessage = null;
      _pendingCheckpoint = await _syncService.getPendingCheckpoint();
      _errorMessage = hasPendingSync
          ? '${e.message} Você pode continuar de onde parou.'
          : e.message;
      await SyncForegroundService.finish(
        message: 'Erro na sincronização: ${e.message}',
      );
    } catch (e) {
      _progressMessage = null;
      _pendingCheckpoint = await _syncService.getPendingCheckpoint();
      _errorMessage = hasPendingSync
          ? 'Não foi possível sincronizar: $e Você pode continuar de onde parou.'
          : 'Não foi possível sincronizar: $e';
      await SyncForegroundService.stop();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> _isForegroundServiceRunning() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return false;
    return FlutterForegroundTask.isRunningService;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
