import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/events/domain/entities/event.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();

  @override
  List<Object?> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailLoaded extends EventDetailState {
  final EventEntity event;
  final List<UserEntity> attendees;

  const EventDetailLoaded({
    required this.event,
    required this.attendees,
  });

  @override
  List<Object?> get props => [event, attendees];
}

class EventDetailJoinLoading extends EventDetailState {}

class EventDetailJoinSuccess extends EventDetailState {}

class EventDetailError extends EventDetailState {
  final String message;

  const EventDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
