import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/connections/domain/entities/connection_entity.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

class ConnectionInitial extends ConnectionState {}

class ConnectionLoading extends ConnectionState {}

class ConnectionLoaded extends ConnectionState {
  final List<ConnectionEntity> connections;

  const ConnectionLoaded(this.connections);

  @override
  List<Object?> get props => [connections];
}

class SingleConnectionLoaded extends ConnectionState {
  final ConnectionEntity connection;

  const SingleConnectionLoaded(this.connection);

  @override
  List<Object?> get props => [connection];
}

class ConnectionError extends ConnectionState {
  final String message;

  const ConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}
