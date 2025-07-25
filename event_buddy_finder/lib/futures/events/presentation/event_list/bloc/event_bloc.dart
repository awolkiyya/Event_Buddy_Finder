// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_buddy_finder/futures/events/domain/usecases/get_all_events_usecase.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_event.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';


class EventListBloc extends Bloc<EventListEvent, EventListState> {
  final GetAllEventsUseCase getAllEventsUseCase;

  EventListBloc({required this.getAllEventsUseCase}) : super(EventListInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<FilterEvents>(_onFilterEvents);
  }

  Future<void> _onFetchEvents(FetchEvents event, Emitter<EventListState> emit) async {
    emit(EventListLoading());
    try {
      final allEvents = await getAllEventsUseCase();
      emit(EventListLoaded(
        allEvents: allEvents,
        filteredEvents: allEvents,
      ));
    } catch (e) {
      emit(EventListError("Failed to load events: ${e.toString()}"));
    }
  }

  void _onFilterEvents(FilterEvents event, Emitter<EventListState> emit) {
    final currentState = state;
    if (currentState is! EventListLoaded) return;

    final filtered = currentState.allEvents.where((e) {
      final matchInterest = event.selectedInterest == null ||
          e.tags.contains(event.selectedInterest);

      final matchLocation = event.selectedLocation == null ||
          e.location.toLowerCase().contains(event.selectedLocation!.toLowerCase());

      final matchDistance = event.maxDistanceKm == null || (e.latitude != null && e.longitude != null && event.currentLatitude != null && event.currentLongitude != null
          ? _calculateDistance(
              e.latitude!, e.longitude!,
              event.currentLatitude!, event.currentLongitude!,
            ) <= event.maxDistanceKm!
          : false);

      return matchInterest && matchLocation && matchDistance;
    }).toList();

    emit(currentState.copyWith(
      filteredEvents: filtered,
      selectedInterest: event.selectedInterest,
      selectedLocation: event.selectedLocation,
      maxDistanceKm: event.maxDistanceKm,
    ));
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // in km
  }
}
