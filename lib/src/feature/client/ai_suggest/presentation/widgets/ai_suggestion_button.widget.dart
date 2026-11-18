import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_data.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/widgets/plan_suggestion.sheet.dart';

/// Small "AI suggestion" button for a connection card. Tapping it opens the
/// plan suggestions for that connection in a bottom sheet.
///
/// Shows nothing for non-client users or when the connection has no id yet.
class AiSuggestionButton extends StatelessWidget {
  const AiSuggestionButton({
    super.key,
    required this.payableAmount,
    required this.isClient,
    required this.connectionId,
    this.onSelectPackage,
  });

  /// Pass true only for signed-in client users.
  final double payableAmount;
  final bool isClient;
  final String? connectionId;

  /// Called when the customer taps "Choose this plan" in the sheet, e.g. to
  /// start the normal reload flow with that package.
  final ValueChanged<PlanSuggestionEntity>? onSelectPackage;

  @override
  Widget build(BuildContext context) {
    final id = connectionId;
    if (!isClient || id == null || id.isEmpty) return const SizedBox.shrink();



    return FilledButton(
      onPressed: () {
        if(payableAmount >= AppData.lockAmount) {
          AppSnackbar.showInfo(context, AppData.lockAmountMessage);
          return;

        }
        PlanSuggestionSheet.show(
          context,
          connectionId: id,
          onSelect: onSelectPackage,
        );
      },
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity(horizontal: -3, vertical: -3),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.white,
      ),
      child: const Icon(Icons.auto_awesome_rounded, size: 18),
    );
  }
}
