import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/core/utils/formatters.dart';
import 'package:consulta_alunos/features/search/models/student.dart';

class StudentAccordionCard extends StatelessWidget {
  const StudentAccordionCard({
    super.key,
    required this.student,
    required this.isExpanded,
    required this.onToggle,
  });

  final Student student;
  final bool isExpanded;
  final VoidCallback onToggle;

  Future<void> _shareStudent() async {
    await Share.share(
      student.toShareText(),
      subject: 'Aluno - ${Formatters.formatName(student.nomeAluno)}',
    );
  }

  Future<void> _openContact(BuildContext context) async {
    final digits = student.telefone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o discador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = Formatters.formatName(student.nomeAluno);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => DismissKeyboard.run(onToggle),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: Radius.circular(isExpanded ? 0 : 14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      Formatters.initials(student.nomeAluno),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cód. ${student.codAluno}',
                          style: AppTextStyles.cardBody.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('DADOS ESCOLARES'),
                  const SizedBox(height: 12),
                  _InfoField(
                    icon: Icons.school_outlined,
                    label: 'ESCOLA',
                    value: student.escola,
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  const _SectionTitle('DADOS PESSOAIS'),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _InfoField(
                          icon: Icons.calendar_today_outlined,
                          label: 'NASCIMENTO',
                          value: student.dtNascAluno,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoField(
                          icon: Icons.badge_outlined,
                          label: 'CPF',
                          value: Formatters.formatCpf(student.cpfAluno),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoField(
                    icon: Icons.person_outline,
                    label: 'MÃE',
                    value: Formatters.formatName(student.nomeMaeAluno),
                  ),
                  if (student.nomePaiAluno.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoField(
                      icon: Icons.person_outline,
                      label: 'PAI',
                      value: Formatters.formatName(student.nomePaiAluno),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  const _SectionTitle('CONTATO E ENDEREÇO'),
                  const SizedBox(height: 12),
                  _InfoField(
                    icon: Icons.phone_outlined,
                    label: 'TELEFONE',
                    value: Formatters.formatPhone(student.telefone),
                  ),
                  const SizedBox(height: 12),
                  _InfoField(
                    icon: Icons.location_on_outlined,
                    label: 'ENDEREÇO',
                    value: student.enderecoAluno,
                  ),
                  const SizedBox(height: 12),
                  _InfoField(
                    icon: Icons.contact_page_outlined,
                    label: 'CPF RESPONSÁVEL',
                    value: Formatters.formatCpf(student.cpfResponsavel),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () => DismissKeyboard.run(_shareStudent),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text('Compartilhar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: student.telefone.isNotEmpty
                                ? () => DismissKeyboard.run(
                                      () => _openContact(context),
                                    )
                                : null,
                            icon: const Icon(Icons.phone_outlined, size: 18),
                            label: const Text('Contato'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.primary,
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.badge.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.cardBody.copyWith(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
