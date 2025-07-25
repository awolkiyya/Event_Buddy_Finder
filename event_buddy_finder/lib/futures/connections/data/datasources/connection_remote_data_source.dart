import 'package:event_buddy_finder/commens/network/api_constants.dart';
import 'package:event_buddy_finder/commens/network/dio_service.dart';
import 'package:event_buddy_finder/futures/connections/data/models/connection_model.dart';

abstract class ConnectionRemoteDataSource {
  Future<List<ConnectionModel>> fetchUserConnections();
  Future<ConnectionModel?> fetchConnectionById(String matchId);
}

class ConnectionRemoteDataSourceImpl implements ConnectionRemoteDataSource {
  final DioService dio;

  ConnectionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ConnectionModel>> fetchUserConnections() async {
    try {
      final response = await dio.get(ApiConstants.getConnections);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ConnectionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch user connections: $e');
    }
  }

  @override
  Future<ConnectionModel?> fetchConnectionById(String matchId) async {
    try {
      final response = await dio.get('/api/connections/$matchId');

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ConnectionModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch connection by ID: $e');
    }
  }
}
