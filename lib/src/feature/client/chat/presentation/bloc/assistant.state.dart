import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/entity/assistant_message.entity.dart';

/// Most customer messages in one conversation. Every message re-sends the
/// conversation to the model, so this keeps usage inside the free quota.
const kMaxUserMessages = 30;

enum AssistantStatus { initial, starting, ready, failure }

class AssistantState extends Equatable {
  final AssistantStatus status;

  /// Oldest first.
  final List<AssistantMessageEntity> messages;
  final bool isReplying;
  final int userMessageCount;

  /// Set when the conversation could not be started.
  final String? errorMessage;

  const AssistantState({
    this.status = AssistantStatus.initial,
    this.messages = const [],
    this.isReplying = false,
    this.userMessageCount = 0,
    this.errorMessage,
  });

  bool get limitReached => userMessageCount >= kMaxUserMessages;

  AssistantState copyWith({
    AssistantStatus? status,
    List<AssistantMessageEntity>? messages,
    bool? isReplying,
    int? userMessageCount,
    String? errorMessage,
  }) {
    return AssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isReplying: isReplying ?? this.isReplying,
      userMessageCount: userMessageCount ?? this.userMessageCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, messages, isReplying, userMessageCount, errorMessage];
}
