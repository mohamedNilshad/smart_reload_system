import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/candidate_package.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/connection_info.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/reload_record.entity.dart';

/// Everything loaded from Firestore for one connection.
class PlanSuggestionInputEntity extends Equatable {
  final ConnectionInfoEntity connection;

  /// Oldest first.
  final List<ReloadRecordEntity> history;
  final List<CandidatePackageEntity> candidates;

  const PlanSuggestionInputEntity({
    required this.connection,
    required this.history,
    required this.candidates,
  });

  @override
  List<Object?> get props => [connection, history, candidates];
}
