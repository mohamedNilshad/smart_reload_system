import 'package:equatable/equatable.dart';

abstract class PlanSuggestionEvent extends Equatable {
  const PlanSuggestionEvent();

  @override
  List<Object?> get props => [];
}

class PlanSuggestionRequested extends PlanSuggestionEvent {
  final String connectionId;

  /// True when the customer taps "Refresh" (the repository still limits how
  /// often this can trigger a new AI call).
  final bool forceRefresh;

  const PlanSuggestionRequested({
    required this.connectionId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [connectionId, forceRefresh];
}

/// Clears state left over from an earlier visit (the bloc is an app-level
/// singleton).
class PlanSuggestionReset extends PlanSuggestionEvent {
  const PlanSuggestionReset();
}
