import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';

class SyncStepsIndicator extends StatelessWidget {
  const SyncStepsIndicator({
    super.key,
    required this.currentPhase,
  });

  final SyncPhase currentPhase;

  static const _steps = [
    (SyncPhase.preparing, '1', 'Preparar'),
    (SyncPhase.downloading, '2', 'Download'),
    (SyncPhase.importing, '3', 'Importar'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((step) => step.$1 == currentPhase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Etapa ${currentIndex + 1} de ${_steps.length}',
          style: AppTextStyles.badge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              if (i > 0) Expanded(child: _Connector(isActive: i <= currentIndex)),
              _StepDot(
                number: _steps[i].$2,
                label: _steps[i].$3,
                state: _stepState(i, currentIndex),
              ),
            ],
          ],
        ),
      ],
    );
  }

  _StepState _stepState(int index, int currentIndex) {
    if (index < currentIndex) return _StepState.completed;
    if (index == currentIndex) return _StepState.active;
    return _StepState.pending;
  }
}

enum _StepState { completed, active, pending }

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.state,
  });

  final String number;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isActive = state == _StepState.active;
    final isCompleted = state == _StepState.completed;

    final circleColor = isCompleted || isActive
        ? AppColors.primary
        : AppColors.surfaceMuted;
    final textColor = isCompleted || isActive
        ? Colors.white
        : AppColors.textSecondary;
    final labelColor = isActive
        ? AppColors.primary
        : isCompleted
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 34 : 30,
            height: isActive ? 34 : 30,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: AppColors.primaryLight, width: 3)
                  : null,
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              color: labelColor,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 22),
      color: isActive ? AppColors.primary : AppColors.border,
    );
  }
}
