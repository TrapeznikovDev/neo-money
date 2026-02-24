class ChatMessageUi {
  final int id;
  final String text;
  final DateTime createdAt;
  final bool isFromUser;

  const ChatMessageUi({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isFromUser,
  });
}