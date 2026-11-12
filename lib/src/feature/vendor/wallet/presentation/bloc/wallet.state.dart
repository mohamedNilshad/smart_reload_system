import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/wallet_summary.entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletSuccess extends WalletState {
  final WalletSummaryEntity summary;

  const WalletSuccess(this.summary);

  @override
  List<Object?> get props => [summary];
}

class WalletFailure extends WalletState {
  final String message;

  const WalletFailure(this.message);

  @override
  List<Object?> get props => [message];
}
