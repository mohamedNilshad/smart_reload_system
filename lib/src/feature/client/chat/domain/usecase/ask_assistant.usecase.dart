import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/repository/assistant.repo.dart';

class AskAssistantUseCase {
  final AssistantRepo repo;
  AskAssistantUseCase(this.repo);

  Future<Either<Failure, String>> call(String text) => repo.ask(text);
}
