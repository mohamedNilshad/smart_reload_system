import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class GifBuilder extends StatelessWidget {
  final String url;
  final bool isVendor;
  const GifBuilder({super.key, required this.url, this.isVendor = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      width: 80,
      height: 80,
      color: isVendor ? AppColors.scaffoldVendor : AppColors.softGrey,
      colorBlendMode: BlendMode.multiply,
    );
  }
}
