import 'package:flutter/material.dart';

/// Text box with a send button at the bottom of the assistant chat.
class AssistantComposer extends StatefulWidget {
  const AssistantComposer({super.key, required this.onSend, this.enabled = true});

  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  State<AssistantComposer> createState() => _AssistantComposerState();
}

class _AssistantComposerState extends State<AssistantComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    OutlineInputBorder border() => OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        );

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.6))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  decoration: InputDecoration(
                    hintText: widget.enabled ? 'Ask about packages or reloads' : 'Please wait…',
                    filled: true,
                    fillColor: cs.surfaceContainerHigh,
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: border(),
                    enabledBorder: border(),
                    disabledBorder: border(),
                    focusedBorder: border(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final canSend = widget.enabled && value.text.trim().isNotEmpty;
                  return IconButton.filled(
                    tooltip: 'Send',
                    onPressed: canSend ? _send : null,
                    icon: const Icon(Icons.send_rounded, size: 20),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
