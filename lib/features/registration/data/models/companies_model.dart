class CompaniesNfModel {
  final List<String> values;

  CompaniesNfModel({required this.values});

  factory CompaniesNfModel.fromJson(Map<String, dynamic> json) {
    final suggestions = (json['suggestions'] as List?) ?? const [];
    final extracted = suggestions
        .map((e) => (e as Map?)?['value']?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return CompaniesNfModel(values: extracted);
  }
}