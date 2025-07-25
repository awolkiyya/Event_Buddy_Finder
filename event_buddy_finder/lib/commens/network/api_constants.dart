class ApiConstants {
  static const String baseUrl = 'http://192.168.8.115:3000/api/v1';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // User profile endpoints
  static const String saveUserProfile = '$baseUrl/user/profile/save';
  static const String getUserProfile = '$baseUrl/user/profile';

  // Event endpoints
  static const String getEvents = '$baseUrl/event/allEvents';
  static const String createEvent = '$baseUrl/events/create';
  static const String updateEvent = '$baseUrl/events/update'; // Usually requires event ID appended
  static const String deleteEvent = '$baseUrl/events/delete'; // Usually requires event ID appended

  // Attendees by IDs (POST with attendeeIds in body)
  static const String getAttendeesByIds = '$baseUrl/event/attendeesByIds';

 // Join event route with dynamic eventId in URL
static String joinEvent(String eventId) => '$baseUrl/event/$eventId/join';

  // Send connection request (POST with fromUserId, toUserId, eventId)
  static const String sendConnectionRequest = '$baseUrl/connection/request';

  // Example dynamic event URL by ID
  static String eventById(String eventId) => '$baseUrl/events/$eventId';
    // ✅ Chat endpoint
  static String getChatMessages(String matchId) => '$baseUrl/chat/$matchId';
  // '/matches
    static const String getConnections = '$baseUrl/connection/matches';

}
