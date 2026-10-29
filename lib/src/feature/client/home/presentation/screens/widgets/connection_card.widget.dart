import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class ConnectionCard extends StatelessWidget {
  final String conNumber;
  final String conName;
  final String conType;
  final String? conPlan;
  final bool isActive;
  final bool status;
  final bool isDark;
  final DateTime? lastDate;
  final void Function()? onTap;
  const ConnectionCard({super.key, required this.conNumber, required this.isActive, this.isDark = false, this.status = true, required this.conName, required this.conType, this.conPlan, required this.onTap, this.lastDate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CCard(
        isDark: isDark,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ListTile(
              leading: SizedBox(
                width: 30,
                height: 30,
                child: CSvgBuilder(
                  path: SvgStrings.box,
                  colorFilter: ColorFilter.mode(isDark ? AppColors.grey : AppColors.darkGrey, BlendMode.srcIn),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  TitleText(text: conName, color: isDark ? AppColors.white : null),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: isActive ? AppColors.green : AppColors.red,
                  ),
                ],
              ),
              subtitle: SubTitleText(text: conNumber, color: isDark ? AppColors.grey : AppColors.darkerGrey),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: isDark ? AppColors.grey : AppColors.darkerGrey),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60.0),
              child: Row(
                spacing: 5,
                children: [
                  CChip(label: conType, fontColor: isDark ? AppColors.white : null,),
                  if(conPlan != null)...{
                    CChip(
                      label: conPlan!,
                      bgColor: AppColors.primary,
                      fontColor: isDark ? AppColors.white : AppColors.primary,
                    ),
                  }

                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(thickness: 0.3),

            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(!status)...{
                    CSvgBuilder(
                      path: SvgStrings.clock,
                      width: 12,
                      colorFilter: ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn),
                    ),
                    LabelText(
                      text: "Waiting for approve",
                      color: AppColors.darkGrey,
                    ),
                  }else if(lastDate == null)...{
                    Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accent,),
                    LabelText(
                      text: "No reload yet",
                      color: AppColors.accent,
                    ),
                  }else if(lastDate != null)...{
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary,),
                    LabelText(
                      text: "Last reload ${HelperFunctions.formatRelativeDate(lastDate)}",
                      color: AppColors.primary,
                    ),
                  },



                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
