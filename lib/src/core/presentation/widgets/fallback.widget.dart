import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';

class FallbackWidget extends StatelessWidget {
  final void Function() onPressed;
  const FallbackWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TitleText(
            text: 'Unable to load data',
            isBold: false,
          ),
          const SizedBox(height: 16),
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
