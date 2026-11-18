import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/usecase/get_plan_advice.usecase.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/bloc/plan_suggestion.event.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/presentation/bloc/plan_suggestion.state.dart';

class PlanSuggestionBloc extends Bloc<PlanSuggestionEvent, PlanSuggestionState> {
  final GetPlanAdviceUseCase getPlanAdviceUseCase;

  /// Lets the newest request win if the customer reopens or refreshes quickly.
  int _requestId = 0;

  PlanSuggestionBloc({required this.getPlanAdviceUseCase})
      : super(const PlanSuggestionInitial()) {
    on<PlanSuggestionRequested>(_onRequested);
    on<PlanSuggestionReset>((_, emit) {
      _requestId++;
      emit(const PlanSuggestionInitial());
    });
  }

  Future<void> _onRequested(
    PlanSuggestionRequested event,
    Emitter<PlanSuggestionState> emit,
  ) async {
    final id = ++_requestId;
    emit(const PlanSuggestionLoading());

    final result = await getPlanAdviceUseCase(
      connectionId: event.connectionId,
      forceRefresh: event.forceRefresh,
    );

    if (id != _requestId) return; // superseded by a newer request
    result.fold(
      (failure) => emit(PlanSuggestionFailureState(failure.message)),
      (advice) => emit(PlanSuggestionSuccess(advice)),
    );
  }
}
