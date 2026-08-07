import 'package:flutter/material.dart';

import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class CElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final bool isLoading;
  final Color? bgColor;
  const CElevatedButton({super.key, required this.onPressed, required this.label, this.isLoading = false, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(HelperFunctions.screenWidth(context), Sizes.buttonHeight),
        backgroundColor: bgColor,
      ),
      child: isLoading ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ) : Text(label),
    );
  }
}
