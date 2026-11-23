import 'package:equatable/equatable.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Starts a new conversation (also used by the "New chat" button).
class AssistantStarted extends AssistantEvent {
  const AssistantStarted();
}

class AssistantMessageSent extends AssistantEvent {
  final String text;

  const AssistantMessageSent(this.text);

  @override
  List<Object?> get props => [text];
}

/// Sends the last message again after an error.
class AssistantRetryRequested extends AssistantEvent {
  const AssistantRetryRequested();
}
