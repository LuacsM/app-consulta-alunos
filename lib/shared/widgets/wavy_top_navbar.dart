import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/core/theme/app_theme.dart';
import 'package:consulta_alunos/shared/widgets/app_logo.dart';

class WavyTopNavbar extends StatelessWidget {
  const WavyTopNavbar({
    super.key,
    this.logoHeight = 56,
    this.seducLogoHeight = 52,
    this.height = 140,
  });

  final double logoHeight;
  final double seducLogoHeight;
  final double height;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.darkHeaderOverlay,
      child: ClipPath(
        clipper: const WavyNavbarClipper(),
        child: SizedBox(
          height: height + topPadding,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topPadding,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.statusBarOverlay,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0x1AFFFFFF),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: SizedBox(
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 44),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppLogo(height: logoHeight),
                        const Spacer(),
                        Flexible(
                          child: Transform.translate(
                            offset: const Offset(0, -4),
                            child: SeducLogo(height: seducLogoHeight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WavyNavbarClipper extends CustomClipper<Path> {
  const WavyNavbarClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.cubicTo(
      size.width * 0.25,
      size.height,
      size.width * 0.75,
      size.height - 100,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
