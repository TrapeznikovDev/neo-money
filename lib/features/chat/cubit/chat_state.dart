import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/chat/model/chat_message_ui.dart';
import 'package:neomoney/features/chat/widgets/chat_message_bubble.dart';

class ChatState implements UiState {
  @override
  final UiStatus status;
  @override
  final String? errorMessage;

  final List<ChatMessageUi> messages;

  const ChatState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.messages = const [],
  });

  ChatState copyWith({
    UiStatus? status,
    String? errorMessage,
    List<ChatMessageUi>? messages,
  }) {
    return ChatState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      messages: messages ?? this.messages,
    );
  }
}