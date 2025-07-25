import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/online_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/read_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/typing_status.dart';

abstract class ChatRepository {
  // 🔹 Message APIs
  Future<List<ChatMessage>> getMessages({required String chatRoomId});
  Future<void> sendMessage(ChatMessage message);
  Stream<ChatMessage> onMessageReceived();

  // 🔹 Typing Status
  Future<void> updateTypingStatus({required String chatRoomId, required String userId, required bool isTyping}); //sender side
  Stream<TypingStatus> onTypingStatusChanged(String chatRoomId); // leasten for update reciever side

  // 🔹 Online Status
  Stream<OnlineStatus> onOnlineStatusChanged(); // on reciever side
  Future<void> setOnlineStatus(String userId, bool isOnline);

  // 🔹 Read Status
  Future<void> markMessageAsRead({required String chatRoomId, required String messageId, required String userId});
  Stream<ReadStatus> onReadStatusChanged(String chatRoomId);
}
