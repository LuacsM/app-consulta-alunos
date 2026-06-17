import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 48});

  static const assetPath = 'assets/images/logo_curumim.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

class SeducLogo extends StatelessWidget {
  const SeducLogo({super.key, this.height = 52});

  static const assetPath = 'assets/images/logo_seduc.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
