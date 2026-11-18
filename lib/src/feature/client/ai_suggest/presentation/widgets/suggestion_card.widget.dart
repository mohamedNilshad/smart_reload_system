import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/usage_stats.entity.dart';
import 'package:smart_reload_system/src/core/utils/money.util.dart';

String _validityLabel(double days) {
  if (days <= 1) return '1 day';
  if (days >= 30 && days % 30 == 0) {
    final months = (days / 30).round();
    return months == 1 ? '1 month' : '$months months';
  }
  if (days % 7 == 0 && days < 30) {
    final weeks = (days / 7).round();
    return weeks == 1 ? '1 week' : '$weeks weeks';
  }
  return '${days.toStringAsFixed(days % 1 == 0 ? 0 : 1)} days';
}

/// "You reload every ~9 days, about Rs. 1,430 a month" card.
class UsageSummaryCard extends StatelessWidget {
  const UsageSummaryCard({super.key, required this.summary, required this.stats});

  final String summary;
  final UsageStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final gap = stats.avgGapDays;

    Widget stat(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.labelSmall?.copyWith(color: cs.onPrimaryContainer.withOpacity(0.7))),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 20, color: cs.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary,
                  style: text.bodyMedium?.copyWith(color: cs.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              stat('Per month', moneyText(stats.monthlySpend)),
              stat('Reloads', '${stats.reloadCount}'),
              stat('Every', gap == null ? '-' : '${gap.toStringAsFixed(gap < 10 ? 1 : 0)} days'),
            ],
          ),
        ],
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.isBest,
    this.onSelect,
  });

  final PlanSuggestionEntity suggestion;
  final bool isBest;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = suggestion.package;

    Widget chip(String label) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: text.labelMedium),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBest ? cs.primary : cs.outlineVariant.withOpacity(0.6),
          width: isBest ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (isBest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Best match',
                    style: text.labelSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [p.name, if (p.packageType.isNotEmpty) p.packageType].join(' · '),
            style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip(moneyText(p.price)),
              chip(_validityLabel(p.validityDays)),
              chip('${moneyText(p.costPerDay)} / day'),
            ],
          ),
          const SizedBox(height: 12),
          _SavingPill(saving: suggestion.monthlySaving),
          if (suggestion.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(suggestion.reason, style: text.bodyMedium),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _ConfidenceLabel(confidence: suggestion.confidence),
              const Spacer(),
              if (onSelect != null)
                FilledButton.tonal(
                  onPressed: onSelect,
                  child: const Text('Choose this plan'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingPill extends StatelessWidget {
  const _SavingPill({required this.saving});

  final double saving;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    late final Color bg;
    late final Color fg;
    late final String label;
    late final IconData icon;

    if (saving >= 1) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      label = 'Save about ${moneyText(saving)} a month';
      icon = Icons.trending_down_rounded;
    } else if (saving <= -1) {
      bg = cs.tertiaryContainer;
      fg = cs.onTertiaryContainer;
      label = 'About ${moneyText(-saving)} more a month';
      icon = Icons.trending_up_rounded;
    } else {
      bg = cs.surfaceContainerHighest;
      fg = cs.onSurfaceVariant;
      label = 'Similar monthly cost';
      icon = Icons.drag_handle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: text.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceLabel extends StatelessWidget {
  const _ConfidenceLabel({required this.confidence});

  final SuggestionConfidence confidence;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = switch (confidence) {
      SuggestionConfidence.high => 'Strong match',
      SuggestionConfidence.medium => 'Good match',
      SuggestionConfidence.low => 'Worth a look',
    };
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: cs.onSurfaceVariant),
    );
  }
}
