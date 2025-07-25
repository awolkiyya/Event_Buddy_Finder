import 'package:equatable/equatable.dart';

abstract class EventListEvent extends Equatable {
  const EventListEvent();

  @override
  List<Object?> get props => [];
}

class FetchEvents extends EventListEvent {}

class FilterEvents extends EventListEvent {
  final String? selectedInterest;
  final String? selectedLocation;
  final double? maxDistanceKm;
  final double? currentLatitude;
  final double? currentLongitude;

  const FilterEvents({
    this.selectedInterest,
    this.selectedLocation,
    this.maxDistanceKm,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  List<Object?> get props => [
        selectedInterest,
        selectedLocation,
        maxDistanceKm,
        currentLatitude,
        currentLongitude,
      ];
}
