import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class BodyText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextOverflow? overflow;
  final int? maxLines;
  const BodyText({super.key, required this.text, this.color, this.overflow, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color ?? AppColors.black,
        overflow: overflow,
      ),
    );
  }
}
