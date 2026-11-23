import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/services/assistant_prompt.service.dart';
import 'package:smart_reload_system/src/feature/client/chat/data/datasource/assistant_catalog.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/chat/data/datasource/assistant_model.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/repository/assistant.repo.dart';

class AssistantRepoImpl implements AssistantRepo {
  final AssistantCatalogRemoteDataSource catalog;
  final AssistantModelDataSource model;
  final AssistantPrompt prompt;

  AssistantRepoImpl({
    required this.catalog,
    required this.model,
    this.prompt = const AssistantPrompt(),
  });

  @override
  Future<Either<Failure, Unit>> startConversation() async {
    try {
      final packages = await catalog.load();
      model.start(prompt.build(packages));
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure('The assistant isn\'t available right now.'));
    }
  }

  @override
  Future<Either<Failure, String>> ask(String text) async {
    try {
      return Right(await model.send(text));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
