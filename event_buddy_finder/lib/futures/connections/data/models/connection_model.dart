import 'package:event_buddy_finder/futures/connections/data/models/UserModel.dart';
import 'package:event_buddy_finder/futures/connections/domain/entities/connection_entity.dart';
import 'package:event_buddy_finder/futures/connections/domain/entities/user_entity.dart' as connection_user_entity;


class ConnectionModel extends ConnectionEntity {
  ConnectionModel({
    required String matchId,
    required connection_user_entity.UserEntity matchedUser,
    required String eventId,
    required DateTime matchDate,
  }) : super(
          matchId: matchId,
          matchedUser: matchedUser,
          eventId: eventId,
          matchDate: matchDate,
        );

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      matchId: json['_id'] as String,
      matchedUser: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      eventId: json['eventId'] as String,
      matchDate: DateTime.parse(json['matchDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': matchId,
      'user': (matchedUser as UserModel).toJson(),
      'eventId': eventId,
      'matchDate': matchDate.toIso8601String(),
    };
  }

  ConnectionEntity toEntity() {
    return ConnectionEntity(
      matchId: matchId,
      matchedUser: matchedUser,
      eventId: eventId,
      matchDate: matchDate,
    );
  }
}
