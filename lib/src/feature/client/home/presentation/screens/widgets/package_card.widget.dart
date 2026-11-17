import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class PackageCard extends StatelessWidget {
  final String title;
  final String validity;
  final String description;
  final double price;
  final bool isDark;
  final void Function()? onTap;
  const PackageCard({super.key, this.isDark = false, required this.title, required this.validity, required this.description, required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CCard(
        isDark: isDark,
        radius: BorderRadius.circular(Sizes.borderRadius),
        padding: const EdgeInsets.symmetric(vertical:  Sizes.ssm),
        margin: const EdgeInsets.symmetric(vertical:  Sizes.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.ssm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(text: title, color: isDark ? AppColors.white : null,),
                  SubTitleText(text: description, color: isDark ? AppColors.darkGrey :AppColors.darkerGrey),
                ],
              ),
            ),
            Divider(thickness: 0.3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.ssm),
              child: Row(
                spacing: HelperFunctions.screenWidth(context)/4,
                children: [
                  _buildDetailsColumn("Validity", validity),
                  _buildDetailsColumn("Price", "Rs. ${price.toStringAsFixed(0)}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsColumn(String title, String subtitle){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: title, color: isDark ? AppColors.grey : AppColors.darkGrey,),
        LabelText(text: subtitle, isBold: true,color: isDark ? AppColors.white : null,),
      ],
    );
  }
}
