import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';

class CustomBanner extends StatelessWidget {
  final bool isNew;
  final String title;
  final String body;
  const CustomBanner({super.key, this.isNew = false, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Sizes.md),
      decoration: BoxDecoration(
          gradient: AppColors.linerGradient,
          borderRadius: BorderRadius.circular(14.0)
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: CSvgBuilder(
              path: SvgStrings.sparkles,
              colorFilter: ColorFilter.mode(AppColors.white.withValues(alpha: 0.2), BlendMode.srcIn),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if(isNew)...{
                CChip(
                  label: "NEW",
                  bgColor: AppColors.white,
                  fontColor: AppColors.white,
                ),
              },
              SubHeadlineText(
                text: title,
                color: AppColors.white,
              ),
              BodyText(
                text: body,
                color: AppColors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
