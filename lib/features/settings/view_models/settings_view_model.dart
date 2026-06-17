import 'package:flutter/material.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';
import 'package:consulta_alunos/features/sync/services/sync_session_controller.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._syncSession) {
    _syncSession.addListener(_onSessionChanged);
  }

  final SyncSessionController _syncSession;

  String? get lastSyncAt => _syncSession.lastSyncAt;
  bool get isSyncing => _syncSession.isSyncing;
  String? get errorMessage => _syncSession.errorMessage;
  String? get successMessage => _syncSession.successMessage;
  String? get progressMessage => _syncSession.progressMessage;
  double? get syncProgress => _syncSession.syncProgress;
  SyncPhase? get syncPhase => _syncSession.syncPhase;
  bool get hasPendingSync => _syncSession.hasPendingSync;
  String? get pendingSyncMessage => _syncSession.pendingSyncMessage;

  Future<void> load() => _syncSession.load();

  Future<void> syncNow() => _syncSession.syncNow();

  Future<void> restartSync() => _syncSession.restartSync();

  void _onSessionChanged() => notifyListeners();

  @override
  void dispose() {
    _syncSession.removeListener(_onSessionChanged);
    super.dispose();
  }
}
