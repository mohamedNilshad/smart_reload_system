
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CStatusBar extends StatelessWidget {
  final Widget child;
  const CStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child,
    );
  }
}
