import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class CSvgBuilder extends StatelessWidget {
  final String path;
  final bool isSelected;
  final Color? color;

  const CSvgBuilder({
    super.key,
    required this.path,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if(color == null) {
      iconColor = isSelected ? AppColors.selectedIcon : AppColors.lightUnSelectedIcon;
    } else{
      iconColor = color!;
    }
    return SvgPicture.asset(
      path,
      // colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
