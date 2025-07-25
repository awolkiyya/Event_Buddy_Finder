import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_event.dart';
import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_buddy_finder/futures/connections/domain/repositorys/connections_repository.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final ConnectionsRepository repository;

  ConnectionBloc(this.repository) : super(ConnectionInitial()) {
    on<FetchUserConnections>(_onFetchUserConnections);
    on<FetchConnectionById>(_onFetchConnectionById);
  }

  Future<void> _onFetchUserConnections(
    FetchUserConnections event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(ConnectionLoading());
    try {
      final connections = await repository.getUserConnections();
      emit(ConnectionLoaded(connections));
    } catch (e) {
      emit(ConnectionError(e.toString()));
    }
  }

  Future<void> _onFetchConnectionById(
    FetchConnectionById event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(ConnectionLoading());
    try {
      final connection = await repository.getConnectionById(event.matchId);
      if (connection != null) {
        emit(SingleConnectionLoaded(connection));
      } else {
        emit(const ConnectionError('Connection not found'));
      }
    } catch (e) {
      emit(ConnectionError(e.toString()));
    }
  }
}
