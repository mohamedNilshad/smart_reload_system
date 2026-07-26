import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';

class CCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const CCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.lg),
      margin: EdgeInsets.symmetric(horizontal: Sizes.sm),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.borderRadiusXl),
          boxShadow: [
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
