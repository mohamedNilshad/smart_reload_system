
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class ShowConfirmPopup extends StatelessWidget {
  final String title;
  final String? content;
  final String leftBtn;
  final String rightBtn;

  const ShowConfirmPopup({
    super.key,
    this.title = AppStrings.confirmDeleteLabel,
    this.content,
    this.leftBtn = AppStrings.cancelLabel,
    this.rightBtn = AppStrings.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.sm)
      ),
      titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDark ? AppColors.white : AppColors.black
      ),
      title: Text(title),
      content: content != null ? Text(content!): null,
      actions: [
        TextButton(
          child: Text(
            leftBtn,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary
            ),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            rightBtn,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error
            ),
          ),
        ),
      ],
    );
  }
}
