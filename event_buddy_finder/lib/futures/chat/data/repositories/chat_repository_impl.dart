import 'package:event_buddy_finder/futures/chat/data/datasources/chat_local_data_source.dart';
import 'package:event_buddy_finder/futures/chat/data/datasources/chat_remote_data_source.dart';
import 'package:event_buddy_finder/futures/chat/data/models/chat_message_model.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/online_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/read_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/typing_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSourceImpl localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // 🔹 Message APIs
  @override
  Future<List<ChatMessage>> getMessages({required String chatRoomId}) async {
    // Assuming you implement fetchMessages in remoteDataSource returning List<ChatMessageModel>
    final models = await remoteDataSource.fetchMessages(chatRoomId: chatRoomId);
    // Convert models to entities
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final model = ChatMessageModel.fromEntity(message);
    remoteDataSource.sendMessage(model);
  }

  @override
  Stream<ChatMessage> onMessageReceived() {
    return Stream<ChatMessage>.multi((controller) {
      remoteDataSource.listenToMessages((model) {
        controller.add(model.toEntity());
      });
    });
  }

  // 🔹 Typing Status
  @override
  Future<void> updateTypingStatus({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) async {
    remoteDataSource.updateTypingStatus(
      chatRoomId: chatRoomId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  @override
  Stream<TypingStatus> onTypingStatusChanged(String chatRoomId) {
    return Stream<TypingStatus>.multi((controller) {
      remoteDataSource.listenToTypingStatus((status) {
        controller.add(status);
      });
    });
  }

  // 🔹 Online Status
  @override
  Future<void> setOnlineStatus(String userId, bool isOnline) async {
    remoteDataSource.setOnlineStatus(userId, isOnline);
  }

  @override
  Stream<OnlineStatus> onOnlineStatusChanged() {
    return Stream<OnlineStatus>.multi((controller) {
      remoteDataSource.listenToOnlineStatus((status) {
        controller.add(status);
      });
    });
  }

  // 🔹 Read Status
  @override
  Future<void> markMessageAsRead({
    required String chatRoomId,
    required String messageId,
    required String userId,
  }) async {
    remoteDataSource.markMessageAsRead(
      chatRoomId: chatRoomId,
      messageId: messageId,
      userId: userId,
    );
  }

  @override
  Stream<ReadStatus> onReadStatusChanged(String chatRoomId) {
    return Stream<ReadStatus>.multi((controller) {
      remoteDataSource.listenToReadStatus((status) {
        controller.add(status);
      });
    });
  }
}
