import 'package:dio/dio.dart';
import 'package:event_buddy_finder/commens/network/api_constants.dart';
import 'package:event_buddy_finder/commens/network/dio_service.dart';
import 'package:event_buddy_finder/futures/auth/data/models/user_model.dart';
import '../models/event_model.dart';

class EventRemoteDataSource {
  final DioService _dioService;

  EventRemoteDataSource(this._dioService);

  Future<List<EventModel>> getAllEvents() async {
    try {
      final Response response = await _dioService.get(ApiConstants.getEvents);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data.containsKey('events')) {
          final eventsJson = data['events'] as List<dynamic>;
          return eventsJson.map((e) => EventModel.fromJson(e)).toList();
        }

        if (data is List) {
          return data.map((e) => EventModel.fromJson(e)).toList();
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception('Failed to fetch events: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Dio error: $e');
    }
  }

Future<List<UserModel>> getAttendeesByIds(List<String> attendeeIds) async {
  try {
    final Response response = await _dioService.post(
      ApiConstants.getAttendeesByIds,
      data: {'attendeeIds': attendeeIds},
    );

    if (response.statusCode == 200) {
      final attendees = response.data['attendees'];
      if (attendees is List) {
        return attendees.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Expected attendees list but got: $attendees');
      }
    } else {
      throw Exception('Failed to fetch attendees: ${response.statusMessage}');
    }
  } catch (e) {
    throw Exception('Error fetching attendees: $e');
  }
}


  Future<void> joinEvent(String eventId, String userId) async {
    try {
      final url = ApiConstants.joinEvent(eventId);
      final Response response = await _dioService.post(
        url,
        data: {
          'userId': userId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to join event: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Dio error: $e');
    }
  }
}
