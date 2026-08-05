import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/image_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/gif_builder.widget.dart';

class EmptyScreenWidget extends StatelessWidget {

  const EmptyScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          GifBuilder(url: ImageStrings.emptyScreen),

          const TitleText(
            text: 'No results found',
            isBold: false,
            color: AppColors.darkerGrey,
          ),
        ],
      ),
    );
  }
}