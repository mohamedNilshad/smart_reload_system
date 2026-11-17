import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/report_format.util.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.changePct,
    this.footnote,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Percent change vs the previous period. When null, [footnote] is shown.
  final double? changePct;
  final String? footnote;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkContainers,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color:  AppColors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitleText(
                  text: label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: TitleText(
              text: value,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 6),
          _buildChange(context),
        ],
      ),
    );
  }

  Widget _buildChange(BuildContext context) {
    final pct = changePct;

    if (pct == null) {
      return BodyText(
        text: footnote ?? 'No prior data',
        color: AppColors.darkGrey,
        size: 13,
      );
    }

    final up = pct >= 0;
    final color = up ? AppColors.green : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        BodyText(
          text: '${formatPct(pct)} vs previous',
          color: color,
        ),
      ],
    );
  }
}
