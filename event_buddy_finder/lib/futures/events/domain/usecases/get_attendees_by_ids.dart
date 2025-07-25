import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import '../repositories/event_repository.dart';

class GetAttendeesByIdsUseCase {
  final EventRepository repository;

  GetAttendeesByIdsUseCase(this.repository);

  Future<List<UserEntity>> execute(List<String> attendeeIds) {
    return repository.getAttendeesByIds(attendeeIds);
  }
}
