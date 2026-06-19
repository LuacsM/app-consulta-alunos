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
  String? _lastGeneratedAt;
  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  String? _progressMessage;
  double? _syncProgress;
  SyncPhase? _syncPhase;
  SyncDumpCheckpoint? _pendingCheckpoint;

  String? get lastSyncAt => _lastSyncAt;
  String? get lastGeneratedAt => _lastGeneratedAt;
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

    return 'Sincronização incompleta. Toque em "Continuar sincronização".';
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
      _lastGeneratedAt = await _syncService.getLastGeneratedAt();
      _pendingCheckpoint = await _syncService.getPendingCheckpoint();
      _errorMessage = null;
      await _restoreRunningSession();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar as informações salvas.';
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
      _progressMessage = 'Salvando dados...';
    } else {
      _syncPhase = SyncPhase.preparing;
      _syncProgress = null;
      _progressMessage = _lastSyncAt == null
          ? 'Preparando os dados...'
          : 'Verificando novidades desde a última atualização...';
    }

    notifyListeners();
  }

  Future<void> _runSync({required bool resume, bool fullSync = false}) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    _progressMessage = resume
        ? 'Continuando de onde parou...'
        : fullSync || _lastSyncAt == null
            ? 'Preparando os dados...'
            : 'Verificando novidades desde a última atualização...';
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
                ? 'Preparando os dados...'
                : 'Verificando novidades desde a última atualização...',
            SyncPhase.downloading => progress.downloadProgress != null
                ? 'Baixando dados '
                    '(${(progress.downloadProgress! * 100).toStringAsFixed(0)}%)...'
                : 'Baixando dados dos alunos...',
            SyncPhase.importing => 'Salvando dados...',
          };

          notifyListeners();
          SyncForegroundService.updateProgress(progress);
        },
      );

      _lastSyncAt = await _syncService.getLastSyncAt();
      _lastGeneratedAt = await _syncService.getLastGeneratedAt();
      _pendingCheckpoint = await _syncService.getPendingCheckpoint();
      _progressMessage = null;
      _syncProgress = result.completedFully ? 1.0 : _syncProgress;

      if (!result.completedFully && result.totalExpected != null) {
        _successMessage =
            'Sincronização pausada. Toque em "Continuar sincronização".';
      } else if (result.incremental) {
        _successMessage = result.itemsProcessed == 0
            ? (result.upToDateMessage ??
                'Nenhuma novidade desde a última atualização.')
            : 'Atualização concluída. ${result.itemsProcessed} registro(s) alterado(s).';
      } else {
        final changed = result.changedCount ?? result.itemsProcessed;
        _successMessage = changed > 0
            ? 'Sincronização concluída. $changed registro(s) disponíveis offline.'
            : 'Sincronização concluída. Os dados já estão disponíveis offline.';
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
          ? 'Não foi possível sincronizar. Você pode continuar de onde parou.'
          : e is ApiException
              ? e.message
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
