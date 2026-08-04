import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';

class CCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final bool disableShadow;
  const CCard({super.key, required this.child, this.padding, this.radius, this.margin, this.disableShadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.lg),
      margin: margin ?? EdgeInsets.symmetric(horizontal: Sizes.sm),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: radius ?? BorderRadius.circular(Sizes.borderRadiusXl),
          boxShadow: disableShadow ? null : [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
      child: child,
    );
  }
}
