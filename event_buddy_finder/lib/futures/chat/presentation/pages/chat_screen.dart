import 'package:event_buddy_finder/futures/chat/presentation/components/ChatInputField.dart';
import 'package:event_buddy_finder/futures/chat/presentation/components/MessageBubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_buddy_finder/futures/chat/domain/entities/chat_message.dart';
import 'package:event_buddy_finder/futures/chat/presentation/blocs/chat_bloc.dart';
import 'package:event_buddy_finder/futures/chat/presentation/blocs/chat_event.dart';
import 'package:event_buddy_finder/futures/chat/presentation/blocs/chat_state.dart';


class ConversationScreen extends StatefulWidget {
  final String chatUserName;
  final String chatRoomId;
  final String currentUserId;

  const ConversationScreen({
    Key? key,
    required this.chatUserName,
    required this.chatRoomId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.chatRoomId));
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: '',
      senderId: widget.currentUserId,
      receiverId: widget.chatUserName,
      message: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    context.read<ChatBloc>().add(SendMessage(message));
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUserName),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.errorMessage != null) {
                  return Center(child: Text('Error: ${state.errorMessage}'));
                } else if (state.messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    return MessageBubble(text: message.message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          MessageInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
