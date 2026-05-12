
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

Future<String?> showRenamePopup({required BuildContext context, required String currentName}) async  {
  TextEditingController saveNameController = TextEditingController();
  bool isDark = HelperFunctions.isDarkMode(context);
  saveNameController.text = currentName;

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Save Name'),
        content: TextField(
          controller: saveNameController,
          enableSuggestions: true,
          decoration: InputDecoration(
            labelText: "Enter Name",
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.grey: AppColors.darkerGrey,
            ),
            alignLabelWithHint: true,
          ),
          keyboardType: TextInputType.multiline,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, saveNameController.text),
            child: const Text(AppStrings.okLabel),
          ),
        ],
      );
    },
  );
}