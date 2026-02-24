class CitySuggestion {
  final String title;     // city or settlement (with type optional)
  final String? fiasId;   // city_fias_id or settlement_fias_id
  final String? postalCode;

  const CitySuggestion({required this.title, this.fiasId, this.postalCode});

  factory CitySuggestion.fromJson(Map<String, dynamic> item) {
    final data = (item['data'] as Map?)?.cast<String, dynamic>();

    // DaData: у адреса бывает city или settlement
    final city = (data?['city_with_type'] as String?) ??
        (data?['city'] as String?) ??
        (data?['settlement_with_type'] as String?) ??
        (data?['settlement'] as String?) ??
        '';

    final fiasId = (data?['city_fias_id'] as String?) ?? (data?['settlement_fias_id'] as String?);

    return CitySuggestion(
      title: city,
      fiasId: fiasId,
      postalCode: (data?['postal_code']?.toString()),
    );
  }
}