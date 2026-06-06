import 'package:flutter/material.dart';

import 'package:consulta_alunos/core/network/api_exception.dart';

import 'package:consulta_alunos/features/sync/models/sync_checkpoint.dart';

import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';

import 'package:consulta_alunos/features/sync/services/sync_foreground_service.dart';



class SettingsViewModel extends ChangeNotifier {

  SettingsViewModel(this._syncService);



  final AlunoSyncService _syncService;



  String? _lastSyncAt;

  int _studentCount = 0;

  bool _isSyncing = false;

  String? _errorMessage;

  String? _successMessage;

  String? _progressMessage;

  double? _syncProgress;

  int _syncItemsProcessed = 0;

  int? _syncTotal;

  SyncCheckpoint? _pendingCheckpoint;



  String? get lastSyncAt => _lastSyncAt;

  int get studentCount => _studentCount;

  bool get isSyncing => _isSyncing;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  String? get progressMessage => _progressMessage;

  double? get syncProgress => _syncProgress;

  int get syncItemsProcessed => _syncItemsProcessed;

  int? get syncTotal => _syncTotal;

  bool get hasPendingSync =>

      _pendingCheckpoint != null && _pendingCheckpoint!.isValid;



  String? get pendingSyncMessage {

    final checkpoint = _pendingCheckpoint;

    if (checkpoint == null || !checkpoint.isValid) return null;



    if (checkpoint.totalExpected != null) {

      return 'Sincronização incompleta: ${checkpoint.itemsProcessed} de '

          '${checkpoint.totalExpected} alunos (${checkpoint.pagesProcessed} lote(s)).';

    }



    return 'Sincronização incompleta: ${checkpoint.itemsProcessed} alunos '

        'em ${checkpoint.pagesProcessed} lote(s).';

  }



  Future<void> load() async {

    try {

      _lastSyncAt = await _syncService.getLastSyncAt();

      _studentCount = await _syncService.getLocalStudentCount();

      _pendingCheckpoint = await _syncService.getPendingCheckpoint();

    } catch (e) {

      _errorMessage = 'Não foi possível ler os dados locais: $e';

    }

    notifyListeners();

  }



  Future<void> syncNow() async {

    await _runSync(resume: hasPendingSync);

  }



  Future<void> resumeSync() async {

    await _runSync(resume: true);

  }



  Future<void> restartSync() async {

    await _runSync(resume: false);

  }



  Future<void> _runSync({required bool resume}) async {

    if (_isSyncing) return;



    _isSyncing = true;

    _errorMessage = null;

    _successMessage = null;

    _progressMessage = resume

        ? 'Retomando sincronização...'

        : 'Iniciando sincronização...';

    _syncProgress = resume ? _pendingCheckpoint?.progressFraction : null;

    _syncItemsProcessed = resume ? _pendingCheckpoint?.itemsProcessed ?? 0 : 0;

    _syncTotal = resume ? _pendingCheckpoint?.totalExpected : null;

    notifyListeners();



    try {

      try {

        await SyncForegroundService.requestPermissions();

        await SyncForegroundService.start();

      } catch (_) {

        // A sincronização continua mesmo se a notificação falhar.

      }



      final result = await _syncService.syncStudents(

        resume: resume,

        onProgress: (progress) {

          _syncItemsProcessed = progress.itemsProcessed;

          _syncTotal = progress.total;

          _syncProgress = progress.progressFraction;

          _progressMessage = progress.total != null

              ? 'Baixando lote ${progress.pagesProcessed} '

                  '(${progress.itemsProcessed} de ${progress.total} alunos)...'

              : 'Baixando lote ${progress.pagesProcessed} '

                  '(${progress.itemsProcessed} alunos)...';

          notifyListeners();



          SyncForegroundService.updateProgress(

            itemsProcessed: progress.itemsProcessed,

            total: progress.total,

            pagesProcessed: progress.pagesProcessed,

          );

        },

      );



      _lastSyncAt = await _syncService.getLastSyncAt();

      _studentCount = await _syncService.getLocalStudentCount();

      _pendingCheckpoint = await _syncService.getPendingCheckpoint();

      _progressMessage = null;

      _syncProgress = result.completedFully ? 1.0 : _syncProgress;



      if (result.itemsProcessed == 0) {

        _successMessage =

            'Sincronização concluída, mas nenhum aluno foi retornado pela API.';

      } else if (!result.completedFully && result.totalExpected != null) {

        _successMessage =

            'Sincronização pausada em ${result.itemsProcessed} de '

            '${result.totalExpected} aluno(s). Toque em "Continuar sincronização".';

      } else if (result.resumedFromCheckpoint) {

        _successMessage =

            'Sincronização concluída: ${result.itemsProcessed} registro(s) '

            'em ${result.pagesProcessed} lote(s). '

            'Nesta sessão: +${result.sessionItemsProcessed} em '

            '${result.sessionPagesProcessed} lote(s).';

      } else {

        _successMessage =

            'Sincronização concluída: ${result.itemsProcessed} registro(s) '

            'em ${result.pagesProcessed} lote(s).';

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

}


