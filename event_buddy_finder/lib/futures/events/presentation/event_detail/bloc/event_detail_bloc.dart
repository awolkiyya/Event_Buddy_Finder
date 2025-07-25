import 'package:bloc/bloc.dart';
import 'package:event_buddy_finder/futures/events/domain/usecases/get_attendees_by_ids.dart';
import 'package:event_buddy_finder/futures/events/domain/usecases/join_event.dart';
import 'event_detail_event.dart';
import 'event_detail_state.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  final GetAttendeesByIdsUseCase  getAttendeesByIdsUseCase;
  final JoinEventUseCase joinEventUseCase;

  EventDetailBloc({
    required this.getAttendeesByIdsUseCase,
    required this.joinEventUseCase,
  }) : super(EventDetailInitial()) {
    on<LoadAttendees>(_onLoadAttendees);
    on<JoinEvent>(_onJoinEvent);
  }

  Future<void> _onLoadAttendees(
      LoadAttendees event, Emitter<EventDetailState> emit) async {
    emit(EventDetailLoading());
    try {
      final attendees = await getAttendeesByIdsUseCase.execute(event.attendeesIds);
      emit(EventDetailLoaded(event: event.event, attendees: attendees));
    } catch (e) {
      emit(EventDetailError('Failed to load attendees: $e'));
    }
  }

  Future<void> _onJoinEvent(JoinEvent event, Emitter<EventDetailState> emit) async {
    emit(EventDetailJoinLoading());
    try {
      await joinEventUseCase.execute(event.eventId, event.currentUserId);

      // After joining, reload attendees list only (event is same)
      final attendees = await getAttendeesByIdsUseCase.execute(event.attendeesIds);
      emit(EventDetailLoaded(event: event.event, attendees: attendees));

      emit(EventDetailJoinSuccess());
    } catch (e) {
      emit(EventDetailError('Failed to join event: $e'));
    }
  }
}
