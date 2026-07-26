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
  final bool status;
  final DateTime lastDate;
  final void Function()? onReloadTap;
  const ConnectionCard({super.key, required this.conNumber, required this.status, required this.conName, required this.conType, this.conPlan, required this.onReloadTap, required this.lastDate});

  @override
  Widget build(BuildContext context) {
    return CCard(
      padding: EdgeInsets.zero,
      child: Column(
        spacing: 10,
        children: [
          Column(
            children: [
              ListTile(
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: CSvgBuilder(
                    path: SvgStrings.box,
                    colorFilter: ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn),
                  ),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    TitleText(text: conName),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: status ? AppColors.green : AppColors.red,
                    ),
                  ],
                ),
                subtitle: SubTitleText(text: conNumber, color: AppColors.darkerGrey),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.darkerGrey),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 60.0),
                child: Row(
                  spacing: 5,
                  children: [
                    CChip(label: conType),
                    if(conPlan != null)...{
                      CChip(
                        label: conPlan!,
                        bgColor: AppColors.primary,
                        fontColor: AppColors.primary,
                      ),
                    }

                  ],
                ),
              ),
              SizedBox(height: 5),
              Divider(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  spacing: 5,
                  children: [
                    CSvgBuilder(
                      path: SvgStrings.clock,
                      width: 18,
                      colorFilter: ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
                    ),
                    LabelText(
                      text: "Last reload ${HelperFunctions.formatRelativeDate(lastDate)}",
                      color: AppColors.darkGrey,
                    ),
                    Spacer(),

                    InkWell(
                      onTap: onReloadTap,
                      child: CChip(
                        label: "Reload",
                        bgColor: AppColors.accent,
                        fontColor: AppColors.darkerGrey,
                        borderRadius: 5,
                        verticalPadding: 5,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
