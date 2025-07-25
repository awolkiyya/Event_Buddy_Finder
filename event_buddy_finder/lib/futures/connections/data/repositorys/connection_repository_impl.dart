import 'package:event_buddy_finder/futures/connections/data/datasources/connection_remote_data_source.dart';
import 'package:event_buddy_finder/futures/connections/data/models/connection_model.dart';
import 'package:event_buddy_finder/futures/connections/domain/entities/connection_entity.dart';
import 'package:event_buddy_finder/futures/connections/domain/repositorys/connections_repository.dart';

class ConnectionRepositoryImpl implements ConnectionsRepository {
  final ConnectionRemoteDataSource remoteDataSource;

  ConnectionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ConnectionEntity>> getUserConnections() async {
    try {
      final List<ConnectionModel> models = await remoteDataSource.fetchUserConnections();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Handle or log error if needed
      rethrow;
    }
  }

  @override
  Future<ConnectionEntity?> getConnectionById(String matchId) async {
    try {
      final ConnectionModel? model = await remoteDataSource.fetchConnectionById(matchId);
      return model?.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
