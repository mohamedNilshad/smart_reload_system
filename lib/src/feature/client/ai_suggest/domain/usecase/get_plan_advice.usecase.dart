import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/repository/plan_suggestion.repo.dart';

class GetPlanAdviceUseCase {
  final PlanSuggestionRepo repo;
  GetPlanAdviceUseCase(this.repo);

  Future<Either<Failure, PlanAdviceEntity>> call({
    required String connectionId,
    bool forceRefresh = false,
  }) {
    return repo.getAdvice(connectionId: connectionId, forceRefresh: forceRefresh);
  }
}
