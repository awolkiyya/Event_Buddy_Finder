import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/typing_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/online_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/read_status.dart';
import 'package:event_buddy_finder/futures/chat/domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<TypingStatus>? _typingSub;
  StreamSubscription<OnlineStatus>? _onlineStatusSub;
  StreamSubscription<ReadStatus>? _readStatusSub;

  ChatBloc({required this.repository}) : super(const ChatState()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<TypingStatusUpdated>(_onTypingStatusUpdated);
    on<OnlineStatusUpdated>(_onOnlineStatusUpdated);
    on<ReadStatusUpdated>(_onReadStatusUpdated);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      // Use HTTP fetch from repository here (fetchMessages uses Dio HTTP client)
      final messages = await repository.getMessages(chatRoomId: event.chatRoomId);

      // Cancel existing subscriptions before starting new ones
      await _messageSub?.cancel();
      _messageSub = repository.onMessageReceived().listen((message) {
        add(MessageReceived(message));
      });

      await _typingSub?.cancel();
      _typingSub = repository.onTypingStatusChanged(event.chatRoomId).listen((typingStatus) {
        add(TypingStatusUpdated(
          senderId: typingStatus.userId,
          isTyping: typingStatus.isTyping,
        ));
      });

      await _onlineStatusSub?.cancel();
      _onlineStatusSub = repository.onOnlineStatusChanged().listen((status) {
        add(OnlineStatusUpdated(userId: status.userId, isOnline: status.isOnline));
      });

      await _readStatusSub?.cancel();
      _readStatusSub = repository.onReadStatusChanged(event.chatRoomId).listen((readStatus) {
        add(ReadStatusUpdated(messageId: readStatus.messageId, userId: readStatus.userId));
      });

      emit(state.copyWith(messages: messages, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await repository.sendMessage(event.message);
    } catch (e) {
      // Optionally handle send errors here
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(event.message);
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onTypingStatusUpdated(TypingStatusUpdated event, Emitter<ChatState> emit) {
    final updatedTyping = Map<String, bool>.from(state.typingStatus);
    updatedTyping[event.senderId] = event.isTyping;
    emit(state.copyWith(typingStatus: updatedTyping));
  }

  void _onOnlineStatusUpdated(OnlineStatusUpdated event, Emitter<ChatState> emit) {
    final updatedOnline = Map<String, bool>.from(state.onlineStatus);
    updatedOnline[event.userId] = event.isOnline;
    emit(state.copyWith(onlineStatus: updatedOnline));
  }

  void _onReadStatusUpdated(ReadStatusUpdated event, Emitter<ChatState> emit) {
    final updatedRead = Map<String, String>.from(state.readStatus);
    updatedRead[event.messageId] = event.userId;
    emit(state.copyWith(readStatus: updatedRead));
  }

  @override
  Future<void> close() {
    _messageSub?.cancel();
    _typingSub?.cancel();
    _onlineStatusSub?.cancel();
    _readStatusSub?.cancel();
    return super.close();
  }
}
