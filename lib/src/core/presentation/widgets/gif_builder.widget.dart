import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class GifBuilder extends StatelessWidget {
  final String url;
  const GifBuilder({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      width: 80,
      height: 80,
      color: AppColors.softGrey,
      colorBlendMode: BlendMode.multiply,
    );
  }
}
