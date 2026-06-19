import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';

/// GIF de processamento usado durante a sincronização.
class DocumentSearchAnimation extends StatelessWidget {
  const DocumentSearchAnimation({
    super.key,
    this.message,
  });

  static const assetPath = 'assets/images/sync_processing.gif';

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          assetPath,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            style: AppTextStyles.cardBody.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
