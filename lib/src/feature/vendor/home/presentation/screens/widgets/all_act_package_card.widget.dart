import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class AllActPackageCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime? expDate;
  final DateTime? actDate;
  final DateTime reqDate;
  final double price;
  final String? validity;
  final bool onlyAmount;

  const AllActPackageCard({
    super.key,
    required this.title,
    required this.price,
    this.validity,
    required this.description,
    required this.reqDate,
    this.onlyAmount = false,
    this.actDate,
    this.expDate,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsGeometry.only(bottom: Sizes.ssm),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Sizes.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius), ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TitleText(text: title),
                    TitleText(text: HelperFunctions.formatCurrency(price)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Flexible(
                      child: SubTitleText(
                        text: "$description$description$description$description",
                        color: AppColors.darkerGrey,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CChip(
                      label: (actDate == null) ? "Pending" : "Completed",
                      bgColor: (actDate == null) ? AppColors.warning : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
      
          Container(
            padding: EdgeInsets.all(Sizes.ssm),
            color: AppColors.secondary.withValues(alpha: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMid(
                  context,
                  title: "Validity",
                  icon: Icons.access_alarms_rounded,
                  subtitle: validity ?? "N/A",
                ),
                SizedBox(
                  height: 40,
                  child: VerticalDivider(color: AppColors.darkGrey),
                ),
                _buildMid(
                  context,
                  title: "Activated",
                  icon: Icons.calendar_month_rounded,
                  subtitle: actDate == null ? "N/A" : HelperFunctions.formatDateTime(actDate!, withTime: false),
                ),
                SizedBox(
                  height: 40,
                  child: VerticalDivider(color: AppColors.darkGrey),
                ),
                _buildMid(
                  context,
                  title: "Expired",
                  icon: Icons.calendar_today_rounded,
                  subtitle: expDate == null ? "N/A" : HelperFunctions.formatDateTime(expDate!, withTime: false),
                ),
              ],
            ),
          ),
      
          Container(
            padding: EdgeInsets.all(Sizes.sm),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Sizes.borderRadius), bottomRight: Radius.circular(Sizes.borderRadius), ),
            ),
            child:  LabelText(
              text: "Req. date: ${HelperFunctions.formatDateTime(reqDate)}",
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMid(BuildContext context, {required String subtitle, required IconData icon, required String title}){
    double screenWidth = HelperFunctions.screenWidth(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          spacing: 3,
          children: [
            Icon(icon, color: AppColors.darkerGrey, size: 16,),
            SubTitleText(text: title, color: AppColors.darkerGrey)
          ],
        ),
        SizedBox(
          width: screenWidth/4,
          child: BodyText(
            text: subtitle, isBold: true,
            textAlign: TextAlign.center,
            size: 12,
            maxLines: 2,
          ),
        )
      ],
    );
  }
}
