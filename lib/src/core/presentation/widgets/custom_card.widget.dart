import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/effects/custom_paint.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class CCard extends StatelessWidget {
  final Gradient bgColor;
  final String title;
  const CCard({super.key, required this.bgColor, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HelperFunctions.screenWidth(context),
      height: 150,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: bgColor,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: Sizes.sm,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: WavePainter(), ),
          ),
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900
              ),
            ),
          )
        ],
      ),
    );
  }
}
