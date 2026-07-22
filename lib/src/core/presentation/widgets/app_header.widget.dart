import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/gradient_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';

class AppHeader extends StatelessWidget {
  final String subtitle;
  const AppHeader({super.key, this.subtitle = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizes.lg),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            spreadRadius: 70,
            blurRadius: 70,
            offset: Offset(0, 60),
          ),
        ],
      ),
      child: Column(
        spacing: Sizes.md,
        children: [
          CSvgBuilder(path: SvgStrings.logoAngle),
          GradientText(
            text: AppStrings.brandName,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.darkerGrey,
            ),
          )

        ],
      ),
    );
  }
}
