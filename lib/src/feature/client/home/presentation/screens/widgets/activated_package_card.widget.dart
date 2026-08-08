import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class ActivatedPackageCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime expDate;
  final DateTime actDate;
  final double price;
  final bool isExpand;
  final String validity;
  final void Function()? onTap;
  const ActivatedPackageCard({super.key, required this.title, required this.price, required this.validity, required this.description, required this.actDate, required this.expDate, this.isExpand = false, required this.onTap});


  double calDate(DateTime startDate, DateTime endDate){
    final now = DateTime.now();


    // Total and elapsed durations
    final totalDuration = endDate.difference(startDate).inMinutes;
    final elapsedDuration = now.difference(startDate).inMinutes;

    double progress = 0.0;
    if (totalDuration > 0) {
      progress = (elapsedDuration / totalDuration);
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Sizes.sm, bottom: Sizes.sm),
      child: Column(
        children: [
          CCard(
            radius: isExpand ? BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius), ) : BorderRadius.circular(Sizes.borderRadius),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            disableShadow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: TitleText(text: title),
                        subtitle: SubTitleText(text: description, color: AppColors.darkerGrey),
                        trailing: Visibility(
                          visible: calDate(actDate, expDate) > 0.75,
                          child: CChip(
                            label: "Expiring soon",
                            bgColor: AppColors.accent,
                            fontColor: AppColors.warning,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(Sizes.ssm),
                        decoration: BoxDecoration(
                          color: AppColors.softGrey,
                          borderRadius: BorderRadius.circular(Sizes.borderRadius),
                        ),
                        child: Column(
                          spacing: 10.0,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                CSvgBuilder(
                                  path: SvgStrings.clock,
                                  width: 18,
                                  colorFilter: ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
                                ),
                                LabelText(
                                  text: HelperFunctions.calculateRemainingTime(expDate),
                                  color: AppColors.accent,
                                ),
                              ],
                            ),

                            buildDateProgressBar(endDate: expDate, startDate: actDate),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 0.3),
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Sizes.sm, Sizes.sm, Sizes.sm, Sizes.ssm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SubTitleText(text: "Package Details", color: AppColors.darkGrey, isBold: true),
                        Icon(isExpand ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.darkGrey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(isExpand)...{
            Container(
              margin: const EdgeInsets.fromLTRB(Sizes.sm, 0.0, Sizes.sm, Sizes.sm),
              padding: const EdgeInsets.all(Sizes.sm),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Sizes.borderRadius), bottomRight: Radius.circular(Sizes.borderRadius)),
                  border: Border(bottom: BorderSide(color: AppColors.grey, width: 1.5))
              ),
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: HelperFunctions.screenWidth(context)/4,
                    children: [
                      _buildDetailsColumn("Activated date", HelperFunctions.formatDateTime(actDate)),
                      _buildDetailsColumn("Price", "Rs. ${price.toStringAsFixed(0)}"),
                    ],
                  ),
                  Row(
                    spacing: HelperFunctions.screenWidth(context)/4,
                    children: [
                      _buildDetailsColumn("Exp. date", HelperFunctions.formatDateTime(expDate)),
                      _buildDetailsColumn("Validity", validity),
                    ],
                  ),
                ],
              ),
            ),
          }
        ],
      ),
    );
  }


  Widget buildDateProgressBar({required DateTime startDate, required DateTime endDate}) {
    double progress = calDate(startDate, endDate);

    // Calculate remaining days for display
    return LinearProgressIndicator(
      value: progress,
      minHeight: 7.0,
      borderRadius: BorderRadius.circular(25),
      backgroundColor: AppColors.grey,
      valueColor: AlwaysStoppedAnimation<Color>(getProgressColor(progress)),
    );
  }

  Color getProgressColor(double value){

    if(value < 0.5){
      return AppColors.darkGrey;
    }else if(value < 0.75){
      return AppColors.accent;
    }else{
      return AppColors.red;
    }
  }

  Widget _buildDetailsColumn(String title, String subtitle){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: title, color: AppColors.darkGrey,),
        LabelText(text: subtitle, isBold: true,),
      ],
    );
  }
}
