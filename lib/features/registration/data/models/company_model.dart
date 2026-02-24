class CompanySuggestion {
  final String name;     // suggestions[i].value
  final String address;  // suggestions[i].data.address.value

  const CompanySuggestion({required this.name, required this.address});

  factory CompanySuggestion.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>();
    final addressObj = (data?['address'] as Map?)?.cast<String, dynamic>();

    return CompanySuggestion(
      name: (json['value'] as String?) ?? '',
      address: (addressObj?['value'] as String?) ?? '',
    );
  }
}

class CompaniesResponse {
  final List<CompanySuggestion> suggestions;

  const CompaniesResponse({required this.suggestions});

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['suggestions'] as List?) ?? const [];
    return CompaniesResponse(
      suggestions: list
          .whereType<Map>()
          .map((e) => CompanySuggestion.fromJson(e.cast<String, dynamic>()))
          .where((e) => e.name.isNotEmpty)
          .toList(growable: false),
    );
  }
}