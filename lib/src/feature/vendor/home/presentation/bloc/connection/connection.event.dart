import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';

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

class AddNewConnectionRequested extends ConnectionEvent {
  final ConnectionModel connectionModel;
  const AddNewConnectionRequested(this.connectionModel);

  @override
  List<Object?> get props => [connectionModel];
}
