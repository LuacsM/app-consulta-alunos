import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/shared/widgets/dashed_border_box.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.description,
    this.badgeLabel = 'Busca rápida e segura',
    this.badgeIcon = Icons.access_time,
    this.icon = Icons.person_search_outlined,
    this.minHeight = 240,
  });

  final String title;
  final String description;
  final String? badgeLabel;
  final IconData badgeIcon;
  final IconData icon;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return DashedBorderBox(
      child: SizedBox(
        width: double.infinity,
        height: minHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.cardBody,
            textAlign: TextAlign.center,
          ),
          if (badgeLabel != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(badgeLabel!, style: AppTextStyles.badge),
                ],
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}
