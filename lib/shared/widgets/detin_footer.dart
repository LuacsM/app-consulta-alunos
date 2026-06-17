import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:consulta_alunos/core/theme/app_text_styles.dart';

class DetinFooter extends StatelessWidget {
  const DetinFooter({
    super.key,
    this.height = 18,
    this.bottomPadding = 36,
  });

  final double height;
  final double bottomPadding;

  static const _assetPath = 'assets/images/footer.svg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Desenvolvido por',
            style: AppTextStyles.footer.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          SvgPicture.asset(
            _assetPath,
            height: height,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
