import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/entity/assistant_message.entity.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/usecase/ask_assistant.usecase.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/usecase/start_assistant_conversation.usecase.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/bloc/assistant.event.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/bloc/assistant.state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final StartAssistantConversationUseCase startConversationUseCase;
  final AskAssistantUseCase askAssistantUseCase;

  static const greeting =
      'Hi! I\'m your Reload Assistant. Ask me about packages, reloads or payments.';

  int _nextId = 0;
  String? _lastUserText;

  /// Ignores answers that arrive after the customer started a new chat.
  int _session = 0;

  AssistantBloc({
    required this.startConversationUseCase,
    required this.askAssistantUseCase,
  }) : super(const AssistantState()) {
    on<AssistantStarted>(_onStarted);
    on<AssistantMessageSent>(_onMessageSent);
    on<AssistantRetryRequested>(_onRetry);
  }

  AssistantMessageEntity _message(String text,
      {required bool isUser, bool isError = false}) {
    return AssistantMessageEntity(
      id: _nextId++,
      text: text,
      isUser: isUser,
      isError: isError,
    );
  }

  Future<void> _onStarted(
    AssistantStarted event,
    Emitter<AssistantState> emit,
  ) async {
    final session = ++_session;
    _lastUserText = null;
    emit(const AssistantState(status: AssistantStatus.starting));

    final result = await startConversationUseCase();
    if (session != _session) return;

    result.fold(
      (failure) => emit(
        AssistantState(
          status: AssistantStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        AssistantState(
          status: AssistantStatus.ready,
          messages: [_message(greeting, isUser: false)],
        ),
      ),
    );
  }

  Future<void> _onMessageSent(
    AssistantMessageSent event,
    Emitter<AssistantState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty || text.length > 1000) return;
    if (state.status != AssistantStatus.ready) return;
    if (state.isReplying || state.limitReached) return;

    _lastUserText = text;
    emit(
      state.copyWith(
        messages: [...state.messages, _message(text, isUser: true)],
        userMessageCount: state.userMessageCount + 1,
        isReplying: true,
      ),
    );
    await _ask(text, emit);
  }

  Future<void> _onRetry(
    AssistantRetryRequested event,
    Emitter<AssistantState> emit,
  ) async {
    final text = _lastUserText;
    if (text == null || state.isReplying) return;
    if (state.messages.isEmpty || !state.messages.last.isError) return;

    // Drop the error bubble and ask again; the customer's message is still
    // in the list.
    emit(
      state.copyWith(
        messages: state.messages.sublist(0, state.messages.length - 1),
        isReplying: true,
      ),
    );
    await _ask(text, emit);
  }

  Future<void> _ask(String text, Emitter<AssistantState> emit) async {
    final session = _session;
    final result = await askAssistantUseCase(text);
    if (session != _session) return; // a new chat was started meanwhile

    result.fold(
      (failure) => emit(
        state.copyWith(
          messages: [
            ...state.messages,
            _message(failure.message, isUser: false, isError: true),
          ],
          isReplying: false,
        ),
      ),
      (reply) => emit(
        state.copyWith(
          messages: [...state.messages, _message(reply, isUser: false)],
          isReplying: false,
        ),
      ),
    );
  }
}
