import 'package:flutter/material.dart';
import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._syncService);

  final AlunoSyncService _syncService;

  String? _lastSyncAt;
  int _studentCount = 0;
  String? _errorMessage;

  String? get lastSyncAt => _lastSyncAt;
  int get studentCount => _studentCount;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    try {
      _lastSyncAt = await _syncService.getLastSyncAt();
      _studentCount = await _syncService.getLocalStudentCount();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Não foi possível ler os dados locais: $e';
    }
    notifyListeners();
  }
}
