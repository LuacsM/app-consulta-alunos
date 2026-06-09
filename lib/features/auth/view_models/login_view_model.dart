import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/auth/device_auth_service.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/network/network_utils.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(
    this._authRepository, {
    bool showOfflineOption = false,
  }) : _showOfflineOption = showOfflineOption;

  final AuthRepository _authRepository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isOfflineLoading = false;
  bool _showOfflineOption;
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  bool get isOfflineLoading => _isOfflineLoading;
  bool get showOfflineOption => _showOfflineOption;
  String? get errorMessage => _errorMessage;

  bool get canSubmit =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login() async {
    if (!canSubmit || _isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (error) {
      _errorMessage =
          'Não foi possível conectar ao servidor. Verifique sua internet.';
      if (NetworkUtils.isConnectionError(error) &&
          await _authRepository.hasStoredSession()) {
        _showOfflineOption = true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startOfflineSession() async {
    if (_isOfflineLoading) return false;

    _isOfflineLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _authRepository.startOfflineSession();
    } on DeviceAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage =
          'Não foi possível iniciar a sessão offline. Tente novamente.';
      return false;
    } finally {
      _isOfflineLoading = false;
      notifyListeners();
    }
  }

  void onFieldChanged() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
