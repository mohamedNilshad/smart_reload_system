import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/image_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/gif_builder.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class FallbackWidget extends StatelessWidget {
  final void Function() onPressed;
  final bool isDark;
  const FallbackWidget({super.key, required this.onPressed, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          GifBuilder(url: isDark ? ImageStrings.serverErrorDark : ImageStrings.serverError, isDark: isDark),
          TitleText(
            text: 'Unable to fetch details',
            isBold: false,
            color: isDark ? AppColors.grey : AppColors.white,
          ),
          SizedBox(
            width: HelperFunctions.screenWidth(context)/1.2,
            child: BodyText(
              text: 'Something went wrong while loading this screen.',
              color: isDark ? AppColors.darkGrey : AppColors.white,
              textAlign: TextAlign.center,
            ),
          ),

          CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            radius: 30,
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(Icons.refresh, size: 30, color: isDark ? AppColors.secondary : AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
