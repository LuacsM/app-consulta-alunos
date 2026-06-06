import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.verified_user_outlined,
        color: Colors.white,
        size: size * 0.45,
      ),
    );
  }
}
