import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/usecase/get_wallet_summary.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet.event.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet.state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletSummaryUseCase getWalletSummaryUseCase;

  WalletBloc({required this.getWalletSummaryUseCase}) : super(const WalletInitial()) {
    on<WalletRequested>(_onWalletRequested);
    on<WalletReset>(_onWalletReset);
  }

  Future<void> _onWalletRequested(
    WalletRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final result = await getWalletSummaryUseCase();

    result.fold(
      (failure) => emit(WalletFailure(failure.message)),
      (summary) => emit(WalletSuccess(summary)),
    );
  }

  Future<void> _onWalletReset(
    WalletReset event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletInitial());
  }
}
