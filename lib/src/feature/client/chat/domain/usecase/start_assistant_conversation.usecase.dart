import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/repository/assistant.repo.dart';

class StartAssistantConversationUseCase {
  final AssistantRepo repo;
  StartAssistantConversationUseCase(this.repo);

  Future<Either<Failure, Unit>> call() => repo.startConversation();
}
