import 'package:neomoney/features/chat/storage/usedesk_chat_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usedesk/usedesk.dart';

class UsedeskChatService {
  UsedeskChat? _chat;
  Future<UsedeskChat>? _initFuture;

  Future<UsedeskChat> getChat() {
    // уже инициализировано
    final existing = _chat;
    if (existing != null) return Future.value(existing);

    // инициализация уже запущена
    final inProgress = _initFuture;
    if (inProgress != null) return inProgress;

    // старт инициализации один раз
    _initFuture = _initChat();
    return _initFuture!;
  }

  Future<UsedeskChat> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = UsedeskChatStorage(prefs);

    final chat = await UsedeskChat.init(
      storage: storage,
      companyId: '161404',
      channelId: '44570',
      apiConfig: const ChatApiConfiguration(
        urlChat: 'https://pubsubsec.usedesk.ru',
        urlOfflineForm: 'https://secure.usedesk.ru/',
        urlToSendFile: 'https://secure.usedesk.ru/uapi/v1/send_file',
      ),
    );

    chat.identify = IdentifyConfiguration(
      name: 'Neomoney User',
      email: 'support@neomoney.app',
      additionalId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    chat.connect();

    _chat = chat;
    return chat;
  }
}
