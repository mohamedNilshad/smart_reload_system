import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class CButton extends StatelessWidget {
  final Function onPressed;
  final Gradient bgColor;
  final Color color;
  final String title;
  const CButton({
    super.key,
    required this.onPressed,
    required this.bgColor,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              offset: Offset(0, 4),
              blurRadius: 5.0,
            )
          ],
          gradient: bgColor,
          color: color,
          borderRadius: BorderRadius.circular(Sizes.borderRadiusXXl),
          border: Border.all(color: Colors.white)
      ),
      child: ElevatedButton(
        onPressed:() => onPressed(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.md),
          fixedSize: Size(HelperFunctions.screenWidth(context)*0.6, Sizes.buttonHeight),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(Sizes.borderRadiusXXl),
          ),
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
        child: Text(title),
      ),
    );
  }
}
