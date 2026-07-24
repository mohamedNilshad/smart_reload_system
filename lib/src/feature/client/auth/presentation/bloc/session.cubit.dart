import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/get_cached_user.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/watch_auth_state.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.state.dart';

class SessionCubit extends Cubit<SessionState> {
  final WatchAuthStateUseCase watchAuthStateUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;
  StreamSubscription? _subscription;

  SessionCubit({
    required this.watchAuthStateUseCase,
    required this.getCachedUserUseCase,
  }) : super(SessionInitial()) {
    _init();
  }

  Future<void> _init() async {
    // 1. Optimistic paint from secure local cache — skips the splash flash
    //    on repeat launches when we're confident the session is still valid.
    final cachedUser = await getCachedUserUseCase();
    if (cachedUser != null && !isClosed) {
      emit(SessionAuthenticated(cachedUser));
    }

    // 2. Source of truth — confirms or corrects the optimistic state above.
    //    If the token actually expired/was revoked, this flips to
    //    SessionUnauthenticated shortly after, even if we emitted optimistic
    //    auth a moment earlier.
    _subscription = watchAuthStateUseCase().listen((user) {
      if (isClosed) return;
      emit(user != null ? SessionAuthenticated(user) : SessionUnauthenticated());
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}