import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final Map<String, bool> typingStatus;
  final Map<String, bool> onlineStatus;
  final Map<String, String> readStatus;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.typingStatus = const {},
    this.onlineStatus = const {},
    this.readStatus = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    Map<String, bool>? typingStatus,
    Map<String, bool>? onlineStatus,
    Map<String, String>? readStatus,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      typingStatus: typingStatus ?? this.typingStatus,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      readStatus: readStatus ?? this.readStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        typingStatus,
        onlineStatus,
        readStatus,
        isLoading,
        errorMessage,
      ];
}
