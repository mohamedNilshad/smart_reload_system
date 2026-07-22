import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';

class CAppBar extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final String? subtitle;
  const CAppBar({super.key, this.onPressed, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(Sizes.md, Sizes.md, Sizes.md, 50.0),
      decoration: BoxDecoration(
        gradient: AppColors.linerGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), )
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: IconButton(
              onPressed: onPressed,
              icon: Container(
                padding: EdgeInsets.all(Sizes.ssm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.5),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
              ),
            ),
          ),
          Text(
            title,
            maxLines: 2,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.white,
            ),
          ),
          Text(
            subtitle ?? "",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
