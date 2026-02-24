import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/chat/cubit/chat_cubit.dart';
import 'package:neomoney/features/chat/cubit/chat_state.dart';
import 'package:neomoney/features/chat/widgets/chat_message_bubble.dart';

class ChatScreen extends BaseBlocPage<ChatCubit, ChatState> {
  const ChatScreen({super.key});

  @override
  ChatCubit createBloc(BuildContext context) {
    final cubit = GetIt.I<ChatCubit>();
    Future.microtask(cubit.load);
    return cubit;
  }

  @override
  Widget buildBody(BuildContext context, ChatState state) {
    if (state.status == UiStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text('Чат с поддержкой', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Expanded(
          child: state.messages.isEmpty
              ? const Center(child: Text('Здесь пока нет сообщений.\nЕсли у вас есть вопрос - \nнапишите и мы постараемся его решить. '))
              : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.messages.length,
            itemBuilder: (context, index) =>
                ChatMessageBubble(message: state.messages[index]),
          ),
        ),
        ChatInput(
          onSend: context.read<ChatCubit>().sendMessage,
          enabled: state.status != UiStatus.loading,
        ),
      ],
    );
  }
}