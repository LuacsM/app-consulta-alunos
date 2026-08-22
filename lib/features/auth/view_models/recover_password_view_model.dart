import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';

class RecoverPasswordViewModel extends ChangeNotifier {
  RecoverPasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  final cpfController = TextEditingController();
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get canSubmit =>
      cpfController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty &&
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void onFieldChanged() {
    if (_errorMessage != null || _successMessage != null) {
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  Future<bool> recoverPassword() async {
    if (!canSubmit || _isLoading) return false;

    if (newPasswordController.text != confirmPasswordController.text) {
      _errorMessage = 'A nova senha e a confirmação não coincidem.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _successMessage = await _authRepository.recoverPassword(
        cpf: cpfController.text,
        phone: phoneController.text,
        newPassword: newPasswordController.text,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage =
          'Não foi possível recuperar a senha. Verifique sua internet.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cpfController.dispose();
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
