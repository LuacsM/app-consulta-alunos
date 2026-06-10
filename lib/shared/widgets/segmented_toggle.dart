import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';

class SegmentedOption<T> {
  const SegmentedOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

/// Toggle em pílula no estilo da tela de autenticação do app minhas_notas,
/// com indicador deslizante animado entre as opções.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  final String? label;
  final List<SegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final Duration animationDuration;

  static const double _indicatorInset = 2;

  int get _selectedIndex {
    final index = options.indexWhere((option) => option.value == selected);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
        ],
        Container(
          padding: const EdgeInsets.all(5),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(40),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / options.length;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: animationDuration,
                    curve: Curves.easeInOutCubic,
                    left: _selectedIndex * tabWidth + _indicatorInset,
                    width: tabWidth - _indicatorInset * 2,
                    top: _indicatorInset,
                    bottom: _indicatorInset,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: options.map((option) {
                      final isActive = option.value == selected;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => DismissKeyboard.run(
                            () => onChanged(option.value),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: AnimatedDefaultTextStyle(
                              duration: animationDuration,
                              curve: Curves.easeInOutCubic,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? AppColors.primaryBlue
                                    : AppColors.textTertiary,
                              ),
                              child: Text(
                                option.label,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
