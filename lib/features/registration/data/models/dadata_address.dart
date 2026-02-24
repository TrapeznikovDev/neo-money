class DadataAddress {
  final String value;
  final String fiasId;

  DadataAddress({
    required this.value,
    required this.fiasId,
  });

  factory DadataAddress.fromJson(Map<String, dynamic> json) {
    return DadataAddress(
      value: json['value'],
      fiasId: json['data']?['fias_id'] ?? '',
    );
  }
}