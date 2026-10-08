import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/add_new_connection.usecase.dart' show AddNewConnectionUseCase;
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_connections.usecase.dart';
import 'connection.event.dart';
import 'connection.state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final GetConnectionsUseCase getConnectionsUseCase;
  final AddNewConnectionUseCase addNewConnectionUseCase;

  ConnectionBloc({
    required this.getConnectionsUseCase,
    required this.addNewConnectionUseCase,
  }) : super(const ConnectionInitial()) {
    on<ConnectionsRequested>(_onConnectionsRequested);
    on<ConnectionsReset>(_onConnectionsReset);
    on<AddNewConnectionRequested>(_onAddNewConnectionRequested);
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

  Future<void> _onAddNewConnectionRequested(AddNewConnectionRequested event, Emitter<ConnectionState> emit) async {
    emit(const ConnectionLoading());

    final result = await addNewConnectionUseCase(connectionModel: event.connectionModel);

    result.fold(
      (failure) => emit(ConnectionFailure(failure.message)),
      (success) => emit(ConnectionSuccess([])), // Adjust this based on your needs
    );
  }
}
