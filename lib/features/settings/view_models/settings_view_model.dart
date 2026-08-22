import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/models/user_info.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';
import 'package:consulta_alunos/features/sync/services/sync_session_controller.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._syncSession, this._authRepository) {
    _syncSession.addListener(_onSessionChanged);
  }

  final SyncSessionController _syncSession;
  final AuthRepository _authRepository;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  UserInfo? _currentUser;
  bool _isPasswordFormVisible = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChangingPassword = false;
  bool _isLoggingOut = false;
  String? _accountErrorMessage;
  String? _accountSuccessMessage;

  String? get lastSyncAt => _syncSession.lastSyncAt;
  String? get lastGeneratedAt => _syncSession.lastGeneratedAt;
  bool get isSyncing => _syncSession.isSyncing;
  String? get errorMessage => _syncSession.errorMessage;
  String? get successMessage => _syncSession.successMessage;
  String? get progressMessage => _syncSession.progressMessage;
  double? get syncProgress => _syncSession.syncProgress;
  SyncPhase? get syncPhase => _syncSession.syncPhase;
  bool get hasPendingSync => _syncSession.hasPendingSync;
  String? get pendingSyncMessage => _syncSession.pendingSyncMessage;
  UserInfo? get currentUser => _currentUser;
  bool get isPasswordFormVisible => _isPasswordFormVisible;
  bool get isCurrentPasswordVisible => _isCurrentPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isChangingPassword => _isChangingPassword;
  bool get isLoggingOut => _isLoggingOut;
  String? get accountErrorMessage => _accountErrorMessage;
  String? get accountSuccessMessage => _accountSuccessMessage;

  bool get canChangePassword =>
      currentPasswordController.text.isNotEmpty &&
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

  Future<void> load() async {
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
    await _syncSession.load();
  }

  Future<void> syncNow() => _syncSession.syncNow();

  Future<void> restartSync() => _syncSession.restartSync();

  void togglePasswordForm() {
    _isPasswordFormVisible = !_isPasswordFormVisible;
    if (!_isPasswordFormVisible) {
      _clearPasswordForm();
    }
    notifyListeners();
  }

  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void onPasswordFieldChanged() {
    if (_accountErrorMessage != null || _accountSuccessMessage != null) {
      _accountErrorMessage = null;
      _accountSuccessMessage = null;
      notifyListeners();
    }
  }

  Future<bool> changePassword() async {
    if (!canChangePassword || _isChangingPassword) return false;

    final newPassword = newPasswordController.text;
    if (newPassword != confirmPasswordController.text) {
      _accountErrorMessage = 'A nova senha e a confirmação não coincidem.';
      notifyListeners();
      return false;
    }

    _isChangingPassword = true;
    _accountErrorMessage = null;
    _accountSuccessMessage = null;
    notifyListeners();

    try {
      final message = await _authRepository.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPassword,
      );
      _clearPasswordForm();
      _isPasswordFormVisible = false;
      _accountSuccessMessage = message;
      return true;
    } on ApiException catch (e) {
      _accountErrorMessage = e.message;
      return false;
    } catch (_) {
      _accountErrorMessage =
          'Não foi possível alterar a senha. Tente novamente.';
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    if (_isLoggingOut || _syncSession.isSyncing) return false;

    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  void _clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _isCurrentPasswordVisible = false;
    _isNewPasswordVisible = false;
    _isConfirmPasswordVisible = false;
  }

  void _onSessionChanged() => notifyListeners();

  @override
  void dispose() {
    _syncSession.removeListener(_onSessionChanged);
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
