


import 'package:event_buddy_finder/futures/connections/domain/entities/user_entity.dart';

class ConnectionEntity {
  final String matchId;       // ID of the match document
  final UserEntity matchedUser; // The other user in this connection
  final String eventId;       // The event related to the match
  final DateTime matchDate;   // When the match was created

  ConnectionEntity({
    required this.matchId,
    required this.matchedUser,
    required this.eventId,
    required this.matchDate,
  });
}
