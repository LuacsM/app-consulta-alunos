import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/core/utils/cpf_input_formatter.dart';
import 'package:consulta_alunos/core/utils/phone_input_formatter.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/view_models/recover_password_view_model.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/input_field.dart';
import 'package:consulta_alunos/shared/widgets/primary_button.dart';
import 'package:consulta_alunos/shared/widgets/wavy_top_navbar.dart';

class RecoverPasswordView extends StatelessWidget {
  const RecoverPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          RecoverPasswordViewModel(context.read<AuthRepository>()),
      child: const _RecoverPasswordBody(),
    );
  }
}

class _RecoverPasswordBody extends StatelessWidget {
  const _RecoverPasswordBody();

  Future<void> _handleSubmit(BuildContext context) async {
    final vm = context.read<RecoverPasswordViewModel>();
    await vm.recoverPassword();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecoverPasswordViewModel>();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: DismissKeyboard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WavyTopNavbar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + bottomInset),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recuperar senha',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informe seu CPF, telefone cadastrado e defina uma '
                      'nova senha.',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 24),
                    InputField(
                      label: 'CPF',
                      controller: vm.cpfController,
                      hint: '000.000.000-00',
                      leadingIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: const [CpfInputFormatter()],
                      onChanged: (_) => vm.onFieldChanged(),
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      label: 'Telefone',
                      controller: vm.phoneController,
                      hint: '(92) 98208-1756',
                      leadingIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: const [PhoneInputFormatter()],
                      onChanged: (_) => vm.onFieldChanged(),
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      label: 'Nova senha',
                      controller: vm.newPasswordController,
                      hint: '••••••••',
                      leadingIcon: Icons.lock_reset_outlined,
                      obscureText: !vm.isNewPasswordVisible,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => vm.onFieldChanged(),
                      trailing: IconButton(
                        icon: Icon(
                          vm.isNewPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed:
                            DismissKeyboard.wrap(vm.toggleNewPasswordVisibility),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      label: 'Confirmar nova senha',
                      controller: vm.confirmPasswordController,
                      hint: '••••••••',
                      leadingIcon: Icons.lock_reset_outlined,
                      obscureText: !vm.isConfirmPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => vm.onFieldChanged(),
                      onSubmitted: (_) => _handleSubmit(context),
                      trailing: IconButton(
                        icon: Icon(
                          vm.isConfirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: DismissKeyboard.wrap(
                          vm.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          vm.errorMessage!,
                          style: AppTextStyles.cardBody.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (vm.successMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          vm.successMessage!,
                          style: AppTextStyles.cardBody.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    if (vm.successMessage == null)
                      PrimaryButton(
                        label: 'Redefinir senha',
                        isLoading: vm.isLoading,
                        onPressed: vm.canSubmit
                            ? () => _handleSubmit(context)
                            : null,
                      )
                    else
                      PrimaryButton(
                        label: 'Voltar ao login',
                        icon: Icons.login_outlined,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
