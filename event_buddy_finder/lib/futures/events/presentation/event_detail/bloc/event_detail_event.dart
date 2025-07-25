import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/events/domain/entities/event.dart';

abstract class EventDetailEvent extends Equatable {
  const EventDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendees extends EventDetailEvent {
  final EventEntity event;
  final List<String> attendeesIds;

  const LoadAttendees({required this.event, required this.attendeesIds});

  @override
  List<Object?> get props => [event, attendeesIds];
}

class JoinEvent extends EventDetailEvent {
  final String eventId;
  final String currentUserId;
  final List<String> attendeesIds;
  final EventEntity event;

  const JoinEvent({
    required this.eventId,
    required this.currentUserId,
    required this.attendeesIds,
    required this.event,
  });

  @override
  List<Object?> get props => [eventId, currentUserId, attendeesIds, event];
}
