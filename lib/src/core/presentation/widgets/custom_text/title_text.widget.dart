import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class TitleText extends StatelessWidget {
  final String text;
  final Color? color;
  const TitleText({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: color ?? AppColors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
