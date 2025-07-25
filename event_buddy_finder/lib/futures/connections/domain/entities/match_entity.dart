// domain/entities/match_entity.dart
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';

class MatchEntity {
  final String id;
  final UserEntity user1;
  final UserEntity user2;
  final String eventId;
  final DateTime matchDate;

  MatchEntity({
    required this.id,
    required this.user1,
    required this.user2,
    required this.eventId,
    required this.matchDate,
  });
}
