import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
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
    } catch (_) {
      _errorMessage =
          'Não foi possível conectar ao servidor. Verifique se a API está ativa.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onFieldChanged() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void onForgotPassword() {
    // TODO: navegar para recuperação de senha
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
