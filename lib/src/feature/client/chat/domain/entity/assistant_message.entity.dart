import 'package:equatable/equatable.dart';

class AssistantMessageEntity extends Equatable {
  final int id;
  final String text;
  final bool isUser;

  /// An error shown in the conversation (for example "busy right now").
  final bool isError;

  const AssistantMessageEntity({
    required this.id,
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  List<Object?> get props => [id, text, isUser, isError];
}
