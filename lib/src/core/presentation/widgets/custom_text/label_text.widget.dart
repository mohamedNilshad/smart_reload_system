import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class LabelText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextOverflow? overflow;
  final int? maxLines;
  const LabelText({super.key, required this.text, this.color, this.overflow, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color ?? AppColors.black,
        overflow: overflow,
      ),
    );
  }
}
