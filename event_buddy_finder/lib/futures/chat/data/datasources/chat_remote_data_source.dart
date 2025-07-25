import 'package:event_buddy_finder/commens/network/api_constants.dart';
import 'package:event_buddy_finder/commens/network/dio_service.dart';
import 'package:event_buddy_finder/commens/services/socketIOService.dart';
import 'package:event_buddy_finder/futures/chat/data/models/chat_message_model.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/online_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/read_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/typing_status.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> fetchMessages({required String chatRoomId});

  void sendMessage(ChatMessageModel message);
  void listenToMessages(Function(ChatMessageModel) onMessageReceived);

  void setOnlineStatus(String userId, bool isOnline);
  void listenToOnlineStatus(Function(OnlineStatus) onStatusChanged);

  void updateTypingStatus({required String chatRoomId, required String userId, required bool isTyping});
  void listenToTypingStatus(Function(TypingStatus) onTypingChanged);

  void markMessageAsRead({required String chatRoomId, required String messageId, required String userId});
  void listenToReadStatus(Function(ReadStatus) onReadStatusChanged);

  void dispose();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SocketIOService socketService;
  final DioService dio;

  ChatRemoteDataSourceImpl({
    required this.socketService,
    required this.dio,
  });

  @override
  Future<List<ChatMessageModel>> fetchMessages({required String chatRoomId}) async {
    try {
      final uri = ApiConstants.getChatMessages(chatRoomId);
      final response = await dio.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final messages = data.map((json) => ChatMessageModel.fromJson(json)).toList();
        return messages;
      } else {
        throw Exception('Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  @override
  void sendMessage(ChatMessageModel message) {
    socketService.emit('send_message', message.toJson());
  }

  @override
  void listenToMessages(Function(ChatMessageModel) onMessageReceived) {
    socketService.on('receive_message', (data) {
      try {
        final message = ChatMessageModel.fromJson(Map<String, dynamic>.from(data));
        onMessageReceived(message);
      } catch (e) {
        print("❌ Error parsing chat message: $e");
      }
    });
  }

  @override
  void setOnlineStatus(String userId, bool isOnline) {
    socketService.emit('online_status', {
      'userId': userId,
      'isOnline': isOnline,
    });
  }

  @override
  void listenToOnlineStatus(Function(OnlineStatus) onStatusChanged) {
    socketService.on('online_status_update', (data) {
      try {
        final map = Map<String, dynamic>.from(data);
        final status = OnlineStatus(
          userId: map['userId'],
          isOnline: map['isOnline'],
        );
        onStatusChanged(status);
      } catch (e) {
        print("❌ Error parsing online status: $e");
      }
    });
  }

  @override
  void updateTypingStatus({required String chatRoomId, required String userId, required bool isTyping}) {
    socketService.emit('typing_status', {
      'chatRoomId': chatRoomId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  @override
  void listenToTypingStatus(Function(TypingStatus) onTypingChanged) {
    socketService.on('typing_status_update', (data) {
      try {
        final map = Map<String, dynamic>.from(data);
        final status = TypingStatus(
          userId: map['userId'],
          isTyping: map['isTyping'],
        );
        onTypingChanged(status);
      } catch (e) {
        print("❌ Error parsing typing status: $e");
      }
    });
  }

  @override
  void markMessageAsRead({required String chatRoomId, required String messageId, required String userId}) {
    socketService.emit('read_status', {
      'chatRoomId': chatRoomId,
      'messageId': messageId,
      'userId': userId,
    });
  }

  @override
  void listenToReadStatus(Function(ReadStatus) onReadStatusChanged) {
    socketService.on('read_status_update', (data) {
      try {
        final map = Map<String, dynamic>.from(data);
        final status = ReadStatus(
          messageId: map['messageId'],
          userId: map['userId'],
          isRead: true,
        );
        onReadStatusChanged(status);
      } catch (e) {
        print("❌ Error parsing read status: $e");
      }
    });
  }

  @override
  void dispose() {
    socketService.dispose();
  }
}
