import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/bloc/assistant.bloc.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/bloc/assistant.event.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/bloc/assistant.state.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/screens/widgets/assistant_bubble.widget.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/screens/widgets/assistant_composer.widget.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/screens/widgets/typing_indicator.widget.dart';

/// Chat with the AI assistant. Open it from the client dashboard.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  static const _suggestions = [
    'Which data package is cheapest per day?',
    'How do I reload a package?',
    'What does unpaid mean?',
    'I only need a package for calls',
  ];

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // The bloc is an app-level singleton, so the conversation is kept while
    // the app is open. Start one only if there isn't a working one.
    final bloc = context.read<AssistantBloc>();
    final status = bloc.state.status;
    if (status == AssistantStatus.initial || status == AssistantStatus.failure) {
      bloc.add(const AssistantStarted());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String text) => context.read<AssistantBloc>().add(AssistantMessageSent(text));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return BlocConsumer<AssistantBloc, AssistantState>(
      listenWhen: (prev, curr) =>
          prev.messages.length != curr.messages.length ||
          prev.isReplying != curr.isReplying,
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        final canType = state.status == AssistantStatus.ready &&
            !state.isReplying &&
            !state.limitReached;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            backgroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.auto_awesome_rounded,
                      size: 19, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reload Assistant',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'AI · can make mistakes',
                        style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'New chat',
                onPressed: state.isReplying
                    ? null
                    : () => context.read<AssistantBloc>().add(const AssistantStarted()),
                icon: const Icon(Icons.add_comment_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildBody(context, state)),
              AssistantComposer(enabled: canType, onSend: _send),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AssistantState state) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (state.status == AssistantStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 44, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'The assistant isn\'t available right now.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () =>
                    context.read<AssistantBloc>().add(const AssistantStarted()),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status != AssistantStatus.ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final messages = state.messages;
    final onlyGreeting = messages.length == 1 && !state.isReplying;
    final lastIsError =
        messages.isNotEmpty && messages.last.isError && !state.isReplying;

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      children: [
        for (final m in messages) AssistantBubble(message: m),
        if (state.isReplying) const TypingIndicator(),
        if (onlyGreeting) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => _send(s),
                ),
            ],
          ),
        ],
        if (lastIsError)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: TextButton.icon(
                onPressed: () =>
                    context.read<AssistantBloc>().add(const AssistantRetryRequested()),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ),
          ),
        if (state.limitReached)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: cs.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You\'ve reached the limit for this chat. Start a new chat to keep going.',
                    style: text.bodyMedium?.copyWith(color: cs.onSecondaryContainer),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<AssistantBloc>().add(const AssistantStarted()),
                  child: const Text('New chat'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
