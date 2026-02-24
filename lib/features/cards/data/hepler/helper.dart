import 'package:neomoney/features/chat/model/chat_message_ui.dart';
import 'package:usedesk/usedesk.dart';

String formatCardMasked(String cardNumber) {
  final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 8) return digits;

  final first4 = digits.substring(0, 4);
  final last4 = digits.substring(digits.length - 4);
  return '$first4  ****  ****  $last4';
}

String getCardTypeAsset(String cardNumber) {
  final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return '';

  final prefix = int.tryParse(digits.substring(0, 4));
  if (prefix == null) return '';

  if (prefix >= 4000 && prefix <= 4999) return 'assets/icons/visa.png';
  if ((prefix >= 5100 && prefix <= 5599) || (prefix >= 2221 && prefix <= 2720)) {
    return 'assets/icons/master.png';
  }
  if (prefix >= 2200 && prefix <= 2204) return 'assets/icons/mir.png';

  return '';
}

ChatMessageUi? mapUsedeskMessage(MessageBase m) {
  // Сообщение клиента
  if (m is MessageTextClient) {
    return ChatMessageUi(
      id: m.id,
      text: m.text,
      createdAt: m.createdAt,
      isFromUser: true,
    );
  }

  // Сообщение поддержки
  if (m is MessageText) {
    return ChatMessageUi(
      id: m.id,
      text: m.text, // <-- и у MessageText
      createdAt: m.createdAt,
      isFromUser: false,
    );
  }

  return null;
}