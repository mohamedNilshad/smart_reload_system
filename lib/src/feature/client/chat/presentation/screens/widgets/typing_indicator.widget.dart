import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Three bouncing dots shown while the assistant is writing a reply.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 38, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.onSurfaceVariant.withValues(
                        alpha: 0.3 + 0.7 * ((math.sin(_controller.value * 2 * math.pi - i * 0.9) + 1) / 2),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
