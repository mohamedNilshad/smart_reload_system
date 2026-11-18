import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/bloc/plan_suggestion.bloc.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/bloc/plan_suggestion.event.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/bloc/plan_suggestion.state.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/screens/widgets/suggestion_card.widget.dart';

/// Bottom sheet that analyses a connection's reload history and shows
/// AI-suggested plans. Open it with [PlanSuggestionSheet.show].
class PlanSuggestionSheet extends StatefulWidget {
  const PlanSuggestionSheet({
    super.key,
    required this.connectionId,
    required this.scrollController,
    this.onSelect,
  });

  final String connectionId;
  final ScrollController scrollController;

  /// Called when the customer taps "Choose this plan". When null the button
  /// isn't shown.
  final ValueChanged<PlanSuggestionEntity>? onSelect;

  static Future<void> show(
    BuildContext context, {
    required String connectionId,
    ValueChanged<PlanSuggestionEntity>? onSelect,
  }) {
    final bloc = context.read<PlanSuggestionBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => PlanSuggestionSheet(
            connectionId: connectionId,
            scrollController: controller,
            onSelect: onSelect,
          ),
        ),
      ),
    );
  }

  @override
  State<PlanSuggestionSheet> createState() => _PlanSuggestionSheetState();
}

class _PlanSuggestionSheetState extends State<PlanSuggestionSheet> {
  @override
  void initState() {
    super.initState();
    // The bloc is an app-level singleton: clear any earlier result first.
    context.read<PlanSuggestionBloc>()
      ..add(const PlanSuggestionReset())
      ..add(PlanSuggestionRequested(connectionId: widget.connectionId));
  }

  void _refresh() {
    context.read<PlanSuggestionBloc>().add(
          PlanSuggestionRequested(
            connectionId: widget.connectionId,
            forceRefresh: true,
          ),
        );
  }

  void _retry() {
    context.read<PlanSuggestionBloc>().add(
          PlanSuggestionRequested(connectionId: widget.connectionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan suggestions',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Based on your recent reloads',
                        style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<PlanSuggestionBloc, PlanSuggestionState>(
              builder: (context, state) {
                if (state is PlanSuggestionSuccess) {
                  return _AdviceView(
                    advice: state.advice,
                    controller: widget.scrollController,
                    onRefresh: _refresh,
                    onSelect: widget.onSelect,
                  );
                }
                if (state is PlanSuggestionFailureState) {
                  return _MessageView(
                    controller: widget.scrollController,
                    icon: Icons.cloud_off_rounded,
                    message: state.message,
                    actionLabel: 'Try again',
                    onAction: _retry,
                  );
                }
                return _MessageView(
                  controller: widget.scrollController,
                  loading: true,
                  message: 'Looking at your reloads…',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceView extends StatelessWidget {
  const _AdviceView({
    required this.advice,
    required this.controller,
    required this.onRefresh,
    this.onSelect,
  });

  final PlanAdviceEntity advice;
  final ScrollController controller;
  final VoidCallback onRefresh;
  final ValueChanged<PlanSuggestionEntity>? onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (!advice.hasEnoughHistory) {
      return _MessageView(
        controller: controller,
        icon: Icons.history_rounded,
        message: advice.summary,
      );
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        UsageSummaryCard(summary: advice.summary, stats: advice.stats),
        const SizedBox(height: 16),
        if (advice.suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              advice.tip ?? 'No better plan found right now.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          )
        else ...[
          for (var i = 0; i < advice.suggestions.length; i++)
            SuggestionCard(
              suggestion: advice.suggestions[i],
              isBest: i == 0,
              onSelect: onSelect == null
                  ? null
                  : () {
                      Navigator.of(context).maybePop();
                      onSelect!(advice.suggestions[i]);
                    },
            ),
          if (advice.tip != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 20, color: cs.onSecondaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      advice.tip!,
                      style: text.bodyMedium?.copyWith(color: cs.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 18),
        Text(
          advice.isAiGenerated
              ? 'Suggestions are written by AI from your reload history. Prices and savings are calculated by the app. Check the package details before you buy.'
              : 'AI wasn\'t available, so these are simple estimates from your reload history. Check the package details before you buy.',
          style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
          ),
        ),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.controller,
    required this.message,
    this.icon,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final ScrollController controller;
  final String message;
  final IconData? icon;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Center(
          child: loading
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Icon(icon, size: 44, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ],
      ],
    );
  }
}
