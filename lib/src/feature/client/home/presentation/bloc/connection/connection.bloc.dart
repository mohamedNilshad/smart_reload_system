import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_connections.usecase.dart';
import 'connection.event.dart';
import 'connection.state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final GetConnectionsUseCase getConnectionsUseCase;

  ConnectionBloc({required this.getConnectionsUseCase}) : super(const ConnectionInitial()) {
    on<ConnectionsRequested>(_onConnectionsRequested);
    on<ConnectionsReset>(_onConnectionsReset);
  }

  Future<void> _onConnectionsRequested(ConnectionsRequested event, Emitter<ConnectionState> emit) async {
    emit(const ConnectionLoading());

    final result = await getConnectionsUseCase(event.clientVendorId);

    result.fold(
      (failure) => emit(ConnectionFailure(failure.message)),
      (connections) => emit(ConnectionSuccess(connections)),
    );
  }

  Future<void> _onConnectionsReset(ConnectionsReset event, Emitter<ConnectionState> emit) async {
    emit(const ConnectionInitial());
  }
}
