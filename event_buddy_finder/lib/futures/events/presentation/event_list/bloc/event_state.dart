
import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/events/domain/entities/event.dart';

abstract class EventListState extends Equatable {
  const EventListState();

  @override
  List<Object?> get props => [];
}

class EventListInitial extends EventListState {}

class EventListLoading extends EventListState {}

class EventListLoaded extends EventListState {
  final List<EventEntity> allEvents;
  final List<EventEntity> filteredEvents;
  final String? selectedInterest;
  final String? selectedLocation;
  final double? maxDistanceKm;

  const EventListLoaded({
    required this.allEvents,
    required this.filteredEvents,
    this.selectedInterest,
    this.selectedLocation,
    this.maxDistanceKm,
  });

  EventListLoaded copyWith({
    List<EventEntity>? allEvents,
    List<EventEntity>? filteredEvents,
    String? selectedInterest,
    String? selectedLocation,
    double? maxDistanceKm,
  }) {
    return EventListLoaded(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      selectedInterest: selectedInterest ?? this.selectedInterest,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }

  @override
  List<Object?> get props =>
      [allEvents, filteredEvents, selectedInterest, selectedLocation, maxDistanceKm];
}

class EventListError extends EventListState {
  final String message;

  const EventListError(this.message);

  @override
  List<Object?> get props => [message];
}
