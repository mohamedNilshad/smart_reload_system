
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class CStatusBar extends StatelessWidget {
  final Widget child;
  const CStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child,
    );
  }
}
