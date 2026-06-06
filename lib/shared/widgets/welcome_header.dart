import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.centered = false,
  });

  final String title;
  final String subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(title, style: AppTextStyles.welcome, textAlign: textAlign),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.subtitle, textAlign: textAlign),
      ],
    );
  }
}
