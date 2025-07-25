import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String chatRoomId;
  LoadMessages(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class SendMessage extends ChatEvent {
  final ChatMessage message;
  SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends ChatEvent {
  final ChatMessage message;
  MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class TypingStatusUpdated extends ChatEvent {
  final String senderId;
  final bool isTyping;
  TypingStatusUpdated({required this.senderId, required this.isTyping});

  @override
  List<Object?> get props => [senderId, isTyping];
}

class OnlineStatusUpdated extends ChatEvent {
  final String userId;
  final bool isOnline;
  OnlineStatusUpdated({required this.userId, required this.isOnline});

  @override
  List<Object?> get props => [userId, isOnline];
}

class ReadStatusUpdated extends ChatEvent {
  final String messageId;
  final String userId;
  ReadStatusUpdated({required this.messageId, required this.userId});

  @override
  List<Object?> get props => [messageId, userId];
}
