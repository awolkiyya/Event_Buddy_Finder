import 'package:event_buddy_finder/futures/chat/data/models/chat_message_model.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheMessage(ChatMessageModel message);
  Future<List<ChatMessage>> getCachedMessages(String chatRoomId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  // You can use Hive, SharedPreferences, or any other local db here.
  
  @override
  Future<void> cacheMessage(ChatMessageModel message) async {
    // TODO: Implement local cache
    print("💾 Caching message: ${message.toJson()}");
  }

  @override
  Future<List<ChatMessage>> getCachedMessages(String chatRoomId) async {
    // TODO: Implement fetching from local cache
    return [];
  }
}
