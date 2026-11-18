import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/widgets/plan_suggestion.sheet.dart';

/// Card that opens the AI plan suggestions. Place it on a connection's screen.
///
/// Shows nothing unless [isClient] is true, so vendors never see it.
class PlanSuggestionEntry extends StatelessWidget {
  const PlanSuggestionEntry({
    super.key,
    required this.isClient,
    required this.connectionId,
    this.onSelectPackage,
  });

  /// Pass true only for signed-in client users.
  final bool isClient;
  final String connectionId;

  /// Called when the customer picks a suggested package, e.g. to start the
  /// normal reload flow with that package selected.
  final ValueChanged<PlanSuggestionEntity>? onSelectPackage;

  @override
  Widget build(BuildContext context) {
    if (!isClient) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => PlanSuggestionSheet.show(
          context,
          connectionId: connectionId,
          onSelect: onSelectPackage,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: cs.onPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a better reload plan',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI looks at your recent reloads and suggests cheaper options',
                      style: text.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
