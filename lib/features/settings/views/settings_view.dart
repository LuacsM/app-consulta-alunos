import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/core/utils/formatters.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/models/user_info.dart';
import 'package:consulta_alunos/features/auth/views/login_view.dart';
import 'package:consulta_alunos/features/settings/view_models/settings_view_model.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';
import 'package:consulta_alunos/features/sync/services/sync_session_controller.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/document_search_animation.dart';
import 'package:consulta_alunos/shared/widgets/info_card.dart';
import 'package:consulta_alunos/shared/widgets/input_field.dart';
import 'package:consulta_alunos/shared/widgets/sync_steps_indicator.dart';
import 'package:consulta_alunos/shared/widgets/primary_button.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(
        context.read<SyncSessionController>(),
        context.read<AuthRepository>(),
      )..load(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  Future<void> _handleLogout(BuildContext context) async {
    final vm = context.read<SettingsViewModel>();
    final success = await vm.logout();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginView()),
        (_) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível sair. Tente novamente.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return DismissKeyboard(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajustes', style: AppTextStyles.screenTitle),
            const SizedBox(height: 24),
            if (vm.currentUser != null) ...[
              _SettingsSection(
                title: 'Conta',
                child: _AccountCard(
                  user: vm.currentUser!,
                  onLogout: () => _handleLogout(context),
                ),
              ),
              const SizedBox(height: 28),
            ],
            _SettingsSection(
              title: 'Sincronização',
              subtitle:
                  'Atualize os dados dos alunos para consultar sem internet.',
              child: _SyncSection(
                lastGeneratedAt: vm.lastGeneratedAt,
                lastSyncAt: vm.lastSyncAt,
                hasPendingSync: vm.hasPendingSync,
                pendingSyncMessage: vm.pendingSyncMessage,
                isSyncing: vm.isSyncing,
                syncPhase: vm.syncPhase,
                syncProgress: vm.syncProgress,
                progressMessage: vm.progressMessage,
                successMessage: vm.successMessage,
                errorMessage: vm.errorMessage,
                onSyncNow: vm.syncNow,
                onRestartSync: vm.restartSync,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: AppTextStyles.subtitle),
        ],
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _SyncSection extends StatelessWidget {
  const _SyncSection({
    required this.lastGeneratedAt,
    required this.lastSyncAt,
    required this.hasPendingSync,
    required this.pendingSyncMessage,
    required this.isSyncing,
    required this.syncPhase,
    required this.syncProgress,
    required this.progressMessage,
    required this.successMessage,
    required this.errorMessage,
    required this.onSyncNow,
    required this.onRestartSync,
  });

  final String? lastGeneratedAt;
  final String? lastSyncAt;
  final bool hasPendingSync;
  final String? pendingSyncMessage;
  final bool isSyncing;
  final SyncPhase? syncPhase;
  final double? syncProgress;
  final String? progressMessage;
  final String? successMessage;
  final String? errorMessage;
  final Future<void> Function() onSyncNow;
  final Future<void> Function() onRestartSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoTile(
            icon: Icons.sync_outlined,
            label: 'Última sincronização',
            value: _formatGeneratedAt(lastGeneratedAt, lastSyncAt),
            bordered: false,
          ),
          if (lastSyncAt != null && lastSyncAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.update_outlined,
              label: 'Dados dos alunos atualizados em',
              value: Formatters.formatIsoDateTime(lastSyncAt),
              bordered: false,
            ),
          ],
          if (hasPendingSync && pendingSyncMessage != null) ...[
            const SizedBox(height: 12),
            InfoCard(
              title: 'Sincronização pendente',
              message: pendingSyncMessage!,
              icon: Icons.pause_circle_outline,
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: isSyncing
                ? 'Sincronizando...'
                : hasPendingSync
                    ? 'Continuar sincronização'
                    : 'Sincronizar alunos',
            icon: hasPendingSync
                ? Icons.play_arrow_outlined
                : Icons.cloud_download_outlined,
            onPressed: isSyncing ? null : onSyncNow,
          ),
          if (hasPendingSync && !isSyncing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onRestartSync,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Reiniciar do zero',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (isSyncing && syncPhase != null) ...[
            const SizedBox(height: 20),
            SyncStepsIndicator(currentPhase: syncPhase!),
            const SizedBox(height: 20),
            const DocumentSearchAnimation(),
            if (syncProgress != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: syncProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(syncProgress! * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (progressMessage != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Text(
                  progressMessage!,
                  style: AppTextStyles.cardBody.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Text(
                _phaseHint(syncPhase!),
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (successMessage != null) ...[
            const SizedBox(height: 16),
            InfoCard(
              title: 'Sincronização',
              message: successMessage!,
              icon: Icons.check_circle_outline,
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            InfoCard(
              title: 'Erro na sincronização',
              message: errorMessage!,
              icon: Icons.error_outline,
            ),
          ],
          if (!isSyncing) ...[
            const SizedBox(height: 16),
            const InfoCard(
              title: 'Consulta sem internet',
              message:
                  'Baixe os dados dos alunos para consultar mesmo offline. '
                  'A atualização pode levar alguns minutos.',
            ),
          ],
        ],
      ),
    );
  }

  String _formatGeneratedAt(String? generatedAt, String? maxSyncUpdatedAt) {
    if (generatedAt != null && generatedAt.isNotEmpty) {
      return Formatters.formatIsoDateTime(generatedAt);
    }
    if (maxSyncUpdatedAt != null && maxSyncUpdatedAt.isNotEmpty) {
      return Formatters.formatIsoDateTime(maxSyncUpdatedAt);
    }
    return 'Nunca sincronizado';
  }

  String _phaseHint(SyncPhase phase) {
    return switch (phase) {
      SyncPhase.preparing =>
        'Aguarde enquanto preparamos os dados. Isso pode levar alguns minutos.',
      SyncPhase.downloading =>
        'Baixando os dados dos alunos para o seu dispositivo.',
      SyncPhase.importing => 'Salvando os alunos no aplicativo.',
    };
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.user,
    required this.onLogout,
  });

  final UserInfo user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nomeCompleto, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppTextStyles.cardBody),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
            title: const Text('Alterar senha'),
            trailing: Icon(
              vm.isPasswordFormVisible
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: AppColors.textSecondary,
            ),
            onTap: vm.togglePasswordForm,
          ),
          if (vm.isPasswordFormVisible) ...[
            const SizedBox(height: 8),
            InputField(
              label: 'Senha atual',
              controller: vm.currentPasswordController,
              hint: '••••••••',
              leadingIcon: Icons.lock_outline,
              obscureText: !vm.isCurrentPasswordVisible,
              textInputAction: TextInputAction.next,
              onChanged: (_) => vm.onPasswordFieldChanged(),
              trailing: IconButton(
                icon: Icon(
                  vm.isCurrentPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed:
                    DismissKeyboard.wrap(vm.toggleCurrentPasswordVisibility),
              ),
            ),
            const SizedBox(height: 12),
            InputField(
              label: 'Nova senha',
              controller: vm.newPasswordController,
              hint: '••••••••',
              leadingIcon: Icons.lock_reset_outlined,
              obscureText: !vm.isNewPasswordVisible,
              textInputAction: TextInputAction.next,
              onChanged: (_) => vm.onPasswordFieldChanged(),
              trailing: IconButton(
                icon: Icon(
                  vm.isNewPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: DismissKeyboard.wrap(vm.toggleNewPasswordVisibility),
              ),
            ),
            const SizedBox(height: 12),
            InputField(
              label: 'Confirmar nova senha',
              controller: vm.confirmPasswordController,
              hint: '••••••••',
              leadingIcon: Icons.lock_reset_outlined,
              obscureText: !vm.isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onChanged: (_) => vm.onPasswordFieldChanged(),
              onSubmitted: (_) => vm.changePassword(),
              trailing: IconButton(
                icon: Icon(
                  vm.isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed:
                    DismissKeyboard.wrap(vm.toggleConfirmPasswordVisibility),
              ),
            ),
            if (vm.accountErrorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                vm.accountErrorMessage!,
                style: AppTextStyles.cardBody.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Salvar nova senha',
              icon: Icons.save_outlined,
              isLoading: vm.isChangingPassword,
              onPressed: vm.canChangePassword && !vm.isChangingPassword
                  ? vm.changePassword
                  : null,
            ),
          ],
          if (vm.accountSuccessMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              vm.accountSuccessMessage!,
              style: AppTextStyles.cardBody.copyWith(color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Sair da conta',
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.error),
            ),
            trailing: vm.isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : null,
            enabled: !vm.isLoggingOut && !vm.isSyncing,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.bordered = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.badge),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );

    if (!bordered) return content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: content,
    );
  }
}
