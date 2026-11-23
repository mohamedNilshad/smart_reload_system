import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/screens/assistant.screen.dart';

/// Tile for the client dashboard that opens the AI assistant.
class AssistantEntry extends StatelessWidget {
  const AssistantEntry({
    super.key,
    this.title = 'Ask the AI assistant',
    this.subtitle = 'Packages, reloads and payments explained',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: cs.onPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.8),
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
