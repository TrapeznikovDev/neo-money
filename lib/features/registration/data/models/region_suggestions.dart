class RegionSuggestion {
  final String title;     // region_with_type
  final String? fiasId;   // region_fias_id
  final String? postalCode;

  const RegionSuggestion({required this.title, this.fiasId, this.postalCode});

  factory RegionSuggestion.fromJson(Map<String, dynamic> item) {
    final data = (item['data'] as Map?)?.cast<String, dynamic>();
    return RegionSuggestion(
      title: (data?['region_with_type'] as String?) ?? '',
      fiasId: (data?['region_fias_id'] as String?),
      postalCode: (data?['postal_code']?.toString()),
    );
  }
}