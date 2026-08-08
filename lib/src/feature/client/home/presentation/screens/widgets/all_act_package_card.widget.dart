import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
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

    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        CCard(
          radius: BorderRadius.circular(Sizes.borderRadius),
          padding: EdgeInsets.all(Sizes.sm),
          margin: const EdgeInsets.only(top: Sizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                child: Column(
                  children: [
                    TitleText(text: title),
                    SubTitleText(text: description, color: AppColors.darkerGrey),

                    if(!onlyAmount)...{
                      SubTitleText(text: "${HelperFunctions.formatCurrency(price)}${validity != null ? " | $validity" : ""}"),
                    },

                    if(actDate == null)...{
                      LabelText(
                        text: "Req. date: ${HelperFunctions.formatDateTime(reqDate)}",
                        color: AppColors.primary,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          SubTitleText(text: "Status: Pending", color: AppColors.darkerGrey),
                        ],
                      ),
                    }else...{
                      LabelText(
                        text: "Act. date: ${HelperFunctions.formatDateTime(actDate!)}",
                        color: AppColors.green,
                      ),

                      LabelText(
                        text: "Exp. date: ${HelperFunctions.formatDateTime(expDate!)}",
                        color: AppColors.red,
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
