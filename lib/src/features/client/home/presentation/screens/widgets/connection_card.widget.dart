import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';

class ConnectionCard extends StatelessWidget {
  final String connection;
  final int status;
  final String packageName;
  final String expDate;
  const ConnectionCard({super.key, required this.connection, required this.status, required this.packageName, required this.expDate});

  @override
  Widget build(BuildContext context) {
    return CCard(
      child: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubHeadlineText(text: connection),
                    CChip(
                      label: "Active",
                      bgColor: AppColors.buttonGreen,
                      fontColor: AppColors.darkerGrey,
                      enableStatus: true,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    CSvgBuilder(
                      path: SvgStrings.box,
                      colorFilter: ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn),
                    ),
                    LabelText(
                      text: packageName,
                      color: AppColors.darkGrey,
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Sizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.softGrey,
                    borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                  ),
                  child: Row(
                    spacing: 5,
                    children: [
                      CSvgBuilder(
                        path: SvgStrings.clock,
                        width: 18,
                        colorFilter: ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Expires: ',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: expDate,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      CChip(
                        label: "12 Days Left",
                        bgColor: AppColors.accent,
                        fontColor: AppColors.darkerGrey,
                        borderRadius: 5,
                        verticalPadding: 5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              bottomWidget(
                context: context,
                icon: SvgStrings.phone,
                label: "USSD",
              ),
              bottomWidget(
                context: context,
                icon: SvgStrings.suggest,
                label: "AI SUGGEST",
                border: false,
              ),
              bottomWidget(
                context: context,
                icon: SvgStrings.history,
                label: "HISTORY",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomWidget({required BuildContext context, required String icon, required String label, bool border = true}){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Sizes.lg),
        decoration: BoxDecoration(
          color: AppColors.softGrey,
          border: Border(
            top: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
            bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
            right: BorderSide(color: AppColors.grey.withValues(alpha: 0.5), width: border ? 1 : 0),
            left: BorderSide(color: AppColors.grey.withValues(alpha: 0.5), width: border ? 1 : 0),
          ),
        ),
        child: Column(
          spacing: 5,
          children: [
            CSvgBuilder(
              path: icon,
              width: 18,
              colorFilter: ColorFilter.mode(AppColors.darkerGrey, BlendMode.srcIn),
            ),
            LabelText(text: label),
          ],
        ),
      ),
    );
  }

}
