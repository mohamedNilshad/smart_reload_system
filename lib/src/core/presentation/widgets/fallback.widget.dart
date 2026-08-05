import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/image_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/gif_builder.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class FallbackWidget extends StatelessWidget {
  final void Function() onPressed;
  const FallbackWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          GifBuilder(url: ImageStrings.serverError),
          const TitleText(
            text: 'Unable to fetch details',
            isBold: false,
            color: AppColors.darkerGrey,
          ),
          SizedBox(
            width: HelperFunctions.screenWidth(context)/1.2,
            child: const BodyText(
              text: 'Something went wrong while loading this screen.',
              color: AppColors.darkerGrey,
              textAlign: TextAlign.center,
            ),
          ),

          CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            radius: 30,
            child: IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
