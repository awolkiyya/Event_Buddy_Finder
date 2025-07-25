import 'package:event_buddy_finder/futures/events/data/models/event_model.dart';
import 'package:event_buddy_finder/futures/auth/data/models/user_model.dart';

import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventModel>> getAllEvents() async {
    final models = await remoteDataSource.getAllEvents();
    return models;
  }

  @override
  Future<List<UserModel>> getAttendeesByIds(List<String> attendeeIds) async {
    final attendees = await remoteDataSource.getAttendeesByIds(attendeeIds);
    return attendees;
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    await remoteDataSource.joinEvent(eventId, userId);
  }
}
