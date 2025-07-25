import 'package:event_buddy_finder/futures/connections/domain/entities/connection_entity.dart';

abstract class ConnectionsRepository {
  /// Fetch all connections (matches) for the current authenticated user.
  Future<List<ConnectionEntity>> getUserConnections();

  /// Optional: fetch details for a specific connection/match by ID.
  Future<ConnectionEntity?> getConnectionById(String matchId);

  /// (Optional) Add more methods if you want to update, delete, etc.
}
