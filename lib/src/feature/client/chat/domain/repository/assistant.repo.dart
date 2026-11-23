import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';

abstract class AssistantRepo {
  /// Starts a fresh conversation (loads the package list the assistant uses).
  Future<Either<Failure, Unit>> startConversation();

  /// Sends one customer message and returns the assistant's reply. The model
  /// remembers earlier messages of the current conversation.
  Future<Either<Failure, String>> ask(String text);
}
