import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/cards/data/hepler/helper.dart';
import 'package:neomoney/features/chat/cubit/chat_state.dart';
import 'package:neomoney/features/chat/model/chat_message_ui.dart';
import 'package:neomoney/features/chat/services/usedesk_chat_service.dart';
import 'package:usedesk/usedesk.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._service) : super(const ChatState());

  final UsedeskChatService _service;

  UsedeskChat? _chat;
  StreamSubscription<List<MessageBase>>? _sub;

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final chat = _chat ??= await _service.getChat();

      await _sub?.cancel();
      _sub = chat.messagesStream.listen((messages) {
        final ui = messages.map(mapUsedeskMessage).whereType<ChatMessageUi>().toList();
        emit(state.copyWith(status: UiStatus.success, messages: ui));
      });

      final initial = chat.messages.map(mapUsedeskMessage).whereType<ChatMessageUi>().toList();
      emit(state.copyWith(status: UiStatus.success, messages: initial));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> sendMessage(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) return;

    try {
      final chat = _chat ??= await _service.getChat();
      chat.sendText(msg, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _chat?.disconnect();
    return super.close();
  }
}