import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';

abstract class PlanSuggestionState extends Equatable {
  const PlanSuggestionState();

  @override
  List<Object?> get props => [];
}

class PlanSuggestionInitial extends PlanSuggestionState {
  const PlanSuggestionInitial();
}

class PlanSuggestionLoading extends PlanSuggestionState {
  const PlanSuggestionLoading();
}

class PlanSuggestionSuccess extends PlanSuggestionState {
  final PlanAdviceEntity advice;

  const PlanSuggestionSuccess(this.advice);

  @override
  List<Object?> get props => [advice];
}

class PlanSuggestionFailureState extends PlanSuggestionState {
  final String message;

  const PlanSuggestionFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
