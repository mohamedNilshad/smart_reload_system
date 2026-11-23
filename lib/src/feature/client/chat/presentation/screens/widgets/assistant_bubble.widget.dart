import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/entity/assistant_message.entity.dart';

/// One chat bubble. The customer's are blue on the right; the assistant's are
/// grey on the left with a small sparkle avatar.
class AssistantBubble extends StatelessWidget {
  const AssistantBubble({super.key, required this.message});

  final AssistantMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final isUser = message.isUser;
    final Color bg;
    final Color fg;
    if (isUser) {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else if (message.isError) {
      bg = cs.errorContainer;
      fg = cs.onErrorContainer;
    } else {
      bg = cs.surfaceContainerHigh;
      fg = cs.onSurface;
    }

    const big = Radius.circular(18);
    const small = Radius.circular(4);
    final radius = BorderRadius.only(
      topLeft: big,
      topRight: big,
      bottomLeft: isUser ? big : small,
      bottomRight: isUser ? small : big,
    );

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.78 : 0.7),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: isUser
            ? Text(message.text,
                style: text.bodyMedium?.copyWith(color: fg, height: 1.35))
            : SelectableText(message.text,
                style: text.bodyMedium?.copyWith(color: fg, height: 1.35)),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: bubble,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: message.isError ? cs.errorContainer : cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.isError ? Icons.error_outline_rounded : Icons.auto_awesome_rounded,
                size: 15,
                color: message.isError ? cs.onErrorContainer : cs.onPrimaryContainer,
              ),
            ),
            Flexible(child: bubble),
          ],
        ),
      ),
    );
  }
}
