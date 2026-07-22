import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final String ref;
  final int count;
  final GestureTapCallback? onTap;
  const CustomTile({super.key, this.onTap,  required this.title, required this.ref, required this.count,});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Sizes.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          spacing: 10.0,
          children: [
            CircleAvatar(
              radius: 25.0,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
              child: HeadlineText(
                text: title[0],
                color: AppColors.secondary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5.0,
              children: [
                TitleText(text: title),
                Row(
                  spacing: 5.0,
                  children: [
                    CChip(label: ref),
                    LabelText(
                      text: "$count Connection${count>1 ? "s" : ""}",
                      color: AppColors.darkerGrey,
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            CircleAvatar(
              radius: 18.0,
              backgroundColor: AppColors.grey.withValues(alpha: 0.4),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
