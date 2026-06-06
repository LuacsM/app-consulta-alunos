import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/view_models/login_view_model.dart';
import 'package:consulta_alunos/features/shell/main_shell_view.dart';
import 'package:consulta_alunos/shared/widgets/app_logo.dart';
import 'package:consulta_alunos/shared/widgets/input_field.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/primary_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(context.read<AuthRepository>()),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  Future<void> _handleLogin(BuildContext context) async {
    final vm = context.read<LoginViewModel>();
    final success = await vm.login();
    if (!context.mounted || !success) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShellView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: DismissKeyboard(
        child: SafeArea(
          child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 20),
                    Text('Consulta Alunos', style: AppTextStyles.appTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Bem Vindo! 👋',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    InputField(
                      label: 'E-mail institucional',
                      controller: vm.emailController,
                      hint: 'exemplo@escola.com.br',
                      leadingIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => vm.onFieldChanged(),
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      label: 'Senha de acesso',
                      controller: vm.passwordController,
                      hint: '••••••••',
                      leadingIcon: Icons.lock_outline,
                      obscureText: !vm.isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => vm.onFieldChanged(),
                      onSubmitted: (_) => _handleLogin(context),
                      trailing: IconButton(
                        icon: Icon(
                          vm.isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed:
                            DismissKeyboard.wrap(vm.togglePasswordVisibility),
                      ),
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          vm.errorMessage!,
                          style: AppTextStyles.cardBody.copyWith(
                            color: const Color(0xFFB91C1C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Entrar',
                      isLoading: vm.isLoading,
                      onPressed:
                          vm.canSubmit ? () => _handleLogin(context) : null,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: DismissKeyboard.wrap(vm.onForgotPassword),
                      child: const Text(
                        'Esqueci minha senha',
                        style: AppTextStyles.link,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Acesso restrito a funcionários autorizados da secretaria escolar.',
                      style: AppTextStyles.footer,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }
}
