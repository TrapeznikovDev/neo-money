class CardModel {
  final int id;
  final String cardNumber;
  final int autoDebiting;
  final String type;
  final int organizationId;

  CardModel({
    required this.id,
    required this.cardNumber,
    required this.autoDebiting,
    required this.type,
    required this.organizationId,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? 0,
      cardNumber: json['card_number'] ?? '',
      autoDebiting: json['auto_debiting'] ?? 0,
      type: json['type'] ?? '',
      organizationId: json['organization_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_number': cardNumber,
      'auto_debiting': autoDebiting,
      'type': type,
      'organization_id': organizationId,
    };
  }
}