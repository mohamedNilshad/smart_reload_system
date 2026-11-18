import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';

abstract class PlanSuggestionRepo {
  /// Suggests better reload plans for one of the client's connections.
  Future<Either<Failure, PlanAdviceEntity>> getAdvice({
    required String connectionId,
    bool forceRefresh = false,
  });
}
