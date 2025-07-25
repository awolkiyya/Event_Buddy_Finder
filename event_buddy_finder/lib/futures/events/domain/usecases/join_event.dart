import '../repositories/event_repository.dart';

class JoinEventUseCase {
  final EventRepository repository;

  JoinEventUseCase(this.repository);

  Future<void> execute(String eventId, String userId) {
    return repository.joinEvent(eventId, userId);
  }
}
