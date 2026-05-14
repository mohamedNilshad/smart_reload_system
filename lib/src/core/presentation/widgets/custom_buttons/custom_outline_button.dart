import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class COutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  const COutlineButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: Sizes.buttonSize(
          context,
          HelperFunctions.screenWidth(context),
          Sizes.buttonHeight,
        ),
      ),
      child: Text(title),
    );
  }
}
