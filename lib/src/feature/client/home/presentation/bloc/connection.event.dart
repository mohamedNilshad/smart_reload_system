import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

class ConnectionsRequested extends ConnectionEvent {
  final String clientVendorId;
  const ConnectionsRequested(this.clientVendorId);

  @override
  List<Object?> get props => [clientVendorId];
}

class ConnectionsReset extends ConnectionEvent {
  const ConnectionsReset();
}
