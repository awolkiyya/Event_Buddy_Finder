import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserConnections extends ConnectionEvent {}

class FetchConnectionById extends ConnectionEvent {
  final String matchId;

  const FetchConnectionById(this.matchId);

  @override
  List<Object?> get props => [matchId];
}
