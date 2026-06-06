import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/features/settings/view_models/settings_view_model.dart';
import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/info_card.dart';
import 'package:consulta_alunos/shared/widgets/primary_button.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(context.read<AlunoSyncService>())
        ..load(),
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
              'Gerencie a sincronização offline dos alunos.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 24),
            _InfoTile(
              icon: Icons.storage_outlined,
              label: 'Alunos no dispositivo',
              value: '${vm.studentCount}',
            ),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.sync_outlined,
              label: 'Última sincronização',
              value: _formatLastSync(vm.lastSyncAt),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sincronizar alunos',
              icon: Icons.cloud_download_outlined,
              onPressed: null,
            ),
            const SizedBox(height: 12),
            const InfoCard(
              title: 'Sync ZIP/JSON',
              message:
                  'A sincronização por arquivo compactado será implementada '
                  'nesta branch. Aguardando definição da rota da API.',
              icon: Icons.info_outline,
            ),
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 16),
              InfoCard(
                title: 'Erro',
                message: vm.errorMessage!,
                icon: Icons.error_outline,
              ),
            ],
            const SizedBox(height: 20),
            const InfoCard(
              title: 'Modo offline',
              message:
                  'Após a sincronização, você poderá consultar alunos mesmo '
                  'sem internet. Com conexão, o app consulta a API e atualiza '
                  'o banco local.',
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSync(String? value) {
    if (value == null || value.isEmpty) return 'Nunca sincronizado';
    return value.replaceFirst('T', ' ').split('.').first;
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
