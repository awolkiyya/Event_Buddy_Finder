import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetAllEventsUseCase {
  final EventRepository repository;

  GetAllEventsUseCase(this.repository);

  Future<List<EventEntity>> call() async {
    return await repository.getAllEvents();
  }
}
