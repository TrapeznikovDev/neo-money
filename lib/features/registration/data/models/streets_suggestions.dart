class StreetSuggestion {
  final String title;     // street_with_type
  final String? fiasId;   // street_fias_id (если нужен)

  const StreetSuggestion({required this.title, this.fiasId});

  factory StreetSuggestion.fromJson(Map<String, dynamic> item) {
    final data = (item['data'] as Map?)?.cast<String, dynamic>();
    return StreetSuggestion(
      title: (data?['street_with_type'] as String?) ?? '',
      fiasId: (data?['street_fias_id'] as String?),
    );
  }
}