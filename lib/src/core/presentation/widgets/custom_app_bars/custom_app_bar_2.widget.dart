import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/gradient_text.widget.dart';

AppBar customAppBar({required String title, List<Widget>? action, IconData? icon, Function()? onPressed}){
  return AppBar(
    backgroundColor: AppColors.white,
    leadingWidth: 20,
    leading: icon == null ? null : IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: AppColors.darkerGrey,fontWeight: FontWeight.bold),
    ),
    title: InkWell(
      onTap: onPressed,
      child: GradientText(text: title),
    ),
    actions: action,
  );
}
