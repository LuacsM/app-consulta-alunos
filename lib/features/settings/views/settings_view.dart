import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/features/settings/view_models/settings_view_model.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';
import 'package:consulta_alunos/features/sync/services/sync_session_controller.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/document_search_animation.dart';
import 'package:consulta_alunos/shared/widgets/info_card.dart';
import 'package:consulta_alunos/shared/widgets/sync_steps_indicator.dart';
import 'package:consulta_alunos/shared/widgets/primary_button.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          SettingsViewModel(context.read<SyncSessionController>())..load(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

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
            const SizedBox(height: 6),
            const Text(
              'Atualize os dados dos alunos para consultar sem internet.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 24),
            _InfoTile(
              icon: Icons.sync_outlined,
              label: 'Última sincronização',
              value: _formatLastSync(vm.lastSyncAt),
            ),
            if (vm.hasPendingSync && vm.pendingSyncMessage != null) ...[
              const SizedBox(height: 12),
              InfoCard(
                title: 'Sincronização pendente',
                message: vm.pendingSyncMessage!,
                icon: Icons.pause_circle_outline,
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: vm.isSyncing
                  ? 'Sincronizando...'
                  : vm.hasPendingSync
                      ? 'Continuar sincronização'
                      : 'Sincronizar alunos',
              icon: vm.hasPendingSync
                  ? Icons.play_arrow_outlined
                  : Icons.cloud_download_outlined,
              onPressed: vm.isSyncing ? null : vm.syncNow,
            ),
            if (vm.hasPendingSync && !vm.isSyncing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: vm.restartSync,
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
            if (vm.isSyncing && vm.syncPhase != null) ...[
              const SizedBox(height: 20),
              SyncStepsIndicator(currentPhase: vm.syncPhase!),
              const SizedBox(height: 20),
              const DocumentSearchAnimation(),
              if (vm.syncProgress != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: vm.syncProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(vm.syncProgress! * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (vm.progressMessage != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    vm.progressMessage!,
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
                  _phaseHint(vm.syncPhase!),
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (vm.successMessage != null) ...[
              const SizedBox(height: 16),
              InfoCard(
                title: 'Sincronização',
                message: vm.successMessage!,
                icon: Icons.check_circle_outline,
              ),
            ],
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 16),
              InfoCard(
                title: 'Erro na sincronização',
                message: vm.errorMessage!,
                icon: Icons.error_outline,
              ),
            ],
            if (!vm.isSyncing) ...[
              const SizedBox(height: 20),
              const InfoCard(
                title: 'Consulta sem internet',
                message:
                    'Baixe os dados dos alunos para consultar mesmo offline. '
                    'A atualização pode levar alguns minutos.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastSync(String? value) {
    if (value == null || value.isEmpty) return 'Nunca sincronizado';
    return value.replaceFirst('T', ' ').split('.').first;
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
      child: Row(
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
      ),
    );
  }
}
