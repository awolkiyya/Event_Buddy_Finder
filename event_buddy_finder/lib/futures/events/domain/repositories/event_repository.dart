import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';

import '../entities/event.dart';

abstract class EventRepository {
  Future<List<EventEntity>> getAllEvents();
  Future<List<UserEntity>> getAttendeesByIds(List<String> attendeeIds);
  Future<void> joinEvent(String eventId, String userId);
}