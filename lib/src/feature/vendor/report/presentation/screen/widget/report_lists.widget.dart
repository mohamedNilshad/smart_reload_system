import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/report_format.util.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/screen/widget/report_section.widget.dart';

/// Ranked rows with a share bar: used for providers and top packages.
class BreakdownBars extends StatelessWidget {
  const BreakdownBars({super.key, required this.items});

  final List<BreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const EmptyHint('No data in this period');

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SubTitleText(
                        text: item.name,
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.white,
                        isBold: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SubTitleText(
                      text: formatMoney(item.amount),
                      color: AppColors.grey,
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.share.clamp(0.0, 1.0).toDouble(),
                    minHeight: 8,
                    backgroundColor: AppColors.grey,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                SubTitleText(
                  text: '${item.count} ${item.count == 1 ? 'request' : 'requests'} · ${(item.share * 100).toStringAsFixed(0)}%',
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.grey,
                ),

              ],
            ),
          ),
      ],
    );
  }
}

/// Three tiles: 0–7, 8–30 and 31+ days unpaid.
class AgingSummary extends StatelessWidget {
  const AgingSummary({super.key, required this.buckets});

  final List<AgingBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.primary, AppColors.darkTabBg, AppColors.error];

    return Row(
      children: [
        for (var i = 0; i < buckets.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors[i % colors.length].withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LabelText(
                          text: buckets[i].label,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TitleText(
                      text: formatMoney(buckets[i].amount),
                      color: AppColors.white,
                    ),
                  ),
                  SubTitleText(
                    text: '${buckets[i].count} unpaid',
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Who to chase": connections with the most money outstanding.
class UnpaidList extends StatelessWidget {
  const UnpaidList({super.key, required this.items});

  final List<UnpaidConnection> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const EmptyHint('No unpaid requests');

    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.errorContainer,
                  child: Icon(Icons.schedule_rounded,
                      size: 18, color: cs.onErrorContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(
                        text: item.connectionName,
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.white,
                        size: 13,
                        isBold: true,
                      ),
                      SubTitleText(
                        text: '${item.connectionNumber} · ${item.count} unpaid',
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TitleText(
                      text: formatMoney(item.amount),
                      color: AppColors.white,
                    ),
                    BodyText(
                      text: 'oldest ${item.oldestDays}d',
                      size: 13,
                      color: item.oldestDays > 30
                          ? AppColors.error
                          : AppColors.darkGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Connections whose package ends within the next 7 days.
class ExpiringList extends StatelessWidget {
  const ExpiringList({super.key, required this.items});

  final List<ExpiringConnection> items;

  String _when(int daysLeft) {
    if (daysLeft <= 0) return 'Today';
    if (daysLeft == 1) return 'Tomorrow';
    return 'In $daysLeft days';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyHint('No connections expiring in the next 7 days');
    }

    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.sim_card_outlined,
                      size: 18, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(
                        text: item.connectionName,
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.white,
                        isBold: true,
                        size: 14,
                      ),
                      SubTitleText(
                        text: '${item.connectionNumber} · ${item.packageName}',
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: item.daysLeft <= 1
                        ? cs.errorContainer
                        : cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _when(item.daysLeft),
                    style: text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: item.daysLeft <= 1
                          ? cs.onErrorContainer
                          : cs.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
