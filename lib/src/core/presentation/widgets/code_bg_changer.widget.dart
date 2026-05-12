import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';

class CodeBgChange extends StatelessWidget {
  final bool isSelected;
  final int value;
  final Color color;
  final VoidCallback onPressed;

  const CodeBgChange({
    super.key,
    required this.isSelected,
    required this.value,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0,Sizes.xs,Sizes.sm,Sizes.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonPrimary : AppColors.softGrey,
          border: Border.all(
            color: isSelected ? AppColors.buttonPrimary : AppColors.darkGrey,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: color == Colors.transparent ? const Icon(
          Icons.not_interested,
          size: Sizes.md,
          color: AppColors.error,
        ): Container(
          width: Sizes.md,
          height: Sizes.md,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: color
          ),
        ),
      ),
    );
  }
}
