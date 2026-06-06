import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/shared/widgets/skeleton_box.dart';

class StudentResultsSkeleton extends StatelessWidget {
  const StudentResultsSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: 160, height: 14, borderRadius: 6),
        const SizedBox(height: 12),
        ...List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < itemCount - 1 ? 12 : 0),
            child: const _StudentCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _StudentCardSkeleton extends StatelessWidget {
  const _StudentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: MediaQuery.sizeOf(context).width * 0.45,
                  height: 14,
                  borderRadius: 6,
                ),
                const SizedBox(height: 8),
                SkeletonBox(
                  width: MediaQuery.sizeOf(context).width * 0.28,
                  height: 12,
                  borderRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SkeletonBox(width: 20, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}
