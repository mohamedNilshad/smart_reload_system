import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

class ConnectionInitial extends ConnectionState {
  const ConnectionInitial();
}

class ConnectionLoading extends ConnectionState {
  const ConnectionLoading();
}

class ConnectionSuccess extends ConnectionState {
  final List<ConnectionModel> connections;
  const ConnectionSuccess(this.connections);

  @override
  List<Object?> get props => [connections];
}

class ConnectionFailure extends ConnectionState {
  final String message;
  const ConnectionFailure(this.message);

  @override
  List<Object?> get props => [message];
}